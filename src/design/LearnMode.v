`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/17 20:02:19
// Design Name: 
// Module Name: LearnMode
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


module LearnMode(
    input           clk,
	input           rst_n,
	input	[7:0]	buts,
	input 	[1:0]   octave,
	input   [9:0]   data_out,
	input           output_ready,
	output          read_en

);
    reg count;
    /*reg [7:0] cur_buts = 0;
    reg [7:0] last_buts = 0;
    wire [7:0] post_buts;
    
    always @(posedge clk) begin
        if(~rst_n)begin
            count <= 1;
        end else begin
            if(count) begin
                count <= 0;
            end
        end
        {last_buts, cur_buts} <= {cur_buts, buts};
    end
    assign post_buts = cur_buts & ~last_buts;
    assign read_en = count ? 1 : ((rst_n & {post_buts[0], post_buts[1], post_buts[2], post_buts[3], post_buts[4], post_buts[5], post_buts[6], post_buts[7], octave} == data_out & output_ready) ? 1 : 0);
*/
    always @(posedge clk) begin
        if(~rst_n)begin
            count <= 1;
        end else begin
            if(count) begin
                count <= 0;
            end
        end
    end
    assign read_en = count ? 1 : ((rst_n & {buts[0], buts[1], buts[2], buts[3], buts[4], buts[5], buts[6], buts[7], octave} == data_out & output_ready) ? 1 : 0);

endmodule
