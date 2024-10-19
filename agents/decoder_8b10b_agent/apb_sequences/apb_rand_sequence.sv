import apb_agent_dec::*;
class apb_rand_sequence extends uvm_sequence #(apb_trans);

// UVM Factory Registration Macro
//
`uvm_object_utils(apb_rand_sequence)


//------------------------------------------
// Data Members (Outputs rand, inputs non-rand)
//------------------------------------------
logic [15:0] rdata;


//------------------------------------------
// Constraints
//------------------------------------------



//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:
extern function new(string name = "apb_rand_sequence");
extern task body;

endclass:apb_rand_sequence

function apb_rand_sequence::new(string name = "apb_rand_sequence");
  super.new(name);
endfunction

task apb_rand_sequence::body;
    apb_agent_config m_cfg = apb_agent_config::get_config(this);
    apb_trans req = apb_trans::type_id::create("req");

    begin
        start_item(req);
        assert(req.randomize() with {
            addr >= m_cfg.start_address[m_cfg.apb_index]; 
            addr <= m_cfg.start_address[m_cfg.apb_index] + 
                m_cfg.range[m_cfg.apb_index];
        });
        finish_item(req);

        if (req.wr == READ)
            rdata = req.rdata;
    end
endtask:body
