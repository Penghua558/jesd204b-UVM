class ila2erb_seq extends uvm_sequence #(erb_trans);
    `uvm_object_utils(ila2erb_seq)
    // we want to access instruction_trans of erb_sequencer, so we 
    // declares a p_sequencer, since m_sequencer's class is uvm_sequencer_base
    // from which we can not access user defined variables
    `uvm_declare_p_sequencer(erb_sequencer)

    uvm_sequencer #(ila_trans) up_sequencer;
    rx_jesd204b_layering_config m_cfg;
    // Standard UVM Methods:
    extern function new(string name = "ila2erb_seq");
    extern task body;
endclass


function ila2erb_seq::new(string name = "ila2erb_seq");
    super.new(name);
endfunction


task ila2erb_seq::body;
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

    m_cfg = rx_jesd204b_layering_config::get_config(m_sequencer);
    syncn_assertion_length = 0;
    fcounter = 0;

    forever begin
        up_sequencer.get_next_item(erb_req);
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
                erb_req.valid = sample_trans.valid;
            end else begin
                erb_req.sync_request |= sample_trans.sync_request;
                erb_req.valid &= sample_trans.valid;
            end
            num_octet++;

            self_o_position = (self_o_position+1) % m_cfg.F;
        end


        repeat(m_cfg.F) begin
            cgs_trans = cgsnfs_trans::type_id::create("cgs_trans");
            start_item(cgs_trans);
            // manipulate cgs_trans meant to be sent to lower layering
            cgs_trans.sync_n = sync_n;
            finish_item(cgs_trans);
        end

        fcounter = (fcounter+1) % m_cfg.K;
        up_sequencer.item_done();
    end
endtask
