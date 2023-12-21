module KeyDebouncer(
	input			slow_clk,
	input			rst_n,
	input			but_in,
	output			but_posedge,
	output			but_negedge,
	output	reg 	but_active
);
	reg prev, cur;
	always @(posedge slow_clk or negedge rst_n) begin
		if(~rst_n) begin
			prev <= 1'b0;
			cur  <= 1'b0;
			but_active <= 1'b0;
		end
		else begin
			{prev, cur, but_active} <= {cur, but_in, but_in};
		end
	end
	assign but_posedge = (~prev) & cur;
	assign but_negedge = prev & (~cur);
endmodule