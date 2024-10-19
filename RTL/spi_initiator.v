module spi_initiator#(
    parameter [11:0] SPI_TRANSMIT_DELAY = 12'd2001
)(
    // clock frequency 100MHz
    input wire clk,
    input wire rstn,
    input wire spi_ready,

    // asserted for 1 clock cycle
    output reg spi_start
);

reg [11:0] cnt4spi_start;

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        cnt4spi_start <= 12'd0;
    end else begin
        if (!cnt4spi_start && spi_ready) begin
            cnt4spi_start <= cnt4spi_start + 12'd1;
        end else begin
            if(cnt4spi_start && cnt4spi_start < SPI_TRANSMIT_DELAY) begin
                cnt4spi_start <= cnt4spi_start + 12'd1;
            end else if (cnt4spi_start == SPI_TRANSMIT_DELAY) begin
                cnt4spi_start <= 12'd0;
            end else begin
                cnt4spi_start <= cnt4spi_start;
            end
        end
    end
end

always @(posedge clk) begin
    if (cnt4spi_start == SPI_TRANSMIT_DELAY)
        spi_start <= 1'b1;
    else
        spi_start <= 1'b0;
end
endmodule
