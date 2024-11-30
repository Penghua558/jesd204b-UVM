//
// BFM Interface Description:
//
interface deserializer_driver_bfm (
    input bitclk,
    input rst_n,

    // MSB is received first, that is, a is received frist
    input logic rx_p,
    input logic rx_n,
    // SYNC~
    output logic sync_n
);

`include "uvm_macros.svh"
import uvm_pkg::*;
import deserializer_agent_dec::*;
import deserializer_agent_pkg::*;

//------------------------------------------
// Data Members
//------------------------------------------
deserializer_agent_config m_cfg;


//------------------------------------------
// Component Members
//------------------------------------------

//------------------------------------------
// Methods
//------------------------------------------
task automatic reset();
    while (!rst_n) begin
        sync_n <= 1'b1;
        @(posedge bitclk);
    end
endtask

// BFM Methods:
task drive(deserializer_trans req);
    // though JESD204B launches sync_n via frame clock, it is an agent here as
    // we can not have timing information in other higher agent layerings, so 
    // frame clock can only be constructed in this agent which would leads to
    // more nasty problems.
    sync_n <= req.sync_n;
    repeat(10) begin
        @(posedge bitclk);
    end
endtask: drive 

endinterface: deserializer_driver_bfm
