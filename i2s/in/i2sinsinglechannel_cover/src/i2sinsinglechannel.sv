module i2sinsinglechannel
  #(parameter BITS_PRECISION=10)
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

   `ifdef FV
   reg has_reset = 0;
   reg enable_up = 1;
   
   always @(posedge sck) begin
      if(rst)
	has_reset <= 1;
   end
   always @(posedge sck) begin
      if(~rst && ~enable)
	enable_up <= 0;
   end
   always @(posedge sck) begin
	 
      if(has_reset && ~$past(rst)) begin
	 assume(rst==0);
	 senddata: cover((data_en==1) && (data_out == 55));
	 premature_interrupt: cover(($past(frame_status)!=1 && data_en==1));
	 
	 enable_change: assert (!($past(enable)&&~enable)||(data_en==1));
	 enable_timeout_change: assert(!(enableup && $past(enable,BITS_PRECISION)==1)||(data_en==1));
	 
      end
   end // always @ (posedge sck)
   `endif //  `ifdef FV
   
   
endmodule // i2sin
