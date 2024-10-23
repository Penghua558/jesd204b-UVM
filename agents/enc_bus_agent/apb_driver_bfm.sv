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
interface apb_driver_bfm (
  input         PCLK,
  input         PRESETn,

  output logic [15:0] PADDR,
  input  logic [15:0] PRDATA,
  output logic [15:0] PWDATA,
  output logic [15:0] PSEL, // Only connect the ones that are needed
  output logic PENABLE,
  output logic PWRITE,
  input  logic PREADY
);

`include "uvm_macros.svh"
import uvm_pkg::*;
import apb_agent_pkg::*;

//------------------------------------------
// Data Members
//------------------------------------------
int apb_index = 0;
apb_agent_config m_cfg;
//------------------------------------------
// Methods
//------------------------------------------

task automatic reset();
    while (!PRESETn) begin
        PADDR <= 16'd0;
        PWDATA <= 16'd0;
        PSEL <= 16'd0;
        PENABLE <= 1'b0;
        PWRITE <= 1'b0;
        @(posedge PCLK);
    end
endtask

function void set_apb_index(int index);
    apb_index = index;
endfunction: set_apb_index

function bit is_addr_legal(logic [15:0] address);
    if (address >= m_cfg.start_address[apb_index] &&
        address <= m_cfg.start_address[apb_index] + m_cfg.range[apb_index])
        return 1;
    else
        return 0;
endfunction

task drive(apb_trans req);
    int apb_index;

    repeat(req.delay)
        @(posedge PCLK);
    if (is_addr_legal(req.addr)) begin
        PSEL[apb_index] <= 1'b1;
        PADDR <= req.addr;
        PWDATA <= req.wdata;
        PWRITE <= req.wr;
        @(posedge PCLK);
        PENABLE <= 1'b1;
        while (!PREADY)
            @(posedge PCLK);
        if(PWRITE == 0)
            req.rdata = PRDATA;
        @(posedge PCLK);
        PSEL[apb_index] <= 1'b0;
        PENABLE <= 1'b0;
    end else begin
        `uvm_error("APB DRIVER", 
            $sformatf("Access to addr %0h out of APB address range", req.addr))
    end
endtask: drive

endinterface: apb_driver_bfm
