interface deserializer_if(input bitclk, input rst_n);
logic rx_p;
logic rx_n;
logic sync_n;

// TODO add assertion to test sync_n's assertion length is always of multiple
// integer number times of frame clock period.

endinterface: deserializer_if
