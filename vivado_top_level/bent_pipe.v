`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Walburg Industries
// Engineer: Alex Walburg
// 
// Create Date: 12/26/2023 07:07:42 PM
// Design Name: Digital_audio_amp
// Module Name: bent_pipe
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module bent_pipe #(parameter MAX_DEV=1) (
    input clk,
    input rstn,
    output [MAX_DEV:0] tx_mclk, // JX[0]
    output [MAX_DEV:0] tx_lrck, // JX[1]
    output [MAX_DEV:0] tx_sclk, // JX[2]
    output [MAX_DEV:0] tx_sdout, // JX[3]
    output [MAX_DEV:0] rx_mclk, // JX[4]
    output [MAX_DEV:0] rx_lrck, // JX[5]
    output [MAX_DEV:0] rx_sclk, // JX[6]
    input  [MAX_DEV:0] rx_sdin // JX[7]
    );
    wire rst;
    xpm_cdc_array_single #(
    .DEST_SYNC_FF(4),   // DECIMAL; range: 2-10
    .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
    .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
    .SRC_INPUT_REG(0),  // DECIMAL; 0=do not register input, 1=register input
    .WIDTH(2)           // DECIMAL; range: 1-1024
    )
    xpm_cdc_array_mclk_rst (
        .dest_out(rst), // WIDTH-bit output: src_in synchronized to the destination clock domain. This
                        // output is registered.

        .dest_clk(mclk), // 1-bit input: Clock signal for the destination clock domain.
        //.src_clk(src_clk),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
        .src_in(~rstn)      // WIDTH-bit input: Input single-bit array to be synchronized to destination clock
                        // domain. It is assumed that each bit of the array is unrelated to the others. This
                        // is reflected in the constraints applied to this macro. To transfer a binary value
                        // losslessly across the two clock domains, use the XPM_CDC_GRAY macro instead.

    );
    
    
    wire sysclkrst;
    xpm_cdc_array_single #(
    .DEST_SYNC_FF(4),   // DECIMAL; range: 2-10
    .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
    .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
    .SRC_INPUT_REG(0),  // DECIMAL; 0=do not register input, 1=register input
    .WIDTH(2)           // DECIMAL; range: 1-1024
    )
    xpm_cdc_array_clk_rst (
        .dest_out(sysclkrst), // WIDTH-bit output: src_in synchronized to the destination clock domain. This
                        // output is registered.

        .dest_clk(clk), // 1-bit input: Clock signal for the destination clock domain.
        //.src_clk(src_clk),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
        .src_in(~rstn)      // WIDTH-bit input: Input single-bit array to be synchronized to destination clock
                        // domain. It is assumed that each bit of the array is unrelated to the others. This
                        // is reflected in the constraints applied to this macro. To transfer a binary value
                        // losslessly across the two clock domains, use the XPM_CDC_GRAY macro instead.

    );
    
    wire mclk;
    clk_wiz_0 clk_div(.clk_in1(clk),.reset(sysclkrst),.mclk(mclk));
    generate for(genvar i = 0; i < MAX_DEV + 1; i = i + 1) begin : mclks
        assign tx_mclk[i] = mclk;
        assign rx_mclk[i] = mclk;
        end
    endgenerate
    
    reg [23:0] l_data[MAX_DEV:0];
    reg [23:0] r_data[MAX_DEV:0];
    
    wire [24:0] l_data_summed;
    wire [24:0] r_data_summed;
    assign l_data_summed = {l_data[0][23],l_data[0]} + {l_data[1][23],l_data[1]};
    assign r_data_summed = {r_data[0][23],r_data[0]} + {r_data[1][23],r_data[1]};
    wire  ws [MAX_DEV:0];
    
    wire [23:0] l_data_out;
    wire [23:0] r_data_out;
    assign l_data_out = l_data_summed[24:1];
    assign r_data_out = r_data_summed[24:1];
    
    wire left_rightn [MAX_DEV:0];
    wire data_en [MAX_DEV:0];
    wire [23:0] data_in [MAX_DEV:0];

    wire sclk;
    wire sclk_posedge;
    wire sclk_negedge;
    clock_div #(.log2clkdiv(1)) sck_div
        (
        .clk(mclk),
        .rst(rst),
        .div_clk(sclk),
        .rising_edge(sclk_posedge),
        .falling_edge(sclk_negedge)
    );
    generate
        for(genvar i = 0; i < MAX_DEV + 1; i = i + 1) begin : pmodi2s2s

            assign tx_lrck[i] = ws[i];
            assign rx_lrck[i] = ws[i];


            assign rx_sclk[i] = sclk;
            assign tx_sclk[i] = sclk;

            
            i2sin in(
                .clk(mclk),
                .sck_negedge(sclk_negedge),
                .rst(rst),
                .ws(ws[i]),
                .sd(rx_sdin[i]),
                .data_in(data_in[i]),
                .left_rightn(left_rightn[i]),
                .data_en(data_en[i]));
    
            i2sout out(
                .clk(mclk),
                .sck_posedge(sclk_posedge),
                .l_data(l_data_out),
                .r_data(r_data_out),
                .rst(rst),
                .ws(ws[i]),
                .sd(tx_sdout[i]),
                .data_en(1));
    
    /*
    ila_0 lgr (
        .clk(clk),
        .probe0(sclk),
        .probe1(ws),
        .probe2(rx_sdin),
        .probe3(tx_sdout),
        .probe4(mclk),
        .probe5(rst)
    );
    */
    
 
        always @(posedge mclk) begin
            if(rst) begin
                l_data[i] <= 0;
                r_data[i] <= 0;
            end
            else begin
            if(data_en[i]) 
                case (left_rightn[i])
                    1: l_data[i] <= data_in[i];
                    0: r_data[i] <= data_in[i]; 
                endcase
            end
         end
     end
     endgenerate
    
endmodule
