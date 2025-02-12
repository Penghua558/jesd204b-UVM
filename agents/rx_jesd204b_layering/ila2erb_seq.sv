class ila2erb_seq extends uvm_sequence #(erb_trans);
    `uvm_object_utils(ila2erb_seq)
    // we want to access instruction_trans of erb_sequencer, so we 
    // declares a p_sequencer, since m_sequencer's class is uvm_sequencer_base
    // from which we can not access user defined variables
    `uvm_declare_p_sequencer(erb_sequencer)

    uvm_sequencer #(ila_trans) up_sequencer;
    rx_jesd204b_layering_config m_cfg;
    ILA_StateMachine m_ila_fsm;

    // Standard UVM Methods:
    extern function new(string name = "ila2erb_seq");
    extern task body;
endclass


function ila2erb_seq::new(string name = "ila2erb_seq");
    super.new(name);
endfunction


task ila2erb_seq::body;
    erb_trans drive_trans;
    // transition sampled from monitor
    erb_trans sample_trans;
    ila_trans ila_req;

    m_cfg = rx_jesd204b_layering_config::get_config(m_sequencer);
    m_ila_fsm = new();
    m_ila_fsm.m_ila_info_extractor = m_cfg.m_ila_info_extractor;

    forever begin
        up_sequencer.get_next_item(ila_req);
        // setup phase, get sync_request from lower layer
        // wait for cgsnfs_trans sent from dec2cgs_monitor
        wait(p_sequencer.instruction_trans.size());
        sample_trans = p_sequencer.instruction_trans.pop_front();

        m_ila_fsm.state_func(ila_req);
        m_ila_fsm.get_nextstate(sample_trans);
        m_ila_fsm.update_currentstate();

        drive_trans = erb_trans::type_id::create("drive_trans");
        start_item(drive_trans);
        // manipulate drive_trans meant to be sent to lower layering
        drive_trans.err_report = ila_req.err_report;
        finish_item(drive_trans);

        up_sequencer.item_done();
    end
endtask
