class apb_agent_config extends uvm_object;

localparam string s_my_config_id = "apb_agent_config";
localparam string s_no_config_id = "no config";
localparam string s_my_config_type_error_id = "config type error";

// UVM Factory Registration Macro
//
`uvm_object_utils(apb_agent_config)

// BFM Virtual Interfaces
virtual apb_monitor_bfm mon_bfm;
virtual apb_driver_bfm drv_bfm;

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
int apb_index = 0; // Which PSEL is the monitor connected to
bit [15:0] start_address[0:15];
bit [15:0] range[0:15];

//------------------------------------------
// Methods
//------------------------------------------
extern static function apb_agent_config get_config( uvm_component c );
// Standard UVM Methods:
extern function new(string name = "apb_agent_config");
extern task wait_for_reset();

endclass: apb_agent_config

function apb_agent_config::new(string name = "apb_agent_config");
  super.new(name);
endfunction

task apb_agent_config::wait_for_reset();
    mon_bfm.wait_for_reset();
endtask

//
// Function: get_config
//
// This method gets the my_config associated with component c. We check for
// the two kinds of error which may occur with this kind of
// operation.
//
function apb_agent_config apb_agent_config::get_config( uvm_component c );
  apb_agent_config t;

  if (!uvm_config_db#(apb_agent_config)::get(c, "", s_my_config_id, t) )
     `uvm_fatal("APB_AGENT_CONFIG", $sformatf("Cannot get() configuration %s \
        from uvm_config_db. Have you set() it?", s_my_config_id))

  return t;
endfunction
