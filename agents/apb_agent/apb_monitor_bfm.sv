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
// BFM Interface Description:
//
//
interface apb_monitor_bfm (
  input PCLK,
  input PRESETn,

  input logic [15:0] PADDR,
  input logic [15:0] PRDATA,
  input logic [15:0] PWDATA,
  input logic [15:0] PSEL,    // Only connect the ones that are needed
  input logic PENABLE,
  input logic PWRITE,
  input logic PREADY
);

`include "uvm_macros.svh"
import uvm_pkg::*;
import apb_agent_pkg::*;

//------------------------------------------
// Data Members
//------------------------------------------
int apb_index = 0; // Which PSEL line is this monitor connected to
apb_monitor proxy;

//------------------------------------------
// Component Members
//------------------------------------------

//------------------------------------------
// Methods
//------------------------------------------
function void set_apb_index(int index);
    apb_index = index;
endfunction : set_apb_index

task automatic wait_for_reset();
    @(posedge PRESETn);
endtask

// BFM Methods:
task run();
  apb_trans item;
  apb_trans cloned_item;
  apb_agent_dec::op_e op;

  item = apb_trans::type_id::create("item");

  forever begin
    // Detect the protocol event on the TBAI virtual interface
    @(posedge PCLK);
    if(PREADY && PSEL[apb_index])
      // Assign the relevant values to the analysis item fields
      begin
        item.addr = PADDR;
        if(!$cast(op, PWRITE))
            `uvm_fatal("APB MONITOR BFM", "failed to convert PWRITE to op_e")
        item.wr = op;
        if(PWRITE) begin
            item.wdata = PWDATA;
            item.rdata = 16'd0;
        end else begin
            item.rdata = PRDATA;
            item.wdata = 16'd0;
        end
        // Clone and publish the cloned item to the subscribers
        $cast(cloned_item, item.clone());
        proxy.notify_transaction(cloned_item);
      end
  end
endtask: run

endinterface: apb_monitor_bfm
