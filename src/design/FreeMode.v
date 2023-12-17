module FreeMode(
	input           clk,
	input           rst_n,
	input	[7:0]	buts,
	input 		 	but_up,
	input 		 	but_center,
	input 		 	but_down,
	input	[7:0]	perm,
	output			pwm,
	output			sd
);
	reg 	[1:0] 	octave;

	always @(posedge clk or negedge rst_n) begin
		if (~rst_n) begin
			octave <= 2'b00;
		end
		else begin
			case ({but_up, but_center, but_down})
				3'b100: octave <= 2'b10;
				3'b010: octave <= 2'b00;
				3'b001: octave <= 2'b01;
				default: octave <= octave;
			endcase
		end
	end

	SoundTop SoundTop_inst(
		.clk		(clk															),
		.rst_n		(rst_n															),
		.shift		(octave															),
		.notes		({buts[perm[0]], buts[perm[1]], buts[perm[2]], buts[perm[3]],
						buts[perm[4]], buts[perm[5]], buts[perm[6]], buts[perm[7]]}	),
		.pwm		(pwm															),
		.sd			(sd																)
	);
endmodule