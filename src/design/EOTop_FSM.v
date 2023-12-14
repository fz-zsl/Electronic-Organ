module EOTop_FSM (
	input 				sys_clk, 
	input 				rst_n,
	input 				but_center, 
	input				but_up, 
	input				but_down, 
	input				but_left, 
	input				but_right,
	output 	[7:0]   	LED
);
    //------------------Clk Divider------------------//
	parameter 			period 		= 1000000;
	reg 		[19:0] 	cnt 		;
	reg 				slow_clk 	;
    always @(posedge sys_clk or negedge rst_n) begin
       	if(~rst_n) begin
	   		cnt <= 20'b0;
			slow_clk <= 1'b0;
		end
		else if (cnt == period - 1) begin
			cnt <= 20'b0;
			slow_clk <= ~slow_clk;
		end
		else begin
			cnt <= cnt + 1;
			slow_clk <= slow_clk;
		end
    end

	//------------------Key Debouncer-----------------//
    wire 	pres_center, pres_up, pres_down, pres_left, pres_right;
	//Center Key Debouncer
	reg     [1:0]   center_shift;
	always @(posedge slow_clk or negedge rst_n) begin
    	if(~rst_n) begin
        	center_shift[0] <= 1'b1;
        	center_shift[1] <= 1'b0;
    	end
    	else 
        	{center_shift[1], center_shift[0]} <= {but_center, ~center_shift[1]};
	end
	assign pres_center = center_shift[1] & center_shift[0];
	//Up Key Debouncer
	reg     [1:0]   up_shift;
	always @(posedge slow_clk or negedge rst_n) begin
    	if(~rst_n) begin
        	up_shift[0] <= 1'b1;
        	up_shift[1] <= 1'b0;
    	end
    	else 
        	{up_shift[1], up_shift[0]} <= {but_up, ~up_shift[1]};
	end
	assign pres_up = up_shift[1] & up_shift[0];

	//Down Key Debouncer
	reg     [1:0]   down_shift;
	always @(posedge slow_clk or negedge rst_n) begin
    	if(~rst_n) begin
        	down_shift[0] <= 1'b1;
        	down_shift[1] <= 1'b0;
    	end
    	else 
        	{down_shift[1], down_shift[0]} <= {but_down, ~down_shift[1]};
	end
	assign pres_down = down_shift[1] & down_shift[0];
	//Left Key Debouncer
	reg     [1:0]   left_shift;
	always @(posedge slow_clk or negedge rst_n) begin
    	if(~rst_n) begin
        	left_shift[0] <= 1'b1;
        	left_shift[1] <= 1'b0;
    	end
    	else 
        	{left_shift[1], left_shift[0]} <= {but_left, ~left_shift[1]};
	end
	assign pres_left = left_shift[1] & left_shift[0];
	//Right Key Debouncer
	reg     [1:0]   right_shift;
	always @(posedge slow_clk or negedge rst_n) begin
    	if(~rst_n) begin
        	right_shift[0] <= 1'b1;
        	right_shift[1] <= 1'b0;
    	end
    	else 
        	{right_shift[1], right_shift[0]} <= {but_right, ~right_shift[1]};
	end
	assign pres_right = right_shift[1] & right_shift[0];

	//------------------Finite State Machine-----------------//
	parameter	WelcomePage		= 8'b1000_0000;
	parameter	ChooseModePage	= 8'b0100_0000;
	parameter	FreeMode		= 8'b0010_0000;
	parameter	PlayMode		= 8'b0001_0000;
	parameter	LearnMode		= 8'b0000_1000;
	parameter	GameMode		= 8'b0000_0100;
	parameter	SettingMode		= 8'b0000_0010;
	parameter	ChooseSongPage 	= 8'b0000_0001;
	parameter	Song_PlayMode	= 8'b0001_0001;
	parameter	Song_LearnMode	= 8'b0000_1001;
	parameter	Song_GameMode	= 8'b0000_0101;
	parameter	UserRanking		= 8'b0000_0000;

	reg		[7:0]		mode	= WelcomePage;
	reg		[7:0]		next_mode;
	assign 	LED  = 	mode;

	always @(posedge slow_clk or negedge rst_n) begin
		if (~rst_n) begin
			mode <= WelcomePage;
		end
		else begin
			if (mode == WelcomePage  ) 
				case ({pres_center, pres_up, pres_down, pres_left, pres_right})
				    5'b10000: begin
						mode <= ChooseModePage;
						next_mode <= FreeMode;
					end
					default:  mode <= WelcomePage;
				endcase
			else if(mode == ChooseModePage	)
				case ({pres_center, pres_up, pres_down, pres_left, pres_right})
					5'b10000: begin
						mode <= next_mode;
					end
					5'b01000: begin
						case (next_mode)
							FreeMode:		next_mode	<= SettingMode;
							Song_PlayMode:	next_mode	<= UserRanking;
							Song_LearnMode:	next_mode	<= FreeMode;
							Song_GameMode:	next_mode	<= Song_PlayMode;
							SettingMode:	next_mode	<= Song_LearnMode;
							UserRanking:	next_mode	<= Song_GameMode;
							default: 		next_mode	<= next_mode;
						endcase
					end
					5'b00100: begin
						case (next_mode)
							FreeMode:		next_mode	<= Song_LearnMode;
							Song_PlayMode:	next_mode	<= Song_GameMode;
							Song_LearnMode:	next_mode	<= SettingMode;
							Song_GameMode:	next_mode	<= UserRanking;
							SettingMode:	next_mode	<= FreeMode;
							UserRanking:	next_mode	<= Song_PlayMode;
							default: 		next_mode	<= next_mode;
						endcase
					end
					5'b00010, 5'b00001: begin
						case (next_mode)
							FreeMode:		next_mode	<= Song_PlayMode;
							Song_PlayMode:	next_mode	<= FreeMode;
							Song_LearnMode:	next_mode	<= Song_GameMode;
							Song_GameMode:	next_mode	<= Song_LearnMode;
							SettingMode:	next_mode	<= UserRanking;
							UserRanking:	next_mode	<= SettingMode;
							default: 		next_mode	<= next_mode;
						endcase
					end
					default: begin
						mode <= mode;
						next_mode <= next_mode;
					end
				endcase
			// else if(mode == FreeMode		)
			// 	case ({pres_center, pres_up, pres_down, pres_left, pres_right})
			// 		5'b10000: mode <= ChooseModePage;
			// 		default:  mode <= FreeMode;
			// 	endcase
			// else if(mode == PlayMode		)
			// 	case ({pres_center, pres_up, pres_down, pres_left, pres_right})
			// 		5'b10000: mode <= Song_PlayMode;
			// 		default:  mode <= PlayMode;
			// 	endcase
			// else if(mode == LearnMode		)
			// 	case ({pres_center, pres_up, pres_down, pres_left, pres_right})
			// 		5'b10000: mode <= Song_LearnMode;
			// 		default:  mode <= LearnMode	;
			// 	endcase
			// else if(mode == GameMode		)
			// 	case ({pres_center, pres_up, pres_down, pres_left, pres_right})
			// 		5'b10000: mode <= Song_GameMode;
			// 		default:  mode <= GameMode;
			// 	endcase
			// else if(mode == SettingMode		)
			// 	case ({pres_center, pres_up, pres_down, pres_left, pres_right})
			// 		5'b10000: mode <= ChooseModePage;
			// 		default:  mode <= SettingMode;
			// 	endcase
			else if(mode == Song_PlayMode 	)
				case ({pres_center, pres_up, pres_down, pres_left, pres_right})
					5'b10000: mode <= PlayMode;
					// 5'b01000: mode <= ChooseModePage;
					default:  mode <= Song_PlayMode;
				endcase
			else if(mode == Song_LearnMode	)
				case ({pres_center, pres_up, pres_down, pres_left, pres_right})
					5'b10000: mode <= LearnMode;
					// 5'b01000: mode <= ChooseModePage;
					default:  mode <= Song_LearnMode;
				endcase
			else if(mode == Song_GameMode	)
				case ({pres_center, pres_up, pres_down, pres_left, pres_right})
					5'b10000: mode <= GameMode;
					// 5'b01000: mode <= ChooseModePage;
					default:  mode <= Song_GameMode;
				endcase
			else 
				mode <= mode;
		end
	end

	//------------------Song Repertoire------------------//
	parameter 			song_per_page 	= 4;
	reg 				repertoire_page = 0;
	reg 	[1:0] 		page_song_id 	= 0;

	always @(posedge sys_clk or negedge rst_n) begin
		if(~rst_n) begin
			repertoire_page <= 1'b0;
			page_song_id 	<= 2'b00;
		end
		else begin // We only use left right down because center and up are chosen.
			if(mode == Song_PlayMode || mode == Song_LearnMode || mode == Song_GameMode) begin
				if(pres_left)
					page_song_id <= (page_song_id == 2'b00) ? 2'b00 : page_song_id - 1;
				else if(pres_right)
					page_song_id <= (page_song_id == 2'b11) ? 2'b11 : page_song_id + 1;
				else if(pres_down)
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
endmodule