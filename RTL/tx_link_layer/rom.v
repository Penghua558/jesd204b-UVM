module rom#(
parameter FILE = "", // file to initialize ROM, data should be in hexdecimal
parameter READ_ADDR_WIDTH = 8, // width of read address, unit in bit
parameter WIDTH = 8, // width of ROM, unit in bit
parameter DEPTH = 64, // depth of ROM
parameter RESET_OUTPUT = {WIDTH{1'b0}} // ROM output value upon reset
)(
    input wire clk,
    input wire [READ_ADDR_WIDTH-1:0] i_addr,
    // 1 - fetch data with current address
    // 0 - don't fetch data
    input wire i_rd_en,
    output reg [WIDTH-1:0] o_out
);

reg [WIDTH-1:0] data[0:DEPTH-1];

initial begin
    $readmemh(FILE, data);
    o_out <= RESET_OUTPUT;
end

always@(posedge clk) begin
    if (i_rd_en) begin
        if (i_addr < DEPTH) begin
            o_out <= data[i_addr];
        end else begin
            o_out <= {WIDTH{1'b0}};
        end
    end else begin
        o_out <= o_out;
    end
end

endmodule
