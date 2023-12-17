module Top (
	input 				sys_clk, 
	input 				rst_n,
	input 				but_center, 
	input				but_up, 
	input				but_down, 
	input				but_left, 
	input				but_right,
	input				but_esc,
	input	[7:0]		buts,
	output 	[7:0]   	LED,
	output	[7:0]		Debug_LED,
	output				pwm,
	output				sd
);
    //------------------Clk Divider------------------//
	wire slow_clk;
	ClkDivider ClkDivider_inst(
		.sys_clk	(sys_clk	),
		.rst_n		(rst_n		),
		.slow_clk	(slow_clk	)
	);

	//------------------Key Debouncer-----------------//
    wire pres_center, pres_up, pres_down, pres_left, pres_right, pres_esc;
	wire pose_center, pose_up, pose_down, pose_left, pose_right, pose_esc;
	wire nege_center, nege_up, nege_down, nege_left, nege_right, nege_esc;
	wire [7:0] pres_buts, pose_buts, nege_buts;
	KeysDebouncer14 KeysDebouncer14_inst(
		.slow_clk		(slow_clk																		),
		.rst_n			(rst_n																			),
		.but_in			({but_center,  but_up,  but_down,  but_left,  but_right,  ~but_esc, ~buts}		),
		.but_active		({pres_center, pres_up, pres_down, pres_left, pres_right, pres_esc, pres_buts}	),
		.but_posedge	({pose_center, pose_up, pose_down, pose_left, pose_right, pose_esc, pose_buts}	),
		.but_negedge	({nege_center, nege_up, nege_down, nege_left, nege_right, nege_esc, nege_buts}	)
	);

	//------------------Set keys------------------//
	reg [2:0] perm [7:0];
	reg [2:0] setting_cnt;
	initial begin
		setting_cnt = 3'b000;
		perm[0] = 3'b000;
		perm[1] = 3'b001;
		perm[2] = 3'b010;
		perm[3] = 3'b011;
		perm[4] = 3'b100;
		perm[5] = 3'b101;
		perm[6] = 3'b110;
		perm[7] = 3'b111;
	end

	//------------------Finite State Machine-----------------//
	`include "TopParams.v";
	reg		[7:0]		mode	= `WelcomePage;
	reg		[7:0]		next_mode;
	assign 	LED  = 	mode;

	always @(posedge slow_clk or negedge rst_n) begin
		if (~rst_n) begin
			mode <= `WelcomePage;
		end
		else begin
			if (mode == `WelcomePage  ) 
				case ({pose_center, pose_up, pose_down, pose_left, pose_right, pose_esc})
				    6'b100000: begin
						mode <= `ChooseModePage;
						next_mode <= `FreeMode;
					end
					default:  mode <= `WelcomePage;
				endcase
			else if(mode == `ChooseModePage	)
				case ({pose_center, pose_up, pose_down, pose_left, pose_right, pose_esc})
					6'b100000: begin
						mode <= next_mode;
					end
					6'b010000: begin
						case (next_mode)
							`FreeMode: begin
								next_mode	<= `SettingMode;
								setting_cnt	<= 3'b000;
								perm[0]		<= 3'b000;
								perm[1]		<= 3'b000;
								perm[2]		<= 3'b000;
								perm[3]		<= 3'b000;
								perm[4]		<= 3'b000;
								perm[5]		<= 3'b000;
								perm[6]		<= 3'b000;
								perm[7]		<= 3'b000;
							end
							`Song_PlayMode:		next_mode	<= `UserRanking;
							`Song_LearnMode:	next_mode	<= `FreeMode;
							`Song_GameMode:		next_mode	<= `Song_PlayMode;
							`SettingMode:		next_mode	<= `Song_LearnMode;
							`UserRanking:		next_mode	<= `Song_GameMode;
							default: 			next_mode	<= next_mode;
						endcase
					end
					6'b001000: begin
						case (next_mode)
							`FreeMode:			next_mode	<= `Song_LearnMode;
							`Song_PlayMode:		next_mode	<= `Song_GameMode;
							`Song_LearnMode: begin
								next_mode	<= `SettingMode;
								setting_cnt	<= 3'b000;
								perm[0]		<= 3'b000;
								perm[1]		<= 3'b000;
								perm[2]		<= 3'b000;
								perm[3]		<= 3'b000;
								perm[4]		<= 3'b000;
								perm[5]		<= 3'b000;
								perm[6]		<= 3'b000;
								perm[7]		<= 3'b000;
							end
							`Song_GameMode:		next_mode	<= `UserRanking;
							`SettingMode:		next_mode	<= `FreeMode;
							`UserRanking:		next_mode	<= `Song_PlayMode;
							default: 			next_mode	<= next_mode;
						endcase
					end
					6'b000100, 6'b000010: begin
						case (next_mode)
							`FreeMode:			next_mode	<= `Song_PlayMode;
							`Song_PlayMode:		next_mode	<= `FreeMode;
							`Song_LearnMode:	next_mode	<= `Song_GameMode;
							`Song_GameMode:		next_mode	<= `Song_LearnMode;
							`SettingMode:		next_mode	<= `UserRanking;
							`UserRanking: begin
								next_mode	<= `SettingMode;
								setting_cnt	<= 3'b000;
								perm[0]		<= 3'b000;
								perm[1]		<= 3'b000;
								perm[2]		<= 3'b000;
								perm[3]		<= 3'b000;
								perm[4]		<= 3'b000;
								perm[5]		<= 3'b000;
								perm[6]		<= 3'b000;
								perm[7]		<= 3'b000;
							end
							default: 			next_mode	<= next_mode;
						endcase
					end
					6'b000001: begin
						mode <= `WelcomePage;
					end
					default: begin
						mode <= mode;
						next_mode <= next_mode;
					end
				endcase
			else if(mode == `FreeMode		)
				case ({pose_center, pose_up, pose_down, pose_left, pose_right, pose_esc})
					6'b000001:	mode <= `ChooseModePage;
					default:	mode <= `FreeMode;
				endcase
			else if(mode == `PlayMode		)
				case ({pose_center, pose_up, pose_down, pose_left, pose_right, pose_esc})
					6'b000001:	mode <= `Song_PlayMode;
					default:	mode <= `PlayMode;
				endcase
			else if(mode == `LearnMode		)
				case ({pose_center, pose_up, pose_down, pose_left, pose_right, pose_esc})
					6'b000001:	mode <= `Song_LearnMode;
					default:	mode <= `LearnMode	;
				endcase
			else if(mode == `GameMode		)
				case ({pose_center, pose_up, pose_down, pose_left, pose_right, pose_esc})
					6'b000001:	mode <= `Song_GameMode;
					default:	mode <= `GameMode;
				endcase
			else if(mode == `SettingMode		) begin
				if (setting_cnt == 3'b000 && perm[0] != 0) begin
					mode <= `ChooseModePage;
				end
				else begin
					case ({pose_center, pose_up, pose_down, pose_left, pose_right, pose_esc, pose_buts})
						14'b00_0001_0000_0000:	mode <= `ChooseModePage;
						14'b00_0000_0000_0001: begin
							{perm[0], setting_cnt} <= {setting_cnt, setting_cnt + 1};
							mode <= `SettingMode;
						end
						14'b00_0000_0000_0010: begin
							{perm[1], setting_cnt} <= {setting_cnt, setting_cnt + 1};
							mode <= `SettingMode;
						end
						14'b00_0000_0000_0100: begin
							{perm[2], setting_cnt} <= {setting_cnt, setting_cnt + 1};
							mode <= `SettingMode;
						end
						14'b00_0000_0000_1000: begin
							{perm[3], setting_cnt} <= {setting_cnt, setting_cnt + 1};
							mode <= `SettingMode;
						end
						14'b00_0000_0001_0000: begin
							{perm[4], setting_cnt} <= {setting_cnt, setting_cnt + 1};
							mode <= `SettingMode;
						end
						14'b00_0000_0010_0000: begin
							{perm[5], setting_cnt} <= {setting_cnt, setting_cnt + 1};
							mode <= `SettingMode;
						end
						14'b00_0000_0100_0000: begin
							{perm[6], setting_cnt} <= {setting_cnt, setting_cnt + 1};
							mode <= `SettingMode;
						end
						14'b00_0000_1000_0000: begin
							{perm[7], setting_cnt} <= {setting_cnt, setting_cnt + 1};
							mode <= `SettingMode;
						end
						default:	mode <= `SettingMode;
					endcase
				end
			end
			else if(mode == `Song_PlayMode 	)
				case ({pose_center, pose_up, pose_down, pose_left, pose_right, pose_esc})
					6'b100000:	mode <= `PlayMode;
					6'b000001:	mode <= `ChooseModePage;
					default:	mode <= `Song_PlayMode;
				endcase
			else if(mode == `Song_LearnMode	)
				case ({pose_center, pose_up, pose_down, pose_left, pose_right, pose_esc})
					6'b100000:	mode <= `LearnMode;
					6'b000001:	mode <= `ChooseModePage;
					default:	mode <= `Song_LearnMode;
				endcase
			else if(mode == `Song_GameMode	)
				case ({pose_center, pose_up, pose_down, pose_left, pose_right, pose_esc})
					6'b100000:	mode <= `GameMode;
					6'b000001:	mode <= `ChooseModePage;
					default:	mode <= `Song_GameMode;
				endcase
			else 
				mode <= mode;
		end
	end

	//------------------Song Repertoire------------------//
	// parameter 			song_per_page 	= 4;
	reg 				repertoire_page = 0;
	reg 	[1:0] 		page_song_id 	= 0;

	always @(posedge sys_clk or negedge rst_n) begin
		if(~rst_n) begin
			repertoire_page <= 1'b0;
			page_song_id 	<= 2'b00;
		end
		else begin // We only use left right down because center and up are chosen.
			if(mode == `Song_PlayMode || mode == `Song_LearnMode || mode == `Song_GameMode) begin
				if(pose_up)
					page_song_id <= (page_song_id == 2'b00) ? 2'b11 : page_song_id - 1;
				else if(pose_down)
					page_song_id <= (page_song_id == 2'b11) ? 2'b00 : page_song_id + 1;
				else if(pose_left || pose_right)
					repertoire_page <= ~repertoire_page;
				else begin
					page_song_id <= page_song_id;
					repertoire_page <= repertoire_page;
				end
			end
		end
	end

	wire 	[2:0] 		visible_song_id;
	assign  visible_song_id = {repertoire_page, page_song_id};

	//------------------Free Mode------------------//
	FreeMode FreeMode_inst(
		.clk		(sys_clk			),
		.rst_n		(mode == `FreeMode	),
		.buts		(pres_buts			),
		.but_up		(pose_up			),
		.but_center	(pose_center		),
		.but_down	(pose_down			),
		.pwm		(pwm				),
		.sd			(sd					)
	);
endmodule