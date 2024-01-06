module clock_div
  #(parameter log2clkdiv = 8)
   (
    input  clk,
    input  rst,
    output div_clk,
    output rising_edge,
    output falling_edge);
   localparam MSB = log2clkdiv - 1;
   reg [MSB:0] count_div;
   assign div_clk = count_div[MSB];
   wire	       some_transition = MSB >= 1 ? &(~count_div[MSB-1:0]) : 1; // all zeros
   assign rising_edge = count_div[MSB] & some_transition;
   assign falling_edge = ~count_div[MSB] & some_transition;

   always @(posedge clk or posedge rst) begin
      if(rst) begin
	      count_div <= 0;
      end
      else begin
	   count_div <= count_div + 1;
      end
   end
   				 
endmodule // clock_div
