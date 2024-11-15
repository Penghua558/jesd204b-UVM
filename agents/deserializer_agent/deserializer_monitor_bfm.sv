//
// BFM Interface Description:
//
//
interface deserializer_monitor_bfm (
    input clk,

    // MSB is received first, that is, a is received frist
    input logic rx_p;
    input logic rx_n;
);

`include "uvm_macros.svh"
import uvm_pkg::*;
import deserializer_agent_pkg::*;

//------------------------------------------
// Data Members
//------------------------------------------
deserializer_monitor proxy;

//------------------------------------------
// Component Members
//------------------------------------------

//------------------------------------------
// Methods
//------------------------------------------

// BFM Methods:
task run();
    deserializer_trans item;
    deserializer_trans cloned_item;

    item = deserializer_trans::type_id::create("item");

    forever begin
        // Clone and publish the cloned item to the subscribers
        $cast(cloned_item, item.clone());
        proxy.notify_transaction(cloned_item);
    end
endtask: run

endinterface: deserializer_monitor_bfm
