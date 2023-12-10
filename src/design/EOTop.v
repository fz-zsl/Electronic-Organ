/*
Electronic Organizer Top Module

States:
[0] Welcome page (username entry and credits)
[1] Main menu (choose mode: 3, 4, 5, 6, 7, 8, 9)
[2] Sub menu (choose song)
[3] Free mode (play notes you enter)
[4] Play mode (play songs in memory)
[5] Learn mode (play songs with correct keys as triggers)
[6] Game mode (piano tiles)
[7] Settings (change key mapping)
[8] User rankings

State transition:
[0] -> [1]: triggered by pressing enter (end of username input)
[1] -> [0]: triggered by pressing ESC
[1] -> [2, 3, 7, 8]: choose in main menu
[3] -> [4, 5, 6]: choose in sub menu
[2, 3, 4, 5, 6, 7, 8] -> [1]: triggered by pressing ESC

Recording:
- Start recording in any mode except [0] by turning on switch[0]
- Stop recording by turning off switch[0]
- After ending record, goto state [1] with pop-up notification (save / discard)

Input ports:
- From FPGA: sys_clk, rst_n, switch[7:0]
- From PS/2 (keyboard): PS2_clk, PS2_data
- From VGA: TODO

Output ports:
- To FPGA: LED[7:0]
- To buzzer: TODO
- To VGA: TODO
*/

