//
// BFM Interface Description:
//
//
interface decoder_8b10b_monitor_bfm (
  input clk,
  input rst_n,

  input logic [9:0] data,
  input k_error
);

`include "uvm_macros.svh"
import uvm_pkg::*;
import decoder_8b10b_agent_pkg::*;

//------------------------------------------
// Data Members
//------------------------------------------
decoder_8b10b_monitor proxy;

//------------------------------------------
// Component Members
//------------------------------------------

//------------------------------------------
// Methods
//------------------------------------------
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

endinterface: decoder_8b10b_monitor_bfm
