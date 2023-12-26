module i2sinsinglechannel
  #(parameter BITS_PRECISION=24)
   (
    input	   sck,
    input	   rst,
    input	   enable,
    input	   sd,
    // from perspective of higher level system, this module's data out is data in, so we call it data in
    output [MSB:0] data_in,
    output	   data_en
    );
   
   localparam	   MSB = BITS_PRECISION -1;
   reg		   last_enable;
   reg [BITS_PRECISION:0] frame_status;
   reg [MSB:0]		  data_out;
   assign data_in = data_out;
   assign data_en = (last_enable == 1) && (enable == 0) || frame_status[0]; // only active when resetting
   genvar	   i;
   

   
   always @(posedge sck or posedge rst) begin
      if(rst) begin
         frame_status <= 1 << BITS_PRECISION;
	 last_enable <= 0;
      end else begin
	 last_enable <= enable;
	 if(enable) begin
	    frame_status <= {1'b0,frame_status[BITS_PRECISION:1]};
	 end else begin
	    frame_status <= 1 << BITS_PRECISION;
	 end
      end
   end // always @ (posedge sck or posedge rst)
   generate
      for (i = 0; i < MSB + 1; i = i + 1) begin
	 always @(posedge sck or posedge rst)
	   if(rst)
	     data_out[i] <= 0;
	   else if (frame_status[i+1])
	     data_out[i] <= sd;   
      end
   endgenerate


   always @(posedge sck) begin
      if(~rst) begin
	 timeout_hi: assert ($past(enable,24) && data_en);
      end
   end
   
   
endmodule // i2sin
