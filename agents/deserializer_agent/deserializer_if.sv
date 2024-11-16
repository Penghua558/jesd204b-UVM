interface deserializer_if(input clk);
// clock signal's phase should delay half of period compared to transmitter's
// bit clock to mimic CDR

logic rx_p;
logic rx_n;

endinterface: deserializer_if
