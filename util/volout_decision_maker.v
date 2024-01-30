module volout_decision_maker
  #(parameter VOL_BITS = 23,
    parameter CPC_BITS = 15,
    parameter NUM_DECIMAL = 8)
  (input signed [VOL_BITS-1:0] vol,
   input			cpc_en,
   input [CPC_BITS-1:0]		cpc,
   output signed [VOL_BITS-1:0]	vol_out);

   always #* begin
      if (cpc_en)begin
	 if(CPC >= 2 << NUM_DECIMAL)
	   vol_out = vol >>> 1;
	 else if(CPC <= 1 << (NUM_DECIMAL-1))
	   vol_out = vol << 1;
	 else if(CPC <= 1 << (NUM_DECIMAL-2))
	   vol_out = vol << 2;
	 else
	   vol_out <= vol;
      end
      else
	vol_out <= vol;
   end
endmodule // volout_decision_maker
