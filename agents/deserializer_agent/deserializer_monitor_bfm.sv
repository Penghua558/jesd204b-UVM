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
import deserializer_agent_dec::*;
import deserializer_agent_pkg::*;

//------------------------------------------
// Data Members
//------------------------------------------
deserializer_monitor proxy;
deserializer_agent_config m_cfg;


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

    // to mimic the time it takes CDR to recover bit clock, so sampling start
    // point is not at the boundary of a valid 8b10b character
    repeat(m_cfg.delay) @(posedge clk);

    forever begin
        // construct 8b10b character from serial line
        repeat(10) begin
            @(posedge clk);
            item.data = item.data << 1;
            item.data[0] = rx_p;
        end
        // detect & synchronize with K28.5

        // Clone and publish the cloned item to the subscribers
        $cast(cloned_item, item.clone());
        proxy.notify_transaction(cloned_item);
    end
endtask: run

endinterface: deserializer_monitor_bfm
