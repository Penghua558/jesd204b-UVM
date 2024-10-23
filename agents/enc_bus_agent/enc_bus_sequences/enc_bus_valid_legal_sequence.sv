class enc_bus_valid_legal_sequence extends uvm_sequence #(enc_bus_trans);

// UVM Factory Registration Macro
//
`uvm_object_utils(enc_bus_valid_legal_sequence)


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
extern function new(string name = "enc_bus_valid_legal_sequence");
extern task body;
extern task read(uvm_sequencer_base seqr, uvm_sequence_base parent = null);

endclass:enc_bus_valid_legal_sequence

function enc_bus_valid_legal_sequence::new(string name = 
    "enc_bus_valid_legal_sequence");
  super.new(name);
endfunction

task enc_bus_valid_legal_sequence::body;
    enc_bus_agent_config m_cfg = enc_bus_agent_config::get_config(this);
    enc_bus_trans req = enc_bus_trans::type_id::create("req");;

    begin
        start_item(req);
        assert(req.randomize() with (valid == 1'b1));
        finish_item(req);
    end
endtask:body
