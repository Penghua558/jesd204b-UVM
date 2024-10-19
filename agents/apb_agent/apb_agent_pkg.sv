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
package apb_agent_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "apb_trans.sv"
`include "apb_agent_config.sv"

`include "apb_monitor.sv"
`include "apb_driver.sv"
`include "apb_sequencer.sv"
`include "apb_recorder.sv"

`include "reg2apb_adapter.sv"
`include "apb_agent.sv"

`include "apb_sequences/apb_read_sequence.sv"
`include "apb_sequences/apb_write_sequence.sv"
`include "apb_sequences/apb_rand_write_sequence.sv"
`include "apb_sequences/apb_rand_read_sequence.sv"
`include "apb_sequences/apb_rand_sequence.sv"
endpackage: apb_agent_pkg
