let min(a, b) = (a <= b)? a:b;

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

ila_info_extractor m_ila_info_extractor;
deserializer_agent_config m_deserializer_agent_cfg;

// LMFC phase adjustment related variables, only used in ila_fsm and 
// erb2ila_monitor
// 1 - erb2ila_monitor should start adjusting LMFC, set by ila_fsm
// 0 - erb2ila_monitor should not adjust LMFC, set by erb2ila_monitor
bit lmfc_adj_start;
bit PHADJ;
bit[3:0] ADJCNT;
bit ADJDIR;

// number of octets per frame
rand int F;
// number of frames per multiframe
rand int K;
// 0 - disable scrambling
// 1 - enable scrambling
rand bit scrambling_enable;
// RX Buffer Delay, unit is frame
// used to describe when Elastic RX Buffer is released
rand int RBD;
// size of Elastic RX Buffer in units of frames
// size should be greater or equal to RBD
rand int erb_size;

constraint dac_para_cons {
    F >= 1;
    F <= 256;

    K >= $ceil(17.0/F);
    K <= (min(32, 1024/F));

    // a multiframe's period must be larger than maximum possible link delay
    // the inequality is only valid for 12.5Gbps link operation
    0.8*K*F > 3.28 + 1.6*F;

    RBD >= 1;
    RBD <= K;

    // Elastic RX Buffer's release delay must be greater than maximum possible
    // link delay, the inequality is only valid for 12.5Gbps link operation
    0.8*RBD*F > 3.28 + 1.6*F;

    erb_size >= RBD;
    erb_size <= 33;

    solve F before K;
    solve K before RBD;
    solve RBD before erb_size;
};

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
    lmfc_adj_start = 1'b0;
    m_ila_info_extractor = new();
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
    printer.print_int("RBD", RBD, $bits(RBD), UVM_DEC);
    printer.print_int("ERB size in frames", erb_size, $bits(erb_size), UVM_DEC);
endfunction:do_print
