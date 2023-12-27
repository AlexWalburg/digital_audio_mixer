module i2out_tb #(parameter BITS_PRECISION=24)();
   localparam MSB = BITS_PRECISION-1;
   reg	      clk = 1;
   reg	      rst;
   reg [MSB:0] l_data;
   reg [MSB:0] r_data;
   reg	       data_en;
   wire	       ws;
   wire	       sd;
   
   integer	i;

   wire		in_data_en;
   wire		left_rightn;
   wire [MSB:0]	in_data;
   
   
   
   always #1 clk = ~clk;

   task write_bitstring(input [MSB:0] LBITS, input [MSB:0] RBITS);
      begin
	 l_data <= LBITS;
	 r_data <= RBITS;
	 data_en <= 1;
	 #2;
	 //data_en <= 0;
	 
      end
   endtask // write_bitstring

   initial begin
      $dumpfile("i2sout.vcd");
      $dumpvars(0,out);
      $dumpvars(0,in);
      
      
      rst <= 1;
      write_bitstring(1,2);
      #5;
      rst <= 0;
      write_bitstring(1<<MSB,1<<MSB);
      #220;
      
      $finish();
      
   end

   i2sout #(.BITS_PRECISION(BITS_PRECISION)) out
     (
      .sck(clk),
      .rst(rst),
      .l_data(l_data),
      .r_data(r_data),
      .data_en(data_en),
      .ws(ws),
      .sd(sd)
      );

   i2sin #(.BITS_PRECISION(BITS_PRECISION)) in
     (.sck(clk),
      .rst(rst),
      .ws(ws),
      .sd(sd),
      .data_in(in_data),
      .data_en(in_data_en),
      .left_rightn(left_rightn));
   
   
endmodule // i2out_tb

