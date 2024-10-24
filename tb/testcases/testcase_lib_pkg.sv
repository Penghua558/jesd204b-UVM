package testcase_lib_pkg;

// Standard UVM import & include:
import uvm_pkg::*;
`include "uvm_macros.svh"

import env_pkg::*;
import enc_bus_agent_pkg::*;
import decoder_8b10b_agent_config::*;
import apb_bus_sequence_lib_pkg::*;
import test_seq_lib_pkg::*;

// testcases
`include "test_base.sv"
`include "test_reg.sv"
`include "test_randspd.sv"

endpackage: testcase_lib_pkg
