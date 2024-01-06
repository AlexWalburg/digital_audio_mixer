`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/26/2023 07:07:42 PM
// Design Name: 
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


module bent_pipe(
    input clk,
    input rstn,
    output tx_mclk, // JA[0]
    output tx_lrck, // JA[1]
    output tx_sclk, // JA[2]
    output tx_sdout, // JA[3]
    output rx_mclk, // JA[4]
    output rx_lrck, // JA[5]
    output rx_sclk, // JA[6]
    input  rx_sdin // JA[7]
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
    assign tx_mclk = mclk;
    assign rx_mclk = mclk;
    
    
    
    wire ws;
    assign tx_lrck = ws;
    assign rx_lrck = ws;
    
    reg [23:0] l_data;
    reg [23:0] r_data; 
    
    wire sclk;
    wire sclk_posedge;
    wire sclk_negedge;
    clock_div #(.log2clkdiv(3)) sck_div
        (
        .clk(mclk),
        .rst(rst),
        .div_clk(sclk),
        .rising_edge(sclk_posedge),
        .falling_edge(sclk_negedge)
        );
    assign rx_sclk = sclk;
    assign tx_sclk = sclk;
    
    
    wire left_rightn;
    wire data_en;
    wire [23:0] data_in;
    
    i2sin in(
        .clk(mclk),
        .sck_negedge(sclk_negedge),
        .rst(rst),
        .ws(ws),
        .sd(rx_sdin),
        .data_in(data_in),
        .left_rightn(left_rightn),
        .data_en(data_en));
    
    i2sout out(
        .clk(mclk),
        .sck_posedge(sclk_posedge),
        .l_data(l_data),
        .r_data(r_data),
        .rst(rst),
        .ws(ws),
        .sd(tx_sdout),
        .data_en(1));
    
    
    
    ila_0 lgr (
        .clk(clk),
        .probe0(sclk),
        .probe1(ws),
        .probe2(rx_sdin),
        .probe3(tx_sdout),
        .probe4(mclk),
        .probe5(rst)
    );
    
 
   always @(posedge mclk) begin
        if(rst) begin
            l_data <= 24'h012345;
            r_data <= 24'h89ABCD;
        end
        else begin
            if(data_en) 
                case (left_rightn)
                    1: l_data <= data_in;
                    0: r_data <= data_in; 
                endcase
        end
   end
    
endmodule
