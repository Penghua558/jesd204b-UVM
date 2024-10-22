class decoder_8b10b_agent_config extends uvm_object;

localparam string s_my_config_id = "decoder_8b10b_agent_config";
localparam string s_no_config_id = "no config";
localparam string s_my_config_type_error_id = "config type error";

// UVM Factory Registration Macro
//
`uvm_object_utils(decoder_8b10b_agent_config)

// BFM Virtual Interfaces
virtual decoder_8b10b_monitor_bfm mon_bfm;

//------------------------------------------
// Data Members
//------------------------------------------
// Is the agent active or passive
uvm_active_passive_enum active = UVM_PASSIVE;
// Include the APB functional coverage monitor
bit has_functional_coverage = 0;
// Include the APB RAM based scoreboard
bit has_scoreboard = 0;

//------------------------------------------
// Methods
//------------------------------------------
extern static function decoder_8b10b_agent_config get_config( uvm_component c );
// Standard UVM Methods:
extern function new(string name = "decoder_8b10b_agent_config");
extern task wait_for_reset();

endclass: decoder_8b10b_agent_config

function decoder_8b10b_agent_config::new(string name = 
    "decoder_8b10b_agent_config");
  super.new(name);
endfunction

task decoder_8b10b_agent_config::wait_for_reset();
    mon_bfm.wait_for_reset();
endtask

//
// Function: get_config
//
// This method gets the my_config associated with component c. We check for
// the two kinds of error which may occur with this kind of
// operation.
//
function decoder_8b10b_agent_config decoder_8b10b_agent_config::get_config( 
    uvm_component c );
  decoder_8b10b_agent_config t;

  if (!uvm_config_db#(decoder_8b10b_agent_config)::get(c, "", 
      s_my_config_id, t))
     `uvm_fatal("DECODER_8B10B_AGENT_CONFIG", 
         $sformatf("Cannot get() configuration %s \
        from uvm_config_db. Have you set() it?", s_my_config_id))

  return t;
endfunction
