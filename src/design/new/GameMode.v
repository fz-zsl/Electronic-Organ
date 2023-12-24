`timescale 1ns / 1ps
module GameMode(
    input                       clk,
    input                       rst_n,
    input                       output_ready,
    input [9:0]                 data_out,
    output                      read_en,
    output	                    pwm,
    output                      sd
    );
    wire [9:0] data_temp;
    assign data_temp = (rst_n) ? data_out : 9'b0;
    assign read_en = rst_n;
    SoundTop SoundTop_inst_play(
        .clk        (clk               ),
        .rst_n      (rst_n             ),
        .shift      (data_temp[1:0]    ),
        .notes      (data_temp[9:2]    ),
        .pwm        (pwm               ),
        .sd         (sd                )
    );
endmodule
