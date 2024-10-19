`include "timescale.v"
`include "spi_defines.v"
`include "apb_completer.v"
`include "spi_clgen.v"
`include "spi_shift.v"
`include "spi_reg.v"
`include "cdc_handshaking.v"
`include "spi_initiator.v"

module spi_top#(
// divide input clock frequency by SCLK_DIVIDER*2
parameter [7:0] SCLK_DIVIDER = 8'd8,
parameter [11:0] SPI_TRANSMIT_DELAY = 12'd2001,
parameter [5:0] CS_N_HOLD_COUNT = 6'd3
)
(
    // clock frequency 100MHz
    input wire PCLK,
    input wire PRESETn,
    input wire PSEL,
    input wire PENABLE,
    input wire PWRITE,
    input wire [15:0] PADDR,
    input wire [15:0] PWDATA,

    output reg PREADY,
    output reg [15:0] PRDATA,

    // PMD901 signals
    // active HIGH, SPI violation, currently no use
    input wire fault,
    // active HIGH, PMD901 close to overheat, currently no use
    input wire fan,
    // active HIGH, PMD901 overheat, currently no use
    input wire ready,

    output wire park,
    output wire bending,

  // SPI signals
    output reg sclk,
    output reg cs_n,
    output reg mosi
);

parameter Tp = 1;
                                           
// Internal signals
wire sclk_gen_o; // SPI clock derived from module input clock
wire spi_ready; // asserted to indicate recent SPI transmit has completed
wire spi_ready_crossed; // signal of spi_ready crossed different clock domain
wire spi_start; // asserted to start a new SPI transmit
wire spi_start_crossed; // signal of spi_start crossed different clock domain
wire [15:0] motor_speed;
wire [15:0] reg_addr;
wire [15:0] reg_wdata;
wire [15:0] reg_rdata;
wire reg_wr;

spi_clgen clgen (
.clk_in(PCLK), 
.rst(!PRESETn),
.divider(SCLK_DIVIDER),
.clk_out(sclk_gen_o),
.pos_edge(pos_edge),
.neg_edge(neg_edge)
);

apb_completer#(
.ADDR_WIDTH(16),
.DATA_WIDTH(16)
) u_apb_completer(
// APB interface
.PCLK(PCLK),
.PRESETn(PRESETn),
.PSEL(PSEL),
.PENABLE(PENABLE),
.PWRITE(PWRITE),
.PADDR(PADDR),
.PWDATA(PWDATA),

.PREADY(PREADY),
.PRDATA(PRDATA),

// register module interface
.o_addr(reg_addr),
.o_wdata(reg_wdata),
.o_wr(reg_wr),
.i_rdata(reg_rdata)
);

spi_reg pmd901_reg(
.clk(PCLK),
.rstn(PRESETn),

.i_addr(reg_addr),
.i_wdata(reg_wdata),
.i_wr(reg_wr),
.o_rdata(reg_rdata),

.i_fan(fan),
.i_fault(fault),
.i_ready(ready),
.o_bending(bending),
.o_park(park),
.o_motor_speed(motor_speed)
);

spi_initiator #(
.SPI_TRANSMIT_DELAY(SPI_TRANSMIT_DELAY)
) transmit_initiator(
.clk(PCLK),
.rstn(PRESETn),
.spi_ready(spi_ready_crossed),
.spi_start(spi_start)
);

cdc_handshaking spi_start_crossing(
.old_clk(PCLK),
.data_in(spi_start),
.new_clk(sclk_gen_o),

.data_out(spi_start_crossed)
);

cdc_handshaking spi_ready_crossing(
.old_clk(sclk_gen_o),
.data_in(spi_ready),
.new_clk(PCLK),

.data_out(spi_ready_crossed)
);


spi_shift#(
.CS_N_HOLD_COUNT(CS_N_HOLD_COUNT)
) shift (
  .clk(sclk_gen_o), 
  .rst(!PRESETn),
  .spi_start(spi_start_crossed),
  .p_in(motor_speed),

  .miso(),
  .spi_ready(spi_ready),
  .s_clk(sclk), 
  .cs_n(cs_n),
  .mosi(mosi)
);
endmodule
