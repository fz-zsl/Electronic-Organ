`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/09 16:25:23
// Design Name: 
// Module Name: vga_ascii
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

//This is the module that loads the files of ASCII chars and output the position data at the place. 
module vga_ascii #(
    parameter   char_color  = 24'h000000
)(
    input       [7:0]       ascii   ,
    input       [9:0]       x_over  ,
    input       [9:0]       y_over  ,  
    output      [23:0]      pos_data    
);

    reg [7:0]   stored_ascii[0 : 256 * 16 - 1];
    
    initial $readmemh("E:/notes/ASC16-96.txt",stored_ascii);
    
    assign pos_data = (stored_ascii[16 * ascii + y_over][7 - x_over]==1) ? 24'h000000 : 24'hFFFFFF;

endmodule