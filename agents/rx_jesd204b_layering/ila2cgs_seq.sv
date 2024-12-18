class ila2cgs_seq extends uvm_sequence #(cgsnfs_trans);
    `uvm_object_utils(ila2cgs_seq)
    // we want to access instruction_trans of cgsnfs_sequencer, so we 
    // declares a p_sequencer, since m_sequencer's class is uvm_sequencer_base
    // from which we can not access user defined variables
    `uvm_declare_p_sequencer(cgsnfs_sequencer)

    uvm_sequencer #(ila_trans) up_sequencer;
    rx_jesd204b_layering_config m_cfg;
    // Standard UVM Methods:
    extern function new(string name = "ila2cgs_seq");
    extern task body;
endclass


function ila2cgs_seq::new(string name = "ila2cgs_seq");
    super.new(name);
endfunction


task ila2cgs_seq::body;
    cgsnfs_trans cgs_trans;
    cgsnfs_trans sample_trans;
    ila_trans ila_req;
    ila_trans ila_rsp;
    int num_valid_octet;
    int self_o_position;
    int o_position;
    // frame position in current multiframe, 0 ~ K-1
    // 0 is considered at the boundary of LMFC
    int fcounter;
    // minimum number of frames to last when SYNC~ is asserted
    int min_syncn_assertion_length;
    // length of assertion of SYNC~ in unit of frame
    int syncn_assertion_length;
    bit sync_n;
    bit sync_n_prev_frame;
    // sync_request from previous frame, we need this to detect when is the
    // start of SYNC~ assertion
    bit sync_request_prev_frame;

    m_cfg = rx_jesd204b_layering_config::get_config(m_sequencer);
    syncn_assertion_frame_length = 0;
    sync_request_prev_frame = 1'b0;
    syncn_assertion_length = 15;
    fcounter = 0;

    forever begin
        up_sequencer.get_next_item(ila_req);
        num_valid_octet = 0;
        self_o_position = 0;
        sync_n = 1'b1;
        sync_n_prev_frame = 1'b1;
        // setup phase, get sync_request from lower layer
        // wait for F valid octets
        while (num_valid_octet != m_cfg.F) begin
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

            if (sample_trans.valid && o_position == 0) begin
                num_valid_octet = 0;
                ila_req.sync_request = sample_trans.sync_request;
            end else begin
                num_valid_octet++;
            end

            self_o_position = (self_o_position++) % m_cfg.F;
        end

        // minimum lengths for SYNC~ asssertion is 5 frames + 9 octets, since
        // SYNC~ deassertion should happen at LMFC boundaries so we should
        // round it up to the minimum frames
        min_syncn_assertion_frame_length = 5 + $ceil(9 / m_cfg.F);
        // access phase, drive SYNC~ according to sync_request and the length
        // of assertion of SYNC~
        if (!sync_request_prev_frame && ila_req.sync_request) begin
            syncn_assertion_length = 0;
        end
        sync_n = 
            (!ila_req.sync_request && 
            (syncn_assertion_length >= min_syncn_assertion_length) && 
            (fcounter == 0)) || (!ila_req.sync_request && !sync_n_prev_frame);

        repeat(m_cfg.F) begin
            cgs_trans = cgsnfs_trans::type_ceilingid::create("cgs_trans");
            start_item(cgs_trans);
            // manipulate cgs_trans meant to be sent to lower layering
            cgs_trans.sync_n = sync_n;
            finish_item(cgs_trans);
        end

        if (!sync_n)
            syncn_assertion_length++;

        fcounter = (fcounter++) % m_cfg.K;
        sync_n_prev_frame = sync_n;
        sync_request_prev_frame = ila_req.sync_request;
        up_sequencer.item_done();

    end
endtask
