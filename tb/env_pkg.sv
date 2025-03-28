//------------------------------------------------------------
//   Copyright 2010-2018 Mentor Graphics Corporation
//   All Rights Reserved Worldwide
//
//   Licensed under the Apache License, Version 2.0 (the
//   "License"); you may not use this file except in
//   compliance with the License.  You may obtain a copy of
//   the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in
//   writing, software distributed under the License is
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//   CONDITIONS OF ANY KIND, either express or implied.  See
//   the License for the specific language governing
//   permissions and limitations under the License.
//------------------------------------------------------------
//
// Package Description:
//
package env_pkg;

// Standard UVM import & include:
import uvm_pkg::*;
`include "uvm_macros.svh"

import enc_bus_agent_pkg::*;
// import decoder_8b10b_agent_pkg::*;
import rx_jesd204b_layering_pkg::*;
import table_8b10b_pkg::*;
// import spi_reg_pkg::*;

// Includes:
//`include "dec_predictor.sv"
//`include "dec_predictor_recorder.sv"
`include "inorder_comparator.sv"
//`include "enc_8b10b_scoreboard.sv"
`include "env_config.svh"
`include "env.svh"
endpackage: env_pkg
