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
    // transition sampled from monitor
    cgsnfs_trans sample_trans;
    ila_trans ila_req;
    int num_octet;
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

    m_cfg = rx_jesd204b_layering_config::get_config(m_sequencer);
    syncn_assertion_length = 0;
    fcounter = 0;

    forever begin
        up_sequencer.get_next_item(ila_req);
        num_octet = 0;
        self_o_position = 0;
        sync_n = 1'b1;
        sync_n_prev_frame = 1'b1;
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
                ila_req.sync_request = sample_trans.sync_request;
                ila_req.valid = sample_trans.valid;
            end else begin
                ila_req.sync_request |= sample_trans.sync_request;
                ila_req.valid &= sample_trans.valid;
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

        `uvm_info("TEST", $sformatf("SYNC~ assertion frame length: %0d", 
            syncn_assertion_length), UVM_HIGH)
        sync_n = 
            (!ila_req.sync_request && 
            (syncn_assertion_length >= min_syncn_assertion_length) && 
            (fcounter == 0)) || (!ila_req.sync_request && sync_n_prev_frame);

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
