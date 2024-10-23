module top;

import uvm_pkg::*;
import env_pkg::*;
import testcase_lib_pkg::*;

// PCLK and PRESETn
//
logic PCLK;
logic PRESETn;

//
// Instantiate the pin interfaces:
//
pmd901_if u_pmd901_if();
apb_if u_apb_if(PCLK, PRESETn);

//
// Instantiate the BFM interfaces:
//
pmd901_driver_bfm u_pmd901_drv_bfm(
    .clk(u_pmd901_if.clk),
    .csn(u_pmd901_if.csn),
    .bend(u_pmd901_if.bend),
    .park(u_pmd901_if.park),
    .mosi(u_pmd901_if.mosi),
    .fault(u_pmd901_if.fault),
    .fan(u_pmd901_if.fan),
    .ready(u_pmd901_if.ready)
);

pmd901_monitor_bfm u_pmd901_mon_bfm(
    .clk(u_pmd901_if.clk),
    .csn(u_pmd901_if.csn),
    .bend(u_pmd901_if.bend),
    .park(u_pmd901_if.park),
    .mosi(u_pmd901_if.mosi),
    .fault(u_pmd901_if.fault),
    .fan(u_pmd901_if.fan),
    .ready(u_pmd901_if.ready)
);

apb_driver_bfm u_apb_driver_bfm(
    .PCLK(u_apb_if.PCLK),
    .PRESETn(u_apb_if.PRESETn),
    .PADDR(u_apb_if.PADDR),
    .PRDATA(u_apb_if.PRDATA),
    .PWDATA(u_apb_if.PWDATA),
    .PSEL(u_apb_if.PSEL),
    .PENABLE(u_apb_if.PENABLE),
    .PWRITE(u_apb_if.PWRITE),
    .PREADY(u_apb_if.PREADY)
);

apb_monitor_bfm u_apb_monitor_bfm(
    .PCLK(u_apb_if.PCLK),
    .PRESETn(u_apb_if.PRESETn),
    .PADDR(u_apb_if.PADDR),
    .PRDATA(u_apb_if.PRDATA),
    .PWDATA(u_apb_if.PWDATA),
    .PSEL(u_apb_if.PSEL),
    .PENABLE(u_apb_if.PENABLE),
    .PWRITE(u_apb_if.PWRITE),
    .PREADY(u_apb_if.PREADY)
);

// DUT
spi_top#(
.SCLK_DIVIDER(8'd8),
.SPI_TRANSMIT_DELAY(12'd2001),
.CS_N_HOLD_COUNT(6'd3)
) DUT(
    .PCLK(PCLK),
    .PRESETn(PRESETn),
    .PSEL(u_apb_if.PSEL[0]),
    .PENABLE(u_apb_if.PENABLE),
    .PWRITE(u_apb_if.PWRITE),
    .PADDR(u_apb_if.PADDR),
    .PWDATA(u_apb_if.PWDATA),
    .PREADY(u_apb_if.PREADY),
    .PRDATA(u_apb_if.PRDATA),

    .fault(u_pmd901_if.fault),
    .fan(u_pmd901_if.fan),
    .ready(u_pmd901_if.ready),
    .park(u_pmd901_if.park),
    .bending(u_pmd901_if.bend),
    .sclk(u_pmd901_if.clk),
    .cs_n(u_pmd901_if.csn),
    .mosi(u_pmd901_if.mosi)
);


// UVM initial block:
// Virtual interface wrapping & run_test()
initial begin
  import uvm_pkg::uvm_config_db;
  uvm_config_db#(virtual pmd901_monitor_bfm)::set(null, "uvm_test_top",
      "PMD901_mon_bfm", u_pmd901_mon_bfm);
  uvm_config_db#(virtual pmd901_driver_bfm)::set(null, "uvm_test_top",
      "PMD901_drv_bfm", u_pmd901_drv_bfm);

  uvm_config_db #(virtual apb_monitor_bfm)::set(null, "uvm_test_top",
      "u_apb_monitor_bfm", u_apb_monitor_bfm);
  uvm_config_db #(virtual apb_driver_bfm)::set(null, "uvm_test_top",
      "u_apb_driver_bfm", u_apb_driver_bfm);
  run_test();
end

//
// Clock and reset initial block:
//
initial begin
  PCLK = 0;
  forever #10ns PCLK = ~PCLK;
end
initial begin
  PRESETn = 0;
  repeat(4) @(posedge PCLK);
  PRESETn = 0;
  repeat(4) @(posedge PCLK);
  PRESETn = 1;
end

initial begin
  $wlfdumpvars();
end

endmodule: top
