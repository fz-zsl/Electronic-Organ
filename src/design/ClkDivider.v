module ClkDivider(
	input			sys_clk,
	input			rst_n,
	output	reg		slow_clk
);
	`include "TopParams.v";
	reg		[19:0]	cnt;
	always @(posedge sys_clk or negedge rst_n) begin
	   	if(~rst_n) begin
	   		cnt <= 20'b0;
			slow_clk <= 1'b0;
		end
		else if (cnt == `HalfClockPeriod - 1) begin
			cnt <= 20'b0;
			slow_clk <= ~slow_clk;
		end
		else begin
			cnt <= cnt + 1;
			slow_clk <= slow_clk;
		end
	end
endmodule