module top;

import uvm_pkg::*;
import env_pkg::*;
import testcase_lib_pkg::*;

// clk and rst_n
//
logic clk;
// 312.5MHz
logic device_clk;
// 12.5GHz
logic agent_bitclk;
logic rst_n;

//
// Instantiate the pin interfaces:
//
deserializer_if u_deser_if(agent_bitclk, rst_n);
enc_bus_if u_enc_bus_if(clk, rst_n);

//
// Instantiate the BFM interfaces:
//
deserializer_monitor_bfm u_deser_mon_bfm(
    .clk(u_deser_if.clk),
    .rx_p(u_deser_if.rx_p),
    .rx_n(u_deser_if.rx_n)
);

enc_bus_driver_bfm u_enc_bus_drv_bfm(
    .clk(u_enc_bus_if.clk),
    .rst_n(u_enc_bus_if.rst_n),
    .data(u_enc_bus_if.data),
    .valid(u_enc_bus_if.valid),
    .k(u_enc_bus_if.k)
);

enc_bus_monitor_bfm u_enc_bus_mon_bfm(
    .clk(u_enc_bus_if.clk),
    .rst_n(u_enc_bus_if.rst_n),
    .data(u_enc_bus_if.data),
    .valid(u_enc_bus_if.valid),
    .k(u_enc_bus_if.k)
);

// DUT
tx_jesd204b DUT(
    .clk(clk),
    .rst_n(rst_n),
    .i_data(u_enc_bus_if.data),
    .i_vld(u_enc_bus_if.valid),
    .i_k(u_enc_bus_if.k),
    .o_tx_p(u_deser_if.rx_p),
    .o_tx_n(u_deser_if.rx_n)
);

// UVM initial block:
// Virtual interface wrapping & run_test()
initial begin
    import uvm_pkg::uvm_config_db;
    uvm_config_db#(virtual deserializer_monitor_bfm)::set(null, "uvm_test_top",
      "deserializer_monitor_bfm", u_deser_mon_bfm);


    uvm_config_db #(virtual enc_bus_monitor_bfm)::set(null, "uvm_test_top",
      "enc_bus_mon_bfm", u_enc_bus_mon_bfm);
    uvm_config_db #(virtual enc_bus_driver_bfm)::set(null, "uvm_test_top",
      "enc_bus_drv_bfm", u_enc_bus_drv_bfm);
    run_test();
end

//
// Clock and reset initial block:
//
initial begin
  // targeting at lane speed of 12.5Gbps
  // character clock frequency 1.25GHz
  // bit clock frequency 12.5GHz
  // device clock frequency 312.5MHz
  clk = 0;
  agent_bitclk = 0;
  device_clk = 0;
  forever #0.4ns clk = ~clk;
  forever #0.04ns agent_bitclk = ~agent_bitclk;
  forever #1.6ns device_clk = ~device_clk;
end
initial begin
  rst_n = 0;
  repeat(4) @(posedge clk);
  rst_n = 0;
  repeat(4) @(posedge clk);
  rst_n = 1;
end

initial begin
  $wlfdumpvars();
end

endmodule: top
