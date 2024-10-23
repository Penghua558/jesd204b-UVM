class enc_bus_agent_config extends uvm_object;

localparam string s_my_config_id = "enc_bus_agent_config";
localparam string s_no_config_id = "no config";
localparam string s_my_config_type_error_id = "config type error";

// UVM Factory Registration Macro
//
`uvm_object_utils(enc_bus_agent_config)

// BFM Virtual Interfaces
virtual enc_bus_monitor_bfm mon_bfm;
virtual enc_bus_driver_bfm drv_bfm;

//------------------------------------------
// Data Members
//------------------------------------------
// Is the agent active or passive
uvm_active_passive_enum active = UVM_ACTIVE;
// Include the APB functional coverage monitor
bit has_functional_coverage = 0;
// Include the APB RAM based scoreboard
bit has_scoreboard = 0;
//

//------------------------------------------
// Methods
//------------------------------------------
extern static function enc_bus_agent_config get_config( uvm_component c );
// Standard UVM Methods:
extern function new(string name = "enc_bus_agent_config");
extern task wait_for_reset();

endclass: enc_bus_agent_config

function enc_bus_agent_config::new(string name = "enc_bus_agent_config");
  super.new(name);
endfunction

task enc_bus_agent_config::wait_for_reset();
    mon_bfm.wait_for_reset();
endtask

//
// Function: get_config
//
// This method gets the my_config associated with component c. We check for
// the two kinds of error which may occur with this kind of
// operation.
//
function enc_bus_agent_config enc_bus_agent_config::get_config( 
    uvm_component c );
  enc_bus_agent_config t;

  if (!uvm_config_db#(enc_bus_agent_config)::get(c, "", s_my_config_id, t) )
     `uvm_fatal("ENC_BUS_AGENT_CONFIG", 
        $sformatf("Cannot get() configuration %s \
        from uvm_config_db. Have you set() it?", s_my_config_id))

  return t;
endfunction
