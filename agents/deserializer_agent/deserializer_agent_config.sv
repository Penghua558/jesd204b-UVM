class deserializer_agent_config extends uvm_object;

localparam string s_my_config_id = "deserializer_agent_config";
localparam string s_no_config_id = "no config";
localparam string s_my_config_type_error_id = "config type error";

// UVM Factory Registration Macro
//
`uvm_object_utils(deserializer_agent_config)

// BFM Virtual Interfaces
virtual deserializer_monitor_bfm mon_bfm;

//------------------------------------------
// Data Members
//------------------------------------------
// Is the agent active or passive
uvm_active_passive_enum active = UVM_PASSIVE;
// Include the APB functional coverage monitor
bit has_functional_coverage = 0;
bit has_scoreboard = 0;

// maximum delay in clock cycles
int max_delay;
// number of clock cycles before starts sampling incoming serial line
rand int delay;

constraint delay_cons {
    delay inside {[0:max_delay]};
};
//------------------------------------------
// Methods
//------------------------------------------
extern static function deserializer_agent_config get_config( uvm_component c );
// Standard UVM Methods:
extern function new(string name = "deserializer_agent_config");
extern function void do_print(uvm_printer printer);

endclass: deserializer_agent_config

function deserializer_agent_config::new(string name = 
    "deserializer_agent_config");
  super.new(name);
endfunction

//
// Function: get_config
//
// This method gets the my_config associated with component c. We check for
// the two kinds of error which may occur with this kind of
// operation.
//
function deserializer_agent_config deserializer_agent_config::get_config( 
    uvm_component c );
  deserializer_agent_config t;

  if (!uvm_config_db#(deserializer_agent_config)::get(c, "", 
      s_my_config_id, t))
     `uvm_fatal("DESERIALIZER_AGENT_CONFIG", 
         $sformatf("Cannot get() configuration %s \
        from uvm_config_db. Have you set() it?", s_my_config_id))

  return t;
endfunction

function void deserializer_agent_config::do_print(uvm_printer printer);
    super.do_print(printer);
    printer.print_int("delay in clock cycles", delay, $bits(delay), UVM_DEC);
endfunction:do_print
