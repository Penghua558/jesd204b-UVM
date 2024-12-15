class ila2cgs_seq extends uvm_sequence #(cgsnfs_trans);
    `uvm_object_utils(ila2cgs_seq)

    uvm_sequencer #(ila_trans) up_sequencer;
    // Standard UVM Methods:
    extern function new(string name = "ila2cgs_seq");
    extern task body;
endclass


function ila2cgs_seq::new(string name = "ila2cgs_seq");
    super.new(name);
endfunction


task ila2cgs_seq::body;
    cgsnfs_trans cgs_trans;
    ila_trans ila_req;
    ila_trans ila_rsp;

    forever begin
        up_sequencer.get_next_item(ila_req);
        // setup_phase(ila_req);
        up_sequencer.item_done();

        up_sequencer.get_next_item(ila_rsp);
        cgs_trans = cgsnfs_trans::type_id::create("cgs_trans");
        start_item(cgs_trans);
        // manipulate cgs_trans meant to be sent to lower layering
        //access_phase(ila_req, ila_rsp);
        finish_item(cgs_trans);
        up_sequencer.item_done();
    end
endtask
