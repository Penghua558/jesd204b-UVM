import apb_agent_dec::*;
class apb_read_sequence extends uvm_sequence #(apb_trans);

// UVM Factory Registration Macro
//
`uvm_object_utils(apb_read_sequence)


//------------------------------------------
// Data Members (Outputs rand, inputs non-rand)
//------------------------------------------
logic [15:0] data;
logic [15:0] addr;

//------------------------------------------
// Constraints
//------------------------------------------



//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:
extern function new(string name = "apb_read_sequence");
extern task body;
extern task read(bit[15:0] addr, uvm_sequencer_base seqr, 
    uvm_sequence_base parent = null);

endclass:apb_read_sequence

function apb_read_sequence::new(string name = "apb_read_sequence");
  super.new(name);
endfunction

task apb_read_sequence::body;
    apb_trans req = apb_trans::type_id::create("req");;

    begin
        start_item(req);
        assert(req.randomize() with {
            wr == READ;
            addr == local::addr;
        });
        finish_item(req);
        data = req.rdata;
    end
endtask:body

task apb_read_sequence::read(bit[15:0] addr, uvm_sequencer_base seqr, 
    uvm_sequence_base parent = null);
    this.addr = addr;
    this.start(seqr, parent);
endtask
