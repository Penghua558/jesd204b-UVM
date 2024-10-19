module apb_completer#(
    parameter ADDR_WIDTH = 16,
    parameter DATA_WIDTH = 16
) (
    // APB interface
    input wire PCLK,
    input wire PRESETn,
    input wire PSEL,
    input wire PENABLE,
    input wire PWRITE,
    input wire [ADDR_WIDTH-1:0] PADDR,
    input wire [DATA_WIDTH-1:0] PWDATA,

    output reg PREADY,
    output reg [DATA_WIDTH-1:0] PRDATA,

    // register module interface
    output reg [ADDR_WIDTH-1:0] o_addr,
    output reg [DATA_WIDTH-1:0] o_wdata,
    // write/read enable, 0 means read, 1 means write
    output reg o_wr,
    input wire [DATA_WIDTH-1:0] i_rdata
);

localparam [2:0] IDLE = 3'b001;
localparam [2:0] SETUP = 3'b010;
localparam [2:0] ACCESS = 3'b100;

reg [2:0] current_state;
reg [2:0] next_state;

always@(posedge PCLK or negedge PRESETn) begin
    if(!PRESETn) begin
        current_state <= IDLE;
        PREADY <= 1'b0;
        PRDATA <= {DATA_WIDTH{1'b0}};

        o_wr <= 1'b0;
        o_addr <= {ADDR_WIDTH{1'b0}};
        o_wdata <= {DATA_WIDTH{1'b0}};
    end else begin
        current_state <= next_state;

        case(current_state)
            IDLE: begin
                PREADY <= 1'b0;
                PRDATA <= {DATA_WIDTH{1'b0}};

                o_wr <= 1'b0;
                o_addr <= PADDR;
                o_wdata <= {DATA_WIDTH{1'b0}};
            end
            SETUP: begin
                PREADY <= 1'b0;
                PRDATA <= {DATA_WIDTH{1'b0}};

                o_wr <= PWRITE;
                o_addr <= PADDR;
                if(PWRITE) begin
                    o_wdata <= PWDATA;
                    PRDATA <= {DATA_WIDTH{1'b0}};
                end else begin
                    PRDATA <= i_rdata;
                    o_wdata <= {DATA_WIDTH{1'b0}};
                end
            end
            ACCESS: begin
                PREADY <= 1'b1;

                o_wr <= PWRITE;
                o_addr <= PADDR;


                if(PWRITE) begin
                    o_wdata <= PWDATA;
                    PRDATA <= {DATA_WIDTH{1'b0}};
                end else begin
                    PRDATA <= i_rdata;
                    o_wdata <= {DATA_WIDTH{1'b0}};
                end
            end
            default: begin
                PREADY <= 1'b0;
                PRDATA <= {DATA_WIDTH{1'b0}};

                o_wr <= 1'b0;
                o_addr <= {ADDR_WIDTH{1'b0}};
                o_wdata <= {DATA_WIDTH{1'b0}};
            end
        endcase
    end
end

always@(*) begin
    case(current_state)
        IDLE: begin
            if(PSEL & !PENABLE)
                next_state = SETUP;
            else
                next_state = IDLE;
        end
        SETUP: begin
            next_state = ACCESS;
        end
        ACCESS: begin
            next_state = IDLE;
        end
        default: next_state = IDLE;
    endcase
end
endmodule