module EOTop (
	input sys_clk, input rst_n,
	input PS2_clk, input PS2_data,
	output [7:0] LED
);
	`include "TopParams.v"
	`include "KeyParams.v"

	reg [(`max_string_length * 8) - 1:0] username = 0;
	reg [3:0] mode = 4'b0000;
	reg [3:0] next_mode = 4'b0000;
	reg [3:0] sub_mode = 4'b0000;
	reg [(`log2_max_string_length - 1):0] username_length = 0;
	reg signed [1:0] username_length_delta = 0;
	reg repertoire_page = 0;
	reg [1:0] page_song_id = 0;
	wire [3:0] visible_song_id;
	assign visible_song_id = {repertoire_page, page_song_id};
	reg [3:0] all_song_id = 0;

    wire [7:0] oData;
    wire PS2_trig;
    wire PS2_ovf;
	PS2Decoder PS2Decoder_dut(
		.sys_clk(sys_clk), .rst_n(rst_n),
		.ps2_clk(PS2_clk), .ps2_data(PS2_data), .in_en(1'b1),
		.data(oData), .out_en(PS2_trig), .overflow(PS2_ovf)
	);

	reg [7:0] last_oData = 0;
	always @* begin
		if (PS2_trig) begin
			last_oData = oData;
		end
	end
    
    wire [7:0] stable_data;
    assign stable_data = (PS2_trig && last_oData != 8'hf0 ? oData : 0);

    assign LED = mode;

    reg [6:0] sys_clk_cnt = 0;
    always @(posedge sys_clk) begin
        sys_clk_cnt <= sys_clk_cnt + 1'b1;
    end
    reg [20:0] sys_clk128 = 0;
    always @(posedge sys_clk_cnt[6]) begin
        sys_clk128 <= sys_clk128 + 1'b1;
    end

    reg [20:0] last_clk128 = 0;
    reg [8:0] last_data = 0;
	always @(posedge sys_clk) begin
		if (~rst_n) begin
			username <= 0;
			username_length <= 0;
			username_length_delta <= 0;
			mode <= 4'b0000;
		end
		if (~PS2_trig) begin
		    //
		end
		else if (stable_data == 0 || stable_data == last_data && sys_clk128 - last_clk128 < 10000) begin
		    //
		end
		else begin
			last_clk128 <= sys_clk128;
			last_data <= stable_data;
			if (mode == 4'd0) begin // welcome page
				if (stable_data == `ps2_enter) begin // enter
					mode <= 4'd1;
					next_mode <= 4'd2;
					sub_mode <= 4'd0;
					repertoire_page <= 0;
					page_song_id <= 0;
				end
				else if (stable_data == `ps2_esc || stable_data == `ps2_f11) begin // esc, clear input
					username <= 4'd0;
					username_length <= 0;
					username_length_delta <= 0;
				end
				else if (stable_data == `ps2_bksp && username_length != 0) begin // backspace
					username_length_delta <= -1;
				end
				else begin // other keys
					username_length_delta <= 1;
				end
			end
			else if (mode == 4'd1) begin
				if (stable_data == `ps2_esc || stable_data == `ps2_f11) begin
					mode <= 4'd0;
				end
				else if (stable_data == `ps2_enter) begin
					mode <= next_mode;
				end
				else if (stable_data == `ps2_up) begin
					if (next_mode == 4'd2 && sub_mode == 4'd0) begin
						next_mode <= 4'd7;
						sub_mode <= 4'd0;
						repertoire_page <= 0;
						page_song_id <= 0;
					end
					else if (next_mode == 4'd3 && sub_mode == 4'd4) begin
						next_mode <= 4'd8;
						sub_mode <= 4'd0;
						repertoire_page <= 0;
						page_song_id <= 0;
					end
					else if (next_mode == 4'd3 && sub_mode == 4'd5) begin
						next_mode <= 4'd2;
						sub_mode <= 4'd0;
						repertoire_page <= 0;
						page_song_id <= 0;
					end
					else if (next_mode == 4'd3 && sub_mode == 4'd6) begin
						next_mode <= 4'd3;
						sub_mode <= 4'd4;
						repertoire_page <= 0;
						page_song_id <= 0;
					end
					else if (next_mode == 4'd7 && sub_mode == 4'd0) begin
						next_mode <= 4'd3;
						sub_mode <= 4'd5;
						repertoire_page <= 0;
						page_song_id <= 0;
					end
					else if (next_mode == 4'd8 && sub_mode == 4'd0) begin
						next_mode <= 4'd3;
						sub_mode <= 4'd6;
						repertoire_page <= 0;
						page_song_id <= 0;
					end
				end
				else if (stable_data == `ps2_down) begin
					if (next_mode == 4'd2 && sub_mode == 4'd0) begin
						next_mode <= 4'd3;
						sub_mode <= 4'd5;
						repertoire_page <= 0;
						page_song_id <= 0;
					end
					else if (next_mode == 4'd3 && sub_mode == 4'd4) begin
						next_mode <= 4'd3;
						sub_mode <= 4'd6;
						repertoire_page <= 0;
						page_song_id <= 0;
					end
					else if (next_mode == 4'd3 && sub_mode == 4'd5) begin
						next_mode <= 4'd7;
						sub_mode <= 4'd0;
						repertoire_page <= 0;
						page_song_id <= 0;
					end
					else if (next_mode == 4'd3 && sub_mode == 4'd6) begin
						next_mode <= 4'd8;
						sub_mode <= 4'd0;
						repertoire_page <= 0;
						page_song_id <= 0;
					end
					else if (next_mode == 4'd7 && sub_mode == 4'd0) begin
						next_mode <= 4'd2;
						sub_mode <= 4'd0;
						repertoire_page <= 0;
						page_song_id <= 0;
					end
					else if (next_mode == 4'd8 && sub_mode == 4'd0) begin
						next_mode <= 4'd3;
						sub_mode <= 4'd4;
						repertoire_page <= 0;
						page_song_id <= 0;
					end
				end
				else if (stable_data == `ps2_left || stable_data == `ps2_right) begin
					if (next_mode == 4'd2 && sub_mode == 4'd0) begin
						next_mode <= 4'd3;
						sub_mode <= 4'd4;
						repertoire_page <= 0;
						page_song_id <= 0;
					end
					else if (next_mode == 4'd3 && sub_mode == 4'd4) begin
						next_mode <= 4'd2;
						sub_mode <= 4'd0;
						repertoire_page <= 0;
						page_song_id <= 0;
					end
					else if (next_mode == 4'd3 && sub_mode == 4'd5) begin
						next_mode <= 4'd3;
						sub_mode <= 4'd6;
						repertoire_page <= 0;
						page_song_id <= 0;
					end
					else if (next_mode == 4'd3 && sub_mode == 4'd6) begin
						next_mode <= 4'd3;
						sub_mode <= 4'd5;
						repertoire_page <= 0;
						page_song_id <= 0;
					end
					else if (next_mode == 4'd7 && sub_mode == 4'd0) begin
						next_mode <= 4'd8;
						sub_mode <= 4'd0;
						repertoire_page <= 0;
						page_song_id <= 0;
					end
					else if (next_mode == 4'd8 && sub_mode == 4'd0) begin
						next_mode <= 4'd7;
						sub_mode <= 4'd0;
						repertoire_page <= 0;
						page_song_id <= 0;
					end
				end
			end
			else if (mode == 4'd2 || mode > 4'd3 && mode < 4'd9) begin
				if (stable_data == `ps2_esc || stable_data == `ps2_a) begin
					mode <= 4'd1;
					next_mode <= 4'd2;
					sub_mode <= 4'd0;
					repertoire_page <= 0;
					page_song_id <= 0;
				end
			end
			else if (mode == 4'd3) begin
				if (stable_data == `ps2_esc || stable_data == `ps2_f11) begin
					mode <= 4'd1;
					next_mode <= 4'd3;
					sub_mode <= 4'd0;
				end
				else if (stable_data == `ps2_enter) begin
					mode <= sub_mode;
				end
				else if (stable_data == `ps2_up) begin
					page_song_id <= page_song_id - 1;
				end
				else if (stable_data == `ps2_down) begin
					page_song_id <= page_song_id + 1;
				end
				else if (stable_data == `ps2_left || stable_data == `ps2_right) begin
					repertoire_page <= ~repertoire_page;
					page_song_id <= 0;
				end
			end
		end
	end

	always @(username_length_delta) begin
		if (username_length_delta == 1) begin
			username_length = username_length + 1;
			username[username_length * 8 - 8] <= oData[0];
			username[username_length * 8 - 7] <= oData[1];
			username[username_length * 8 - 6] <= oData[2];
			username[username_length * 8 - 5] <= oData[3];
			username[username_length * 8 - 4] <= oData[4];
			username[username_length * 8 - 3] <= oData[5];
			username[username_length * 8 - 2] <= oData[6];
			username[username_length * 8 - 1] <= oData[7];
		end
		else if (username_length_delta == -1) begin
			username[username_length * 8 - 8] <= 1'b0;
			username[username_length * 8 - 7] <= 1'b0;
			username[username_length * 8 - 6] <= 1'b0;
			username[username_length * 8 - 5] <= 1'b0;
			username[username_length * 8 - 4] <= 1'b0;
			username[username_length * 8 - 3] <= 1'b0;
			username[username_length * 8 - 2] <= 1'b0;
			username[username_length * 8 - 1] <= 1'b0;
			username_length = username_length - 1;
		end
		username_length_delta = 0;
	end

	// always @(visible_song_id) begin
	// 	reg cnt = 0;
	// 	all_song_id = 0;
	// 	for (; cnt < visible_song_id; all_song_id = all_song_id + 1) begin
	// 		if (song_owner[all_song_id] == username
	// 			or song_owner[all_song_id] == `ascii_global) begin
	// 			cnt = cnt + 1;
	// 		end
	// 	end
	// end
endmodule