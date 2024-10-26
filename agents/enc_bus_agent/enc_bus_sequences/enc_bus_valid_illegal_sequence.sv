class enc_bus_valid_illegal_sequence extends uvm_sequence #(enc_bus_trans);

// UVM Factory Registration Macro
//
`uvm_object_utils(enc_bus_valid_illegal_sequence)


//------------------------------------------
// Data Members (Outputs rand, inputs non-rand)
//------------------------------------------

//------------------------------------------
// Constraints
//------------------------------------------



//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:
extern function new(string name = "enc_bus_valid_illegal_sequence");
extern task body;

endclass:enc_bus_valid_illegal_sequence

function enc_bus_valid_illegal_sequence::new(string name = 
    "enc_bus_valid_illegal_sequence");
  super.new(name);
endfunction

task enc_bus_valid_illegal_sequence::body;
    enc_bus_agent_config m_cfg = enc_bus_agent_config::get_config(this);
    enc_bus_trans req = enc_bus_trans::type_id::create("req");

    begin
        start_item(req);
        req.control_word_legal_c.constraint_mode(0);
        assert(req.randomize() with {valid == 1'b1;});
        finish_item(req);
    end
endtask:body
