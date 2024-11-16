package rx_jesd204b_layering_pkg;

import uvm_pkg::*;
import deserializer_agent_pkg::*;

`include "uvm_macros.svh"
`include "decoder_8b10b_trans.sv"

`include "deser2dec_monitor.sv"

`include "decoder_8b10b_agent_config.sv"

`include "decoder_8b10b_recorder.sv"

`include "decoder_8b10b_agent.sv"
endpackage: rx_jesd204b_layering_pkg
