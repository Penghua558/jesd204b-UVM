class erb2cgs_seq extends uvm_sequence #(cgsnfs_trans);
    `uvm_object_utils(erb2cgs_seq)
    // we want to access instruction_trans of cgsnfs_sequencer, so we 
    // declares a p_sequencer, since m_sequencer's class is uvm_sequencer_base
    // from which we can not access user defined variables
    `uvm_declare_p_sequencer(cgsnfs_sequencer)

    uvm_sequencer #(erb_trans) up_sequencer;
    rx_jesd204b_layering_config m_cfg;
    // Standard UVM Methods:
    extern function new(string name = "erb2cgs_seq");
    extern task body;
endclass


function erb2cgs_seq::new(string name = "erb2cgs_seq");
    super.new(name);
endfunction


task erb2cgs_seq::body;
    cgsnfs_trans cgs_trans;
    // transition sampled from monitor
    cgsnfs_trans sample_trans;
    erb_trans erb_req;
    int num_octet;
    int self_o_position;
    int o_position;
    // frame position in current multiframe, 0 ~ K-1
    // 0 is considered at the boundary of LMFC
    int fcounter;
    // minimum number of frames to last when SYNC~ is asserted when requiring
    // link re-initialization
    int min_syncn_assertion_length;
    // length of assertion of SYNC~ in unit of frame
    int syncn_assertion_length;
    bit sync_n;
    bit sync_n_prev_frame;
    // 1 - SYNC~ is asserted by requiring link re-initialization
    // 0 - SYNC ~ is not asserted by requiring link re-initialization or
    // SYNC~ is not asserted
    bit asserted_by_sync_request;
    // 1 - assert SYNC~ 2 frames prior of the end of current LMFC
    // 0 - no SYNC~ assertion caused by error reporting at current LMFC
    bit err_report_assert_current_lmfc;
    // 1 - error report raised at this LMFC
    // 0 - error report not raised at this LMFC
    bit err_report_raised_current_lmfc;

    m_cfg = rx_jesd204b_layering_config::get_config(m_sequencer);
    syncn_assertion_length = 0;
    fcounter = 0;
    sync_n_prev_frame = 1'b1;
    asserted_by_sync_request = 1'b0;
    err_report_assert_current_lmfc = 1'b0;
    err_report_raised_current_lmfc = 1'b0;

    forever begin
        up_sequencer.get_next_item(erb_req);
        num_octet = 0;
        self_o_position = 0;
        sync_n = 1'b1;
        // setup phase, get sync_request from lower layer
        // wait for F valid octets
        while (num_octet != m_cfg.F) begin
            `uvm_info("TEST", $sformatf("num_octet in a frame: %0d", 
                num_octet), UVM_HIGH)
            // wait for cgsnfs_trans sent from dec2cgs_monitor
            wait(p_sequencer.instruction_trans.size());
            sample_trans = p_sequencer.instruction_trans.pop_front();

            if (sample_trans.ifsstate == FS_INIT) begin
                o_position = self_o_position;
            end else if (sample_trans.valid) begin
                o_position = sample_trans.o_position;
            end else begin
                o_position = o_position;
            end

            if (num_octet == 0) begin
                erb_req.sync_request = sample_trans.sync_request;
            end else begin
                erb_req.sync_request |= sample_trans.sync_request;
            end
            num_octet++;

            self_o_position = (self_o_position+1) % m_cfg.F;
        end

        // minimum lengths for SYNC~ asssertion is 5 frames + 9 octets, since
        // SYNC~ deassertion should happen at LMFC boundaries so we should
        // round it up to the minimum frames
        min_syncn_assertion_length = 5 + $ceil(9.0 / m_cfg.F);
        // access phase, drive SYNC~ according to sync_request and the length
        // of assertion of SYNC~

        if (fcounter == 0) begin
            // at boundary of LMFC, we detect if error report was raised at
            // last LMFC period
            err_report_assert_current_lmfc = err_report_raised_current_lmfc;
            // at boundary of LMFC, we detect error report from the start
            // again
            err_report_raised_current_lmfc = 1'b0;
        end

        err_report_raised_current_lmfc |= erb_req.err_report;

        `uvm_info("TEST", $sformatf("SYNC~ assertion frame length: %0d", 
            syncn_assertion_length), UVM_HIGH)
        `uvm_info("TEST", $sformatf("minimum SYNC~ assertion frame length: %0d",
            min_syncn_assertion_length), UVM_HIGH)
        `uvm_info("TEST", $sformatf("sync request: %b", erb_req.sync_request), 
            UVM_HIGH)
        `uvm_info("TEST", $sformatf("Current frame position: %0d", fcounter), 
            UVM_HIGH)
        `uvm_info("TEST", $sformatf("SYNC~ at previous frame: %b", 
            sync_n_prev_frame), UVM_HIGH)
        `uvm_info("TEST", 
            $sformatf("SYNC~ shall be asserted due to error reporting: %b", 
            err_report_assert_current_lmfc), UVM_HIGH)
        `uvm_info("TEST", 
            $sformatf("Error report detected at current LMFC: %b", 
            err_report_raised_current_lmfc), UVM_HIGH)


        if ((erb_req.sync_request && sync_n_prev_frame) ||
            (!sync_n_prev_frame && asserted_by_sync_request))begin
            // SYNC~ is controlled by link re-initialization
            sync_n = 
                (!erb_req.sync_request && 
                (syncn_assertion_length >= min_syncn_assertion_length) && 
                (fcounter == 0))||(!erb_req.sync_request && sync_n_prev_frame);

            asserted_by_sync_request = ~sync_n;
        end else begin
            // SYNC~ is controlled by error reporting
            sync_n = !(err_report_assert_current_lmfc && 
                (fcounter >= m_cfg.K-2 && fcounter <= m_cfg.K-1));

            asserted_by_sync_request = 1'b0;
        end

        repeat(m_cfg.F) begin
            cgs_trans = cgsnfs_trans::type_id::create("cgs_trans");
            start_item(cgs_trans);
            // manipulate cgs_trans meant to be sent to lower layering
            cgs_trans.sync_n = sync_n;
            finish_item(cgs_trans);
        end

        if (!sync_n)
            syncn_assertion_length++;
        else
            syncn_assertion_length = 0;

        fcounter = (fcounter+1) % m_cfg.K;
        sync_n_prev_frame = sync_n;
        up_sequencer.item_done();

    end
endtask
