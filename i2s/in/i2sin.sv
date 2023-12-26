module i2sin
  #(parameter BITS_PRECISION=24)
   (
    input	       sck,
    input	       rst,
    input	       ws,
    input	       sd,
    // from perspective of higher level system, this module's data out is data in, so we call it data in
    output reg [MSB:0] data_in,
    output reg	       left_rightn, 
    output reg	       data_en
    );
   localparam MSB = BITS_PRECISION - 1;
   
   wire	[MSB:0]	   right_data;
   wire		   right_data_en;
		   
   wire	[MSB:0]	   left_data;
   wire		   left_data_en;


   // somewhat overspecified case statement for output muxxing, essentially prefers left over right
   always @(left_data_en,right_data_en) begin
      case({left_data_en,right_data_en})
	2'b10: begin
	   data_en = left_data_en;
	   data_in = left_data;
	   left_rightn = 1;
	   $display("This should really be happening rn");
	   
	end
	2'b01: begin
	   data_en = right_data_en;
	   data_in = right_data;
	   left_rightn = 0;
	   $display("This should happen after the other one");
	   
	end
	2'b00: begin
	   data_en = 0;
	   data_in  =0;
	   left_rightn = 0;
	   
	end
      endcase
   end // always @ (left_data_en,right_data_en)

   // wire up two single channel setups
   i2sinsinglechannel #(.BITS_PRECISION(BITS_PRECISION)) left_channel
     (
      .sck(sck),
      .rst(rst),
      .enable(~ws),
      .sd(sd),
      .data_in(left_data),
      .data_en(left_data_en)
      );

   i2sinsinglechannel #(.BITS_PRECISION(BITS_PRECISION)) right_channel
     (
      .sck(sck),
      .rst(rst),
      .enable(ws),
      .sd(sd),
      .data_in(right_data),
      .data_en(right_data_en)
      );
   
   
endmodule // i2sin
