class rx_jesd204b_layering_config extends uvm_object;

localparam string s_my_config_id = "rx_jesd204b_layering_config";
localparam string s_no_config_id = "no config";
localparam string s_my_config_type_error_id = "config type error";

// UVM Factory Registration Macro
//
`uvm_object_utils(rx_jesd204b_layering_config)

//------------------------------------------
// Data Members
//------------------------------------------
// Is the agent active or passive
uvm_active_passive_enum active = UVM_PASSIVE;
// Include the APB functional coverage monitor
bit has_functional_coverage = 0;
// Include the APB RAM based scoreboard
bit has_scoreboard = 0;

deserializer_agent_config m_deserializer_agent_cfg;

// number of octets per frame
rand int F;
// number of frames per multiframe
rand int K;
// 0 - disable scrambling
// 1 - enable scrambling
rand bit scrambling_enable;

//------------------------------------------
// Methods
//------------------------------------------
extern static function rx_jesd204b_layering_config get_config(uvm_component c);
// Standard UVM Methods:
extern function new(string name = "rx_jesd204b_layering_config");
extern function void do_print(uvm_printer printer);

endclass: rx_jesd204b_layering_config

function rx_jesd204b_layering_config::new(string name = 
    "rx_jesd204b_layering_config");
    super.new(name);
    m_deserializer_agent_cfg = deserializer_agent_config::type_id::
        create("m_deserializer_agent_cfg");
endfunction

//
// Function: get_config
//
// This method gets the my_config associated with component c. We check for
// the two kinds of error which may occur with this kind of
// operation.
//
function rx_jesd204b_layering_config rx_jesd204b_layering_config::get_config( 
    uvm_component c );
    rx_jesd204b_layering_config t;

    if (!uvm_config_db#(rx_jesd204b_layering_config)::get(c, "", 
      s_my_config_id, t))
        `uvm_fatal("RX_JESD204B_LAYERING_CONFIG", 
         $sformatf("Cannot get() configuration %s \
        from uvm_config_db. Have you set() it?", s_my_config_id))

  return t;
endfunction

function void rx_jesd204b_layering_config::do_print(uvm_printer printer);
    m_deserializer_agent_cfg.print();
    super.do_print(printer);
    printer.print_int("F", F, $bits(F), UVM_DEC);
    printer.print_int("K", K, $bits(K), UVM_DEC);
    printer.print_string("scrambling enable?", scrambling_enable? "Yes":"No");
endfunction:do_print
