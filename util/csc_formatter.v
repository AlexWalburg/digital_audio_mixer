module csc_formatter #(parameter NUM_INPUT_BITS = 24,
	 parameter NUM_OUTPUT_BITS = 15,
	 parameter NUM_DECIMAL_BITS = 6,
	 parameter NUM_SIGNALS = 4)
   (
    input				   clk,
    input				   rst,
    input [NUM_INPUT_BITS*NUM_SIGNALS-1:0] vol_data,
    input				   data_en,
    output [NUM_OUTPUT_BITS-1:0]	   csc_data,
    output				   csc_data_en
    );
   localparam						num_bits_extra = $clog2(NUM_SIGNALS);
   function [NUM_INPUT_BITS+NUM_BITS_EXTRA-1:0] sumAll(input [NUM_SIGNALS*NUM_INPUT_BITS-1:0] data);
      begin
	 integer i;
	 sumAll = vol_data[0+:NUM_INPUT_BITS];
	 for(i = 0; i < NUM_SIGNALS; i = i + 1)
	   sumAll = sumAll + vol_data;
      end
   endfunction // sumAll

   localparam	 sum_size = NUM_INPUT_BITS+NUM_BITS_EXTRA;
   assign csc_data_en = data_en;

   wire [sum_size-1:0] sum = sumAll(vol_data);
   
   assign csc_data {{(NUM_OUTPUT_BITS-NUM_DECIMAL_BITS){sum[sum_size-1]}},
		    sum[sum_size-1-:NUM_DECIMAL_BITS]};
   
endmodule // csc_formatter
   
   
		
