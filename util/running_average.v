module running_average #(parameter NUM_BITS=32,
			 parameter NUM_BITS_OUT=64,
			 parameter QUEUE_DEPTH=64)
  (
   input			 clk,
   input			 rst,
   input			 data_en,
   input [NUM_BITS-1:0]		 data_in,
   output reg [NUM_BITS_OUT-1:0] data_out,
   output reg			 data_en_out);

   localparam			 NUM_COUNTER_BITS = $clog2(QUEUE_DEPTH);
   
   reg [NUM_COUNTER_BITS:0]	 num_entries;

   wire				 counter_done;
   wire signed [NUM_BITS-1:0]	 data_in_sgn;
   data_in_sgn = data_in;
   assign counter_done = num_entries == QUEUE_DEPTH;

   reg [QUEUE_DEPTH*NUM_BITS-1:0] queue;
   
   wire signed [NUM_BITS-1:0]		 last_entry;
   assign last_entry = queue[(QUEUE_DEPTH-1)*NUM_BITS+:NUM_BITS];

   task do_reset();
      data_out <= 0;
      data_en_out <= 0;
      queue <= 0;
      num_entries <= 0;
   endtask // do_reset

   integer i;
   always @(posedge clk or posedge rst) begin
      if(rst)
	do_reset();
      else begin
	 num_entries <= num_entries + 1;
	 data_out <= data_out + data_in_sgn - last_entry;
	 data_out_en <= counter_done && data_en;
	 queue[0+:NUM_BITS] <= data_in;
	 for(i = 1; i < QUEUE_DEPTH; i = i + 1)
	   queue[i*NUM_BITS+:NUM_BITS] <= queue[(i-1)*NUM_BITS+:NUM_BITS];
      end
   end // always @ (posedge clk or posedge rst)	 
endmodule // running_average

   
