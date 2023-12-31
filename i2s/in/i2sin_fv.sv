
module i2sin_fv_top // fv dummy top used to do fv assertions
  #(parameter BITS_PRECISION=4)
   (
    input	   sck,
    input	   rst,
    input	   ws,
    input	   sd,
    // from perspective of higher level system, this module's data out is data in, so we call it data in
    output [MSB:0] data_in,
    output	   left_rightn, 
    output	   data_en
    );
   localparam	   MSB = BITS_PRECISION - 1;
   
   i2sin #(.BITS_PRECISION(BITS_PRECISION)) dut_in(.*);

   reg reset_high = 0;
   always@(posedge sck) begin
      if(rst)
	reset_high <= 1;
   end


   function bit with_preq(preq,cond);
      with_preq = (!preq || cond);
   endfunction // with_preq

   function bit with_preq_post_reset(preq,cond);
      with_preq_post_reset = with_preq(preq && $past(reset_high) && !$past(rst),cond);
   endfunction // with_preq_post_reset

   function bit stable_range(signal,starttime,endtime);
      stable_range = 1;
      for(integer i = starttime; i < endtime;i = i + 1) begin
	 stable_range = stable_range && $stable(signal,times[i]);
      end
   endfunction // stable_range
   

   
   always@(negedge sck) begin
      no_post_reset_zero_len_frames: assume(with_preq($past(rst),$stable(ws)) && with_preq($past(rst,2),$stable(ws)));
      
      no_zero_len_frames: assume(with_preq(!$stable($past(ws)),$stable(ws)));
      // for whatever reason assumes ignore their state in yosys, so we have to assume reset_high or our asserts become vacuous by this assumption.
      no_more_resets: assume(with_preq(reset_high, !$rose(rst)));
      if(~rst && reset_high) begin

	 
	 correct_lr: assert(with_preq(data_en,left_rightn==$past(ws)));
	 transition_asserts_data_en: assert(
					    with_preq_post_reset(!$stable(ws) && $past(rst,2) == 0 && $past(data_en) == 0,data_en));
	 //timeout_creates_data_en: assert(with_preq($past(rst,100)==0,data_en));
	 
	 
	 good_0th_bit: cover(data_en && data_in[0] && $onehot(data_in) && $stable($past(ws)));
	 good_1th_bit: cover(data_en && data_in[1] && $onehot(data_in)&& $stable($past(ws)));
	 good_2nd_bit: cover(data_en && data_in[2] && $onehot(data_in)&& $stable($past(ws)));
	 good_3rd_bit: cover(data_en && data_in[3] && $onehot(data_in)&& $stable($past(ws)));
	 ws_flip_flop: cover($past(reset_high,3) && $past(ws,2) && !$past(ws) && data_en);
	 
      end
   end

endmodule // i2sin_fv_top
