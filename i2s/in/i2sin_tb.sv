module i2sin_tb #(parameter BITS_PRECISION=24)();
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

   task write_bitstring(input [MSB:0] LBITS, input [MSB:0] RBITS,input out_of_reset);
      begin
	 ws <= 0;
	 if(!out_of_reset) #2;
	 for (i = MSB; i >= 0; i = i - 1) begin
	    sd <= LBITS[i];
	    #2;
	 end
	 ws <= 1;
	 for (i = MSB; i >= 0; i = i - 1) begin
	    #2;
	    sd <= RBITS[i];
	 end
      end
   endtask // write_bitstring

   initial begin
      $dumpfile("i2sin.vcd");
      $dumpvars(data_in,left_rightn,data_en);
      $dumpvars(0,in);
      
      rst <= 1;
      ws <= 0;
      #4;
      rst <= 0;
      write_bitstring(1,2 | (1 << MSB),1);
      #10;
      
      $finish();
      
   end

   i2sin #(.BITS_PRECISION(BITS_PRECISION)) in 
     (
      .sck(clk),
      .rst(rst),
      .ws(ws),
      .sd(sd),
      .data_in(data_in),
      .left_rightn(left_rightn),
      .data_en(data_en)
      );
endmodule // i2sin_tb
