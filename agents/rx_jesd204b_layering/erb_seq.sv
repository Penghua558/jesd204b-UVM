class erb_seq extends uvm_sequence #(erb_trans);
    `uvm_object_utils(erb_seq)

    // Standard UVM Methods:
    extern function new(string name = "erb_seq");
    extern task body;
endclass


function erb_seq::new(string name = "erb_seq");
    super.new(name);
endfunction


task erb_seq::body;
    erb_trans req = erb_trans::type_id::create("req");

    start_item(req);
    assert(req.randomize());
    finish_item(req);
endtask
