module rd_fsm(
    input wire clk,
    // reset makes running disparity as RD-
    input wire rst_n,
    input wire [9:0] i_data,
    // running disparity,
    // 1 - RD+
    // 0 - RD-
    output reg o_rd
);


    localparam [1:0] RD_MINUS = 2'b01;
    localparam [1:0] RD_PLUS = 2'b10;

    reg [1:0] next_state;
    reg [1:0] current_state;

  always@(posedge clk or negedge rst_n) begin
      if (rst_n) begin
          current_state <= RD_MINUS;
          o_rd <= 1'b0;
      end else begin
          current_state <= next_state;

          case(current_state)
              RD_MINUS: begin
                  o_rd <= 1'b0;
              end
              RD_PLUS: begin
                  o_rd <= 1'b1;
              end
              default: begin
                  o_rd <= 1'b0;
              end
          endcase
      end
  end

always@(*) begin
    case(current_state)
        RD_MINUS: begin
            if (^i_data)
                next_state = RD_MINUS;
            else
                next_state = RD_PLUS;
        end
        RD_PLUS: begin
            if (^i_data)
                next_state = RD_PLUS;
            else
                next_state = RD_MINUS;
        end
        default: next_state = RD_MINUS;
    endcase
end

endmodule
