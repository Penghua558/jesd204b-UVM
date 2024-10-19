module spi_reg(
    input wire clk,
    input wire rstn,

    input wire [15:0] i_addr,
    input wire [15:0] i_wdata,
    input wire i_wr,
    output reg [15:0] o_rdata,

    input wire i_fan,
    input wire i_fault,
    input wire i_ready,
    output wire [15:0] o_motor_speed,
    output wire o_park,
    output wire o_bending
);

reg [15:0] addr_d;
reg [15:0] wdata_d;
reg wr_d;

reg [15:0] motor_speed;
reg park;
reg bending;
reg fan;
reg fault;
reg ready;

always@(posedge clk) begin
    fan <= i_fan;
    fault <= i_fault;
    ready <= i_ready;
end

assign o_motor_speed = motor_speed;
assign o_park = park;
assign o_bending = bending;

always@(posedge clk or negedge rstn) begin
    if (!rstn) begin
        o_rdata <= 16'd0;
        motor_speed <= 16'h100;
        park <= 1'b0;
        bending <= 1'b0;
    end else begin
        if (i_wr) begin
        // write operation
            case(i_addr)
                16'd0: motor_speed <= i_wdata;
                16'd2: park        <= i_wdata[0];
                16'd4: bending     <= i_wdata[0];
                default:;
            endcase
        end else begin
        // read operation
            case(i_addr)
                16'd0: o_rdata <= motor_speed;
                16'd2: o_rdata <= {15'd0, park};
                16'd4: o_rdata <= {15'd0, bending};
                16'd6: o_rdata <= {15'd0, fan};
                16'd8: o_rdata <= {15'd0, fault};
                16'd10: o_rdata <= {15'd0, ready};
                default: o_rdata <= 16'd0;
            endcase
        end
    end
end
endmodule
