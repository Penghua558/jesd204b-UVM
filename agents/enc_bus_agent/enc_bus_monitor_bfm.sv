interface enc_bus_monitor_bfm (
    input clk,
    input rst_n,

    // HGFEDCBA
    input logic [7:0] data,
    input logic valid,
    input logic k
);

`include "uvm_macros.svh"
import uvm_pkg::*;
import enc_bus_agent_pkg::*;

//------------------------------------------
// Data Members
//------------------------------------------
enc_bus_monitor proxy;

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

endinterface: enc_bus_monitor_bfm
