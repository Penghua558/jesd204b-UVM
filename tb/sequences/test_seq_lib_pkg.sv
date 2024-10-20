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

package test_seq_lib_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

import pmd901_agent_pkg::*;
import env_pkg::*;
import apb_bus_sequence_lib_pkg::*;

`include "test_vseq_base.sv"
`include "test_reg_vseq.sv"
`include "test_randspd_vseq.sv"

endpackage:test_seq_lib_pkg
