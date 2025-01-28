package rx_jesd204b_layering_pkg;

import uvm_pkg::*;
import deserializer_agent_pkg::*;

`include "uvm_macros.svh"

`include "rx_jesd204b_layering_config.sv"

`include "decoder_8b10b_trans.sv"
`include "decoder_sequencer.sv"
`include "dec8b10b2des_seq.sv"
`include "deser2dec_monitor.sv"
`include "deser2dec_recorder.sv"

`include "cgsnfs_trans.sv"
`include "cgsnfs_sequencer.sv"
`include "cgsnfs2dec_seq.sv"
`include "cgsnfs_fsm.sv"
`include "dec2cgs_monitor.sv"
`include "dec2cgs_recorder.sv"

`include "erb_trans.sv"
`include "elastic_rx_buffer.svh"
`include "erb_sequencer.sv"
`include "erb2cgs_seq.sv"
`include "cgs2erb_monitor.sv"
`include "cgs2erb_recorder.sv"
`include "ila_info_extractor.svh"
`include "ila_extractor.sv"

`include "erb_seq.sv"

`include "ila_trans.sv"
`include "ila_fsm.sv"
`include "erb2ila_monitor.sv"
`include "erb2ila_recorder.sv"


`include "rx_jesd204b_layering.sv"
endpackage: rx_jesd204b_layering_pkg
