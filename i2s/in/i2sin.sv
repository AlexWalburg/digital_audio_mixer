module i2sin
  #(parameter BITS_PRECISION=24)
   (
    input	   sck,
    input	   rst,
    input	   ws,
    input	   sd,
    // from perspective of higher level system, this module's data out is data in, so we call it data in
    output [MSB:0] data_in,
    output	   left_rightn, 
    output reg	   data_en
    );
   localparam MSB = BITS_PRECISION - 1;
   
   reg	[MSB:0]	   data;
	   
   reg		   reading;		   

   reg [MSB:0]	   frame_status;
   reg		   last_ws;

   wire		   ws_transition = last_ws != ws;
   wire		   last_bit = frame_status[0] || ws_transition;
   assign left_rightn = last_ws;
   assign data_in = data;
   

   task do_reset();
      begin
	 reading <= 1;
	 frame_status <= 1 << MSB;
	 last_ws <= ws;
	 data_en <= 0;
	 
      end
   endtask // do_reset
   
   task do_idle(); // does state management for writes
      begin
	 frame_status <= 1 << MSB;
	 reading <= ws_transition;
	 data_en <= 0;
      end
   endtask // do_idle

   task do_read(); // does state management for reads
      begin
	 frame_status <= {1'b0,frame_status[MSB:1]};
	 data_en <= last_bit;
	 reading <= ~last_bit;
      end
   endtask // do_read
   
   always@(negedge sck or posedge rst) begin
      if(rst)
	do_reset();
      else begin
	 last_ws <= ws;
	 if (reading)
	   do_read();
	 else
	   do_idle();
      end
   end
   genvar i;
   
   generate
      for (i = 0; i < MSB + 1; i = i + 1) begin
	 always @(negedge sck or posedge rst)
	   if(rst)
	     data[i] <= 0;
	   else if(i != MSB && frame_status[MSB]) //do reset if we have restarted reading, which would drive frame_status[MSB] high
	     data[i] <= 0;
	   else if (frame_status[i])
	     data[i] <= sd;
      end
   endgenerate

endmodule // i2sin
