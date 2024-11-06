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
task automatic wait_for_reset();
    @(posedge rst_n);
    @(posedge clk);
endtask

// BFM Methods:
task run();
    enc_bus_trans item;
    enc_bus_trans cloned_item;

    item = enc_bus_trans::type_id::create("item");

    wait_for_reset();

    forever begin
        @(posedge clk);
        item.data = data;
        item.valid = valid;
        item.control_word = k;
        // Clone and publish the cloned item to the subscribers
        $cast(cloned_item, item.clone());
        proxy.notify_transaction(cloned_item);
    end
endtask: run

endinterface: enc_bus_monitor_bfm
