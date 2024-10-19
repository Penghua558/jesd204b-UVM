module spi_clgen(clk_in, rst, divider, clk_out, pos_edge, neg_edge);
    parameter  Tp = 1;
  
  input clk_in;   // input clock (system clock)
  input rst;      // reset
  input [7:0] divider;  // clock divider (output clock is divided by this value)
  output clk_out;  // output clock
  output pos_edge; // pulse marking positive edge of clk_out
  output neg_edge; // pulse marking negative edge of clk_out

  reg clk_out;
  reg pos_edge;
  reg neg_edge;
                            
  reg [7:0] cnt; // clock counter
  wire cnt_zero; // conter is equal to zero
  wire cnt_one;  // conter is equal to one

  assign cnt_zero = cnt == 8'b0;
  assign cnt_one = cnt == {{7'b0, 1'b1}};
  
  // Counter counts half period
  always @(posedge clk_in or posedge rst)
  begin
    if(rst)
      cnt <= #Tp {8{1'b1}};
    else
      begin
        if(cnt_zero)
          cnt <= #Tp divider;
        else
          cnt <= #Tp cnt - {{7{1'b0}}, 1'b1};
      end
  end
  
  // clk_out is asserted every other half period
  always @(posedge clk_in or posedge rst)
  begin
    if(rst)
      clk_out <= #Tp 1'b0;
    else
      clk_out <= #Tp (cnt_zero) ? ~clk_out : clk_out;
  end
   
  // Pos and neg edge signals
  always @(posedge clk_in or posedge rst)
  begin
    if(rst)
      begin
        pos_edge  <= #Tp 1'b0;
        neg_edge  <= #Tp 1'b0;
      end
    else
      begin
        pos_edge  <= #Tp (!clk_out && cnt_one) ||
                        (!(|divider) && clk_out) ||
                        (!(|divider));
        neg_edge  <= #Tp (clk_out && cnt_one) || (!(|divider) && !clk_out);
      end
  end
endmodule
