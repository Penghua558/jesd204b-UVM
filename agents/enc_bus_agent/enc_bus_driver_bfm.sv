//
// BFM Interface Description:
//
//
interface enc_bus_driver_bfm (
  input clk,
  input rst_n,

  output logic [7:0] data,
  output logic valid,
  output logic k
);

`include "uvm_macros.svh"
import uvm_pkg::*;
import enc_bus_agent_pkg::*;

//------------------------------------------
// Data Members
//------------------------------------------
enc_bus_agent_config m_cfg;
//------------------------------------------
// Methods
//------------------------------------------

task automatic reset();
    while (!rst_n) begin
        data <= 8'd0;
        valid <= 1'b0;
        k <= 1'b0;
        @(posedge clk);
    end
endtask

task drive(enc_bus_trans req);
    data <= req.data;
    valid <= req.valid;
    k <= req.control_word;
    @(posedge clk);
endtask: drive

endinterface: enc_bus_driver_bfm
