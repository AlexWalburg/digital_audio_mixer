module clock_div_tb();
   reg clk = 0;
   reg rst = 1;

   always #1 clk <= ~clk;
   wire clock_div;
   wire	clock_posedge;
   wire	clock_negedge;

   clock_div #(.log2clkdiv(3)) div
     (
      .rst(rst),
      .clk(clk),
      .div_clk(clock_div),
      .rising_edge(clock_posedge),
      .falling_edge(clock_negedge)
      );

   initial begin
      $dumpfile("clockdiv.vcd");
      $dumpvars(0,div);
      #1 rst <= 0;
      #32;
      $finish();
   end
endmodule; // clock_div_tb

      
		 
