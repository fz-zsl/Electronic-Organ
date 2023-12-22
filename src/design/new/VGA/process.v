`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/22 22:06:47
// Design Name: 
// Module Name: process
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
`include "VGAparams.v"

module process(
    input   wire            clk         ,
    input   wire            showProcess ,
    input   wire    [9:0]   pos_x       ,
    input   wire    [9:0]   pos_y       ,
    input   wire    [9:0]   duration    ,
    output  [23:0]          pos_data    
);
    reg     [29:0]          counter;
    always @(posedge clk or posedge showProcess)begin
        if(showProcess)
            counter <= 30'b0;
        else begin
            if(counter == duration * `SAMPLE_INTERVAL) 
                counter <= 30'b0;
            else 
                counter <= counter +1;
        end
    end
    
    wire enable;
    assign enable = (pos_x * duration * `SAMPLE_INTERVAL < counter * 640) && (pos_y < 3 && showProcess) ? 1'b1 : 1'b0;
    assign pos_data =  (enable) ? 24'h000000: 24'hFFFFFF;
    
endmodule
