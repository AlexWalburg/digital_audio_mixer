module volout_decision_maker
  #(parameter VOL_BITS = 24,
    parameter CPC_BITS = 15,
    parameter NUM_DECIMAL = 8)
  (
    input			 clk,
    input			 rst,
    input signed [VOL_BITS-1:0]	 vol,
    input			 cpc_en,
    input [CPC_BITS-1:0]	 cpc,
    output signed [VOL_BITS-1:0] vol_out);
    
    reg [CPC_BITS-1:0] cpc_int;
    
    assign vol_out = 
        (cpc_int >= 1 << (NUM_DECIMAL + 2)) ? vol >>> 1 :
        (cpc_int >= 1 << (NUM_DECIMAL - 1)) ? vol << 1 :
        (cpc_int >= 1 << (NUM_DECIMAL - 2)) ? vol << 2 :
        vol;
    
    always @(posedge clk or posedge rst) begin
       if (rst) begin
          cpc_int <= 0;
       end
       else begin
	  if(cpc_en)
            cpc_int <= cpc;
       end
    end
endmodule // volout_decision_maker
