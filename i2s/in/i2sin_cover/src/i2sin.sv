module i2sin
  #(BITS_PRECISION=24)
   (
    input	   sck,
    input	   rst,
    input	   ws,
    input	   sd,
    output [MSB:0] data_in,
    output	   data_en
    );
   
    localparam MSB = BITS_PRECISION - 1;
endmodule // i2sin
