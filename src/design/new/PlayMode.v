`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/17 17:40:00
// Design Name: 
// Module Name: PlayMode
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
`define DISPLAY_LENGTH   384

module PlayMode(
    input                       clk,
    input                       isMode,
    input [9:0]                 vga_bottom_pm,
    output                      read_en,
    output	                    pwm,
    output                      sd
    );
    
    wire [9:0] data_temp;
    assign data_temp = (isMode) ? vga_bottom_pm : 9'b0;
    assign read_en = isMode;
    
    SoundTop SoundTop_inst_play(
            .clk        (clk               ),
            .rst_n      (isMode            ),
            .shift      (data_temp[1:0]    ),
            .notes      (data_temp[9:2]    ),
            .pwm        (pwm               ),
            .sd         (sd                )
    );
endmodule

