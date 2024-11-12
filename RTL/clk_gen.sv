// this module is to mimic PLL generating higher frequency clock than input
// clock
module clk_gen#(parameter half_period = 400ps) (
    output reg out_clk
);

initial begin
    out_clk = 0;
    forever #(half_period) out_clk = ~out_clk;
end
endmodule
