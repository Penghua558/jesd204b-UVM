//
//------------------------------------------------------------------------------
//   Copyright 2018 Mentor Graphics Corporation
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
//------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------
//   Copyright 2018 Mentor Graphics Corporation
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
interface apb_if(input PCLK, input PRESETn);

logic[15:0] PADDR;
logic[15:0] PRDATA;
logic[15:0] PWDATA;
logic[15:0] PSEL; // Only connect the ones that are needed
logic PENABLE;
logic PWRITE;
logic PREADY;

`include "uvm_macros.svh"
import uvm_pkg::*;

property psel_valid;
    disable iff (!PRESETn == 1'b0)
    @(posedge PCLK) !$isunknown(PSEL);
endproperty: psel_valid

// PADDR should remain stable once PSEL is asserted
property paddr_stable;
    disable iff (!PRESETn)
    @(posedge PCLK) PSEL |=> ($stable(PADDR) until_with !PSEL);
endproperty

// PWRITE should remain stable once PSEL is asserted
property pwrite_stable;
    disable iff (!PRESETn)
    @(posedge PCLK) PSEL |=> ($stable(PWRITE) until_with !PSEL);
endproperty

// PWDATA should remain stable once PSEL is asserted
property pwdata_stable;
    disable iff (!PRESETn)
    @(posedge PCLK) PSEL |=> ($stable(PWDATA) until_with !PSEL);
endproperty

assert property (psel_valid)
else
    `uvm_fatal("APB IF", "PSEL should be valid when PRESETn is deasserted")

assert property (paddr_stable)
else
    `uvm_fatal("APB IF", "PADDR is not stable during transmission")

assert property (pwrite_stable)
else
    `uvm_fatal("APB IF", "PWRITE is not stable during transmission")

assert property (pwdata_stable)
else
    `uvm_fatal("APB IF", "PWDATA is not stable during transmission")

//CHK_PSEL: assert property(psel_valid);

//COVER_PSEL: cover property(psel_valid);

endinterface: apb_if
