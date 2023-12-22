`include "TopParams.v"
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
	input               recording,
	input               delete,
	output 	[7:0]   	LED,
	output	[7:0]		Debug_LED,	
	output	[7:0]		tub_sel,
    output  [7:0]       tub_data1,
    output  [7:0]       tub_data2,
	
	//Output for Sound
	output	    reg			            pwm,
	output	    reg			            sd,
	
	//Output for VGA
	output      wire                    hsync       ,   //Horizontal Sync Signal
    output      wire                    vsync       ,   //Vertical Sync Signal
    output      wire        [3:0]       color_red   ,   //RGB Red data
    output      wire        [3:0]       color_green ,   //RGB Green data
    output      wire        [3:0]       color_blue      //RGB Blue data
);  
    //------------------Clk Divider------------------//
	wire slow_clk;
	ClkDivider ClkDivider_inst(
		.sys_clk	(sys_clk	),
		.rst_n		(rst_n		),
		.slow_clk	(slow_clk	)
	);

	//------------------Set keys------------------//
	reg [2:0] perm [7:0];
	reg [2:0] perm_conf [7:0];
	reg [2:0] setting_cnt;
	initial begin
		setting_cnt  = 3'b000;
		perm_conf[0] = 3'b000;
		perm_conf[1] = 3'b001;
		perm_conf[2] = 3'b010;
		perm_conf[3] = 3'b011;
		perm_conf[4] = 3'b100;
		perm_conf[5] = 3'b101;
		perm_conf[6] = 3'b110;
		perm_conf[7] = 3'b111;
	end

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
	
	wire                     press_recording;
	KeyDebouncer recordDebouncer(
	   .slow_clk	   (slow_clk			),
       .rst_n          (rst_n           	),
       .but_in         (recording			),
       .but_active     (press_recording    	)
	);
	
	wire                     press_delete;
    KeyDebouncer deleteDebouncer(
           .slow_clk       (slow_clk        ),
           .rst_n          (rst_n           ),
           .but_in         (delete			),
           .but_active     (press_delete    )
    );

	//------------------Finite State Machine-----------------//
	`include "TopParams.v";
	reg		[7:0]		mode	= `WelcomePage;
	reg		[7:0]		next_mode;
	assign 	LED = mode;
	always @(posedge slow_clk or negedge rst_n) begin
		if (~rst_n) begin
			mode <= `WelcomePage;
		end
		else begin
			if (mode == `WelcomePage  ) begin
				case ({pose_center, pose_up, pose_down, pose_left, pose_right, pose_esc})
				    6'b100000: begin
						mode <= `ChooseModePage;
						next_mode <= `FreeMode;
					end
					default:  mode <= `WelcomePage;
				endcase
			end
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
				if (setting_cnt == 3'b111 && perm[0] != 0) begin
					perm_conf[0] <= perm[0];
					perm_conf[1] <= perm[1];
					perm_conf[2] <= perm[2];
					perm_conf[3] <= perm[3];
					perm_conf[4] <= perm[4];
					perm_conf[5] <= perm[5];
					perm_conf[6] <= perm[6];
					perm_conf[7] <= perm[7];
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

	//------------------Tub Display------------------//
	`include "TubParams.v";
	wire tub_en = (mode == `FreeMode || mode == `LearnMode || mode == `GameMode || mode == `PlayMode
					|| mode == `Song_PlayMode || mode == `Song_LearnMode || mode == `Song_GameMode);
	reg [7:0] tub_in7, tub_in6, tub_in5, tub_in4, tub_in3, tub_in2, tub_in1, tub_in0;
	TubDisplay TubDisplay_inst(
		.sys_clk	(sys_clk	),
		.rst_n		(rst_n		),
		.data7		(tub_in7	),
		.data6		(tub_in6	),
		.data5		(tub_in5	),
		.data4		(tub_in4	),
		.data3		(tub_in3	),
		.data2		(tub_in2	),
		.data1		(tub_in1	),
		.data0		(tub_in0	),
		.en			(tub_en		),
		.tub_sel	(tub_sel	),
		.tub_data1	(tub_data1	),
		.tub_data2	(tub_data2	)
	);
	always @(posedge slow_clk or negedge rst_n) begin
		if (~rst_n) begin
			tub_in7 <= `tub_H;	tub_in6 <= `tub_E;	tub_in5 <= `tub_L;	tub_in4 <= `tub_L;
			tub_in3 <= `tub_O;	tub_in2 <= `tub_nil;tub_in1 <= `tub_nil;tub_in0 <= `tub_nil;
		end
		else if (mode == `WelcomePage) begin
			tub_in7 <= `tub_H;	tub_in6 <= `tub_E;	tub_in5 <= `tub_L;	tub_in4 <= `tub_L;
			tub_in3 <= `tub_O;	tub_in2 <= `tub_nil;tub_in1 <= `tub_nil;tub_in0 <= `tub_nil;
		end
		else if (mode == `ChooseModePage) begin
		    tub_in7 <= `tub_C;	tub_in6 <= `tub_H;	tub_in5 <= `tub_O;	tub_in4 <= `tub_O;
            tub_in3 <= `tub_S;  tub_in2 <= `tub_E;  tub_in1 <= `tub_nil;tub_in0 <= `tub_nil;
        end
		else if (mode == `Song_GameMode || mode == `Song_LearnMode || mode == `Song_PlayMode
				|| mode == `GameMode || mode == `LearnMode || mode == `PlayMode) begin
			tub_in7 <= `tub_S;	tub_in6 <= `tub_O;	tub_in5 <= `tub_N;	tub_in4 <= `tub_G;
			tub_in3 <= `tub_nil;tub_in2 <= `tub_nil;tub_in1 <= `tub_0;
			case (visible_song_id)
				3'b000: tub_in0 <= `tub_1;
				3'b001: tub_in0 <= `tub_2;
				3'b010: tub_in0 <= `tub_3;
				3'b011: tub_in0 <= `tub_4;
				3'b100: tub_in0 <= `tub_5;
				3'b101: tub_in0 <= `tub_6;
				3'b110: tub_in0 <= `tub_7;
				3'b111: tub_in0 <= `tub_8;
				default: tub_in0 <= `tub_0;
			endcase
		end
		else begin
		  tub_in7 <= `tub_nil; tub_in6 <= `tub_nil; tub_in5 <= `tub_nil; tub_in4 <= `tub_nil;
          tub_in3 <= `tub_nil; tub_in2 <= `tub_nil; tub_in1 <= `tub_nil; tub_in0 <= `tub_nil;
        end
	end

	

	//------------------Song Repertoire------------------//
	// parameter 			song_per_page 	= 4;
	reg 				repertoire_page = 0;
	reg 	[1:0] 		page_song_id 	= 0;
    //There is a problem here
	always @(posedge slow_clk or negedge rst_n) begin
		if(~rst_n) begin
			repertoire_page <= 1'b0;
			page_song_id 	<= 2'b00;
		end
		else begin
			if(mode == `Song_PlayMode || mode == `Song_LearnMode || mode == `Song_GameMode) begin
				if(pose_up) begin
					page_song_id <= (page_song_id == 2'b00) ? 2'b11 : page_song_id - 1;
                    repertoire_page <= repertoire_page;
                end
				else if(pose_down) begin
					page_song_id <= (page_song_id == 2'b11) ? 2'b00 : page_song_id + 1;
                    repertoire_page <= repertoire_page;
                end
				else if(pose_left || pose_right) begin
				    page_song_id <= page_song_id;
					repertoire_page <= ~repertoire_page;
			    end
				else begin
					page_song_id <= page_song_id;
					repertoire_page <= repertoire_page;
				end
			end
		end
	end

	wire   [2:0] 	   visible_song_id;
	wire   [1:0]       octave;
	wire               pwm_fm;
	wire               sd_fm;
	assign  visible_song_id = {repertoire_page, page_song_id};
      
    //------------------Memory------------------//
    reg                       read_en;
    wire                      read_rst = 0;
    wire  [3:0]               select;
    wire  [9:0]               data_out;
    wire                      output_ready;
    wire                      full_flag;      
    wire  [3:0]               count;
    wire  [3:0]               next;
    wire  [9:0]               duration;
    wire  [8:0]               unit_status;
    
	reg [97:0] song_name [0:8];
	reg [97:0] visible_song_name [0:7];
	reg [3:0]  real_song_id [0:7];

	always @* begin
	    visible_song_name[0] = song_name[0];
	    real_song_id[0] = 0;
	    visible_song_name[1] = song_name[1];
	    real_song_id[1] = 1;
	    visible_song_name[2] = song_name[2];
	    real_song_id[2] = 2;
	    visible_song_name[3] = song_name[3];
	    real_song_id[3] = 3;
	    visible_song_name[4] = song_name[4];
	    real_song_id[4] = 4;
	    case (unit_status[8:5])
	        4'b0000:
	            begin
	                visible_song_name[5] = 98'b0;
	                real_song_id[5] = 0;
	                visible_song_name[6] = 98'b0;
	                real_song_id[6] = 0;
	                visible_song_name[7] = 98'b0;
	                real_song_id[7] = 0;
	            end
	        4'b0001:
	            begin
	                visible_song_name[5] = song_name[5];
	                real_song_id[5] = 5;
	                visible_song_name[6] = 98'b0;
	                real_song_id[6] = 0;
	                visible_song_name[7] = 98'b0;
	                real_song_id[7] = 0;
	            end
	        4'b0011:
	            begin
	                visible_song_name[5] = song_name[5];
	                real_song_id[5] = 5;
	                visible_song_name[6] = song_name[6];
	                real_song_id[6] = 6;
	                visible_song_name[7] = 98'b0;
	                real_song_id[7] = 0;
	            end
	        4'b0111:
	            begin
	                visible_song_name[5] = song_name[5];
	                real_song_id[5] = 5;
	                visible_song_name[6] = song_name[6];
	                real_song_id[6] = 6;
	                visible_song_name[7] = song_name[7];
	                real_song_id[7] = 7;
	            end
	        4'b1110:
	            begin
	                visible_song_name[5] = song_name[6];
	                real_song_id[5] = 6;
	                visible_song_name[6] = song_name[7];
	                real_song_id[6] = 7;
	                visible_song_name[7] = song_name[8];
	                real_song_id[7] = 8;
	            end
	        4'b1101:
	            begin
	                visible_song_name[5] = song_name[5];
	                real_song_id[5] = 5;
	                visible_song_name[6] = song_name[7];
	                real_song_id[6] = 7;
	                visible_song_name[7] = song_name[8];
	                real_song_id[7] = 8;
	            end
	        4'b1011:
	            begin
	                visible_song_name[5] = song_name[5];
	                real_song_id[5] = 5;
	                visible_song_name[6] = song_name[6];
	                real_song_id[6] = 6;
	                visible_song_name[7] = song_name[8];
	                real_song_id[7] = 8;
	            end
	         default:
	            begin
	                visible_song_name[5] = 98'b0;
	                real_song_id[5] = 0;
	                visible_song_name[6] = 98'b0;
	                real_song_id[6] = 0;
	                visible_song_name[7] = 98'b0;
	                real_song_id[7] = 0;
	             end
	    endcase
	end

	assign select = real_song_id[visible_song_id];


    MemoryBlock MemoryBlock_inst(
        .clk                    (sys_clk),
        .rst_n                  (rst_n),
        .write_en               (press_recording),
        .read_en                (read_en),
        .read_rst               (read_rst),
        .current_state          (mode),
        .select                 (select),
        .data_in                ({pres_buts[0], pres_buts[1], pres_buts[2], pres_buts[3], pres_buts[4], pres_buts[5], pres_buts[6], pres_buts[7], octave}),
        .save                   (pres_right),
        .discard                (pres_left),
        .delete                 (press_delete),
        .data_out               (data_out),
        .output_ready           (output_ready),
        .full_flag              (full_flag),
        .count                  (count),
        .next                   (next),
        .duration               (duration),
        .unit_status            (unit_status)
    );
    
	//------------------Free Mode------------------//
    FreeMode FreeMode_inst(
        .clk                    (sys_clk            ),
        .rst_n                  (mode == `FreeMode| mode == `LearnMode),
        .buts                   (pres_buts          ),
        .but_up                 (pose_up            ),
        .but_center             (pose_center        ),
        .but_down               (pose_down          ),
        .pwm                    (pwm_fm             ),
        .sd                     (sd_fm              ),
        .octave                 (octave             )
    );
    
    //------------------Play Mode------------------//
    wire pwm_pm;
    wire sd_pm;
    wire read_en_pm;
    wire [9:0] vga_bottom_pm;
    PlayMode PlayMode_inst(
        .clk                (sys_clk),
        .isMode             (mode == `PlayMode),
        .vga_bottom_pm      (vga_bottom_pm),
        .read_en            (read_en_pm),
        .pwm                (pwm_pm),
        .sd                 (sd_pm)
    );
    
    //------------------Learn Mode------------------//
    wire read_en_lm;
    wire [9:0] vga_bottom_lm;
    LearnMode LearnMode_inst(
        .clk(sys_clk),
        .rst_n(mode == `LearnMode),
        // .buts(pose_buts),
        .buts(pres_buts),
        .octave(octave),
        .data_out(vga_bottom_lm),
        .read_en(read_en_lm)
    );
    
    //------------------Game Mode------------------//
    wire pwm_gm;
    wire sd_gm;
    wire read_en_gm;
    wire [9:0] vga_bottom_gm;
    GameMode GameMode_inst(
        .clk(sys_clk),
        .rst_n(mode == `GameMode),
        .output_ready(output_ready),
        .data_out(data_out),
        .read_en(read_en_gm),
        .pwm(pwm_gm),
        .sd(sd_gm)
    );
	
	//------------------PWM Choose Panel------------------//
    always @* begin
        case(mode) 
            `PlayMode: begin pwm = pwm_pm; sd = sd_pm; read_en = read_en_pm; end
            `FreeMode: begin pwm = pwm_fm; sd = sd_fm; read_en = 0; end
            `LearnMode: begin pwm = pwm_fm; sd = sd_fm; read_en = read_en_lm; end
            `GameMode: begin pwm = pwm_gm; sd = sd_gm; read_en = read_en_gm; end
            default: begin pwm = 0; sd = 0; read_en = 0; end
        endcase
    end

    //------------------VGA_module------------------//
    wire        [23:0]      color;
    vga_top vga_inst(
        //Input port
        .sys_clk     (sys_clk),  //Input Clock: 100 MHz 
        .sys_rst_n   (rst_n),   //Reset Signal: Low active 
        .key         (pres_buts),
        .mode        (mode),
        .next_mode   (next_mode),
        .shift       (octave),
        .setting_cnt (setting_cnt),
        //Song repertoire
        .repertoire_page (repertoire_page),
        .page_song_id    (page_song_id),
        
        //Playmode inputs and outputs
        .output_ready    (output_ready),//input from memory
        .data_out        (data_out), //input from memory
        .vga_bottom_pm   (vga_bottom_pm), //output from vga
        .vga_bottom_lm   (vga_bottom_lm),
        .vga_bottom_gm   (vga_bottom_gm),
        
        //Output port
        .hsync       (hsync),   //Horizontal Sync Signal
        .vsync       (vsync),   //Vertical Sync Signal
        .color       (color)    //RGB Data
    );
    
    
    assign color_red = color[23:20];
    assign color_green = color[15:12];
    assign color_blue = color[7:4];
    
    //------------------Debug Output------------------//  
    assign Debug_LED = {data_out[2], data_out[3], data_out[4], data_out[5], data_out[6], repertoire_page, page_song_id[1], page_song_id[0]};
    
    
endmodule