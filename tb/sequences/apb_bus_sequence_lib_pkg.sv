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
// This package contains the sequences targetting the bus
// interface of the SPI block - Not all are used by the test cases
//
// It uses the UVM register model
//
package apb_bus_sequence_lib_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

import env_pkg::*;
import spi_reg_pkg::*;

`include "apb_bus_sequence_base.sv"
`include "rand_speed_sequence.sv"
`include "rand_control_sequence.sv"
`include "enable_pmd901_sequence.sv"

endpackage: apb_bus_sequence_lib_pkg
