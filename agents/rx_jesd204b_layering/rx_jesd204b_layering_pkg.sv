package rx_jesd204b_layering_pkg;

import uvm_pkg::*;
import deserializer_agent_pkg::*;

`include "uvm_macros.svh"
`include "decoder_8b10b_trans.sv"
`include "rx_jesd204b_layering_config.sv"

`include "deser2dec_monitor.sv"

`include "deser2dec_recorder.sv"

`include "rx_jesd204b_layering.sv"
endpackage: rx_jesd204b_layering_pkg
