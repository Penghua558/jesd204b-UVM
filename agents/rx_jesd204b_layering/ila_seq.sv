class ila_seq extends uvm_sequence #(ila_trans);
    `uvm_object_utils(ila_seq)

    rx_jesd204b_layering_config m_cfg;
    // Standard UVM Methods:
    extern function new(string name = "ila_seq");
    extern task body;
endclass


function ila_seq::new(string name = "ila_seq");
    super.new(name);
endfunction


task ila_seq::body;
    ila_trans req = ila_trans::type_id::create("req");
    m_cfg = rx_jesd204b_layering_config::get_config(m_sequencer);

    start_item(req);
    `uvm_info("ILA SEQ", "debug here?", UVM_MEDIUM)
    assert(req.randomize() with {
        if (!m_cfg.randomize_err_report) err_report == 1'b0;
    });
    `uvm_info("ILA SEQ", "or debug here?", UVM_MEDIUM)
    finish_item(req);
endtask
