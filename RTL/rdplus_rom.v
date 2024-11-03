module rdplus_rom(
    input wire clk,
    input wire rst_n,
    // HGFEDCBA, H is MSB, A is LSB
    input wire [7:0] i_addr,
    input wire i_rd_en,
    // 1 - this data is control word K
    // 0 - this data is data word D
    input wire i_k,
    // abcdeifghj
    output wire [9:0] o_out,
    // 1 - input control word is not found in table
    // 0 - no error
    output wire o_k_error
);

localparam K28_0 = 8'b000_11100;
localparam K28_1 = 8'b001_11100;
localparam K28_2 = 8'b010_11100;
localparam K28_3 = 8'b011_11100;
localparam K28_4 = 8'b100_11100;
localparam K28_5 = 8'b101_11100;
localparam K28_6 = 8'b110_11100;
localparam K28_7 = 8'b111_11100;
localparam K23_7 = 8'b111_10111;
localparam K27_7 = 8'b111_11011;
localparam K29_7 = 8'b111_11101;
localparam K30_7 = 8'b111_11110;

localparam K28_0_PLUS = 10'b110000_1011;
localparam K28_1_PLUS = 10'b110000_0110;
localparam K28_2_PLUS = 10'b110000_1010;
localparam K28_3_PLUS = 10'b110000_1100;
localparam K28_4_PLUS = 10'b110000_1101;
localparam K28_5_PLUS = 10'b110000_0101;
localparam K28_6_PLUS = 10'b110000_1001;
localparam K28_7_PLUS = 10'b110000_0111;
localparam K23_7_PLUS = 10'b000101_0111;
localparam K27_7_PLUS = 10'b001001_0111;
localparam K29_7_PLUS = 10'b010001_0111;
localparam K30_7_PLUS = 10'b100001_0111;

wire [9:0] d_out;
reg [9:0] k_out;
reg k_error;
reg i_k_d;

rom#(
.FILE("../RTL/D_RD_PLUS.mem"),
.READ_ADDR_WIDTH(8),
.WIDTH(10),
.DEPTH(256),
.RESET_OUTPUT(10'h18b)
) d_plus_rom(
.clk(clk),
.i_addr(i_addr),
.i_rd_en(i_rd_en),
.o_out(d_out)
);

always@(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        k_error <= 1'b0;
    end else begin
    case(i_addr)
        K28_0: begin
            k_out <= K28_0_PLUS;
            k_error <= 1'b0;
        end
        K28_1: begin
            k_out <= K28_1_PLUS;
            k_error <= 1'b0;
        end
        K28_2: begin
            k_out <= K28_2_PLUS;
            k_error <= 1'b0;
        end
        K28_3: begin
            k_out <= K28_3_PLUS;
            k_error <= 1'b0;
        end
        K28_4: begin
            k_out <= K28_4_PLUS;
            k_error <= 1'b0;
        end
        K28_5: begin
            k_out <= K28_5_PLUS;
            k_error <= 1'b0;
        end
        K28_6: begin
            k_out <= K28_6_PLUS;
            k_error <= 1'b0;
        end
        K28_7: begin
            k_out <= K28_7_PLUS;
            k_error <= 1'b0;
        end
        K23_7: begin
            k_out <= K23_7_PLUS;
            k_error <= 1'b0;
        end
        K27_7: begin
            k_out <= K27_7_PLUS;
            k_error <= 1'b0;
        end
        K29_7: begin
            k_out <= K29_7_PLUS;
            k_error <= 1'b0;
        end
        K30_7: begin
            k_out <= K30_7_PLUS;
            k_error <= 1'b0;
        end
        default: begin
            k_out <= 10'b0;
            k_error <= 1'b1;
        end
    endcase
    end
end

always @(posedge clk) begin
    i_k_d <= i_k;
end

assign o_out = (i_k_d)? k_out:d_out;
assign o_k_error = (i_k_d)? k_error:1'b0;
endmodule
