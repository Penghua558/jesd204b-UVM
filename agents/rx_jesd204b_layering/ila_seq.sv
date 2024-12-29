class ila_seq extends uvm_sequence #(ila_trans);
    `uvm_object_utils(ila_seq)

    // Standard UVM Methods:
    extern function new(string name = "ila_seq");
    extern task body;
endclass


function ila_seq::new(string name = "ila_seq");
    super.new(name);
endfunction


task ila_seq::body;
    ila_trans req = ila_trans::type_id::create("req");

    start_item(req);
    assert(req.randomize());
    finish_item(req);
endtask
