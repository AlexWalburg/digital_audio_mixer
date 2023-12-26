module i2sinsinglechannel_tb #(parameter BITS_PRECISION=6)();
   localparam MSB = BITS_PRECISION-1;
   reg clk = 1;
   reg rst;
   reg ws;
   reg sd;
   wire [MSB:0]	data_in;
   wire		left_rightn;
   wire		data_en;
   integer	i;
   
   
   always #1 clk = ~clk;

   task write_bitstring(input [MSB:0] BITS);
      begin
	 ws <= 1;
	 for (i = MSB; i >= 0; i = i - 1) begin
	    sd <= BITS[i];
	    #2;
	 end
	 #2;
	 
	 ws <= 0;
      end
   endtask // write_bitstring

   initial begin
      $dumpfile("i2sinsinglechannel.vcd");
      $dumpvars(0,data_in,data_en);
      $dumpvars(0,in);
      
      rst <= 1;
      #4;
      rst <= 0;
      #2;
      write_bitstring(1);
      #2;
      write_bitstring(2);
      #10;
      $finish();
      
   end

   i2sinsinglechannel #(.BITS_PRECISION(BITS_PRECISION)) in 
     (
      .sck(clk),
      .rst(rst),
      .enable(ws),
      .sd(sd),
      .data_in(data_in),
      .data_en(data_en)
      );
   
   
endmodule; // i2sin_tb
