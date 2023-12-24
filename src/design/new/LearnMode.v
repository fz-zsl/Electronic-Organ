`timescale 1ns / 1ps
module LearnMode(
    input           clk,
	input           rst_n,
	input	[7:0]	buts,
	input 	[1:0]   octave,
	input   [9:0]   data_out,
	output          read_en

);
reg count;
always @(posedge clk) begin
    if(~rst_n)begin
        count <= 1;
    end else begin
        if(count) begin
            count <= 0;
        end
    end
end
assign read_en = count ? 1 : ((rst_n & ({buts[0], buts[1], buts[2], buts[3], buts[4], buts[5], buts[6], buts[7], octave} == data_out)) ? 1 : 0);
endmodule
