import apb_agent_dec::*;
class apb_rand_write_sequence extends uvm_sequence #(apb_trans);

// UVM Factory Registration Macro
//
`uvm_object_utils(apb_rand_write_sequence)


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
extern function new(string name = "apb_rand_write_sequence");
extern task body;
extern task write(uvm_sequencer_base seqr, uvm_sequence_base parent = null);

endclass:apb_rand_write_sequence

function apb_rand_write_sequence::new(string name = "apb_rand_write_sequence");
  super.new(name);
endfunction

task apb_rand_write_sequence::body;
    apb_agent_config m_cfg = apb_agent_config::get_config(this);
    apb_trans req = apb_trans::type_id::create("req");;

    begin
        start_item(req);
        assert(req.randomize() with {
            wr == WRITE;
            addr >= m_cfg.start_address[m_cfg.apb_index]; 
            addr <= m_cfg.start_address[m_cfg.apb_index] + 
                m_cfg.range[m_cfg.apb_index];
        });
        finish_item(req);
    end
endtask:body

task apb_rand_write_sequence::write(uvm_sequencer_base seqr, 
    uvm_sequence_base parent = null);
    this.start(seqr, parent);
endtask
