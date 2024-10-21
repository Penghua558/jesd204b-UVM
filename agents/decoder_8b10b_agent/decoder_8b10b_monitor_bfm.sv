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
// running disparity
// 1 - RD+
// 0 - RD-
bit rd;

//------------------------------------------
// Component Members
//------------------------------------------

//------------------------------------------
// Methods
//------------------------------------------
task automatic wait_for_reset();
    @(posedge rst_n);
    rd = 1'b0;
    @(posedge clk);
endtask

// BFM Methods:
task run();
  decoder_8b10b_trans item;
  decoder_8b10b_trans cloned_item;

  item = decoder_8b10b_trans::type_id::create("item");

  forever begin
    @(posedge clk);
    item.k_not_valid_error = k_error;
    item.data = ;

    // Clone and publish the cloned item to the subscribers
    $cast(cloned_item, item.clone());
    proxy.notify_transaction(cloned_item);
  end
endtask: run

endinterface: decoder_8b10b_monitor_bfm
