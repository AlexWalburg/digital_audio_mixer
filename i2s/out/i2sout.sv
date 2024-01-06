module i2sout
  #(parameter BITS_PRECISION = 24,
    parameter WS_DIV_SCLK = 64)
   (
    input	  clk,
    input	  sck_posedge, 
    input	  rst,
    input [MSB:0] l_data,
    input [MSB:0] r_data,
    input	  data_en,
    output	  ws,
    output	  sd,
    output	  data_entered
    );
   localparam MSB = BITS_PRECISION - 1;
   localparam NUM_PAUSE_BITS = WS_DIV_SCLK - BITS_PRECISION;
   localparam FRAME_STATE_MSB = WS_DIV_SCLK - 1;
   localparam IDLE = 0;
   localparam WRITE_L = 1;
   localparam WRITE_R = 2;

   reg [MSB:0] l_data_cpy;
   reg [MSB:0] r_data_cpy;
   wire [MSB:0]	current_data;
   reg [FRAME_STATE_MSB:0] frame_state;
   reg [1:0]   state;
   reg	       sd_int;
   assign data_entered = frame_state[FRAME_STATE_MSB] && (state == WRITE_L);

   wire	       should_read_next = frame_state[0];
   assign ws = state[1];
   assign current_data = state[1] ? r_data_cpy : l_data_cpy;
   assign sd = sd_int;
   always@(posedge clk) begin
      if(rst)
	   sd_int <= 0;
      else if(sck_posedge)
	   sd_int <= |((frame_state >> NUM_PAUSE_BITS) & current_data);
   end

   task do_reset();
      begin
	 l_data_cpy <= data_en == 1 ? l_data : 0;
	 r_data_cpy <= data_en == 1 ? r_data : 0;
	 state <= data_en ==1 ? WRITE_L : IDLE;
	 frame_state <= 1 << FRAME_STATE_MSB;
      end
   endtask // do_reset

   task do_idle();
      begin
	 if(data_en) begin
	    l_data_cpy <= l_data;
	    r_data_cpy <= r_data;
	    state <= WRITE_L;
	 end 
	 frame_state <= 1 << FRAME_STATE_MSB;
      end
   endtask // do_idle

   task do_left();
      if(sck_posedge) begin
	 if(should_read_next) begin
	    state <= WRITE_R;
	 end
	 frame_state <= {frame_state[0],frame_state[FRAME_STATE_MSB:1]};
      end
   endtask // do_left

   task do_right();
      if(sck_posedge) begin
	 if(should_read_next) begin
	    if(data_en) begin
	       do_idle();
	    end
	    else begin
	       state <= IDLE;
	       l_data_cpy <= 0;
	       r_data_cpy <= 0;
	    end
	 end else
	   frame_state <= {frame_state[0],frame_state[FRAME_STATE_MSB:1]};
      end
   endtask // do_right
   
   
   always @(posedge clk) begin
      if(rst)
	   do_reset();
      else begin
	 case (state)
	   IDLE: do_idle();
	   WRITE_L: do_left();
	   WRITE_R: do_right();
	 endcase; // case (state)
      end
   end
endmodule // i2sout

   
 
