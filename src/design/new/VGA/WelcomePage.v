`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/18 12:32:00
// Design Name: 
// Module Name: WelcomePage
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
module WelcomePage(
    input   wire            vga_clk     ,
    input   wire            rst_n       ,
    input   wire    [9:0]   pos_x       ,
    input   wire    [9:0]   pos_y       ,
    output  wire    [23:0]  pos_data     
    );
    parameter height_welcome = 100;
    parameter width_welcome = 300;
    parameter start_point_welcome_x = 170;
    parameter start_point_welcome_y = 100;
    
    wire [15:0] data_addr;
    wire        enable_pic;
    Welcome_page welcome_page_inst(
        .addra      (data_addr),
        .clka       (vga_clk),
        .douta      (pos_data),
        .ena        (1)
    );
    
    assign enable_pic  = ( (pos_y - start_point_welcome_y < height_welcome) && (pos_x - start_point_welcome_x < width_welcome) );                               
    assign data_addr = enable_pic ? ( (pos_y - start_point_welcome_y ) * width_welcome + (pos_x - start_point_welcome_x ) ) : 0;
endmodule
