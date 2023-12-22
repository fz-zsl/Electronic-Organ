`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/07 15:47:40
// Design Name: 
// Module Name: vga_pic
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

//This modules should be reshaped to a large finite state machine. 
`include "VGAparams.v"
module vga_pic(
    input   wire            vga_clk     ,
    input   wire            rst_n       ,
    input   wire    [9:0]   pos_x       ,
    input   wire    [9:0]   pos_y       ,
    
    input   wire	[7:0]	mode	    ,
    input   wire    [7:0]   next_mode   ,  
    input   wire    [7:0]   note        ,
    input   wire    [1:0]   shift       ,
    
    //Repertoire inputs
    input   wire            repertoire_page,
    input   wire    [1:0]   page_song_id,
    
    //Playmode inputs and outputs
    input   wire            output_ready,
    input   wire    [9:0]   data_out    ,
    output  wire    [9:0]   vga_bottom_pm,
    
    //Learnmode inputs and outputs
    
    //Setting Mode inputs
    input   wire    [2:0]   setting_cnt ,
    //Key input is note[7:0]
    output  wire    [9:0]   vga_bottom_lm,
    output  wire    [9:0]   vga_bottom_gm,
    
    output  wire    [23:0]  pos_data      
    );
    
    wire             enable_welcomepage;
    assign enable_welcomepage = (mode == `WelcomePage)? 1'b1:1'b0;
    wire   [23:0]    output_welcomepage;
    WelcomePage welcome_page_inst(
            .vga_clk     (vga_clk),
            .rst_n       (rst_n),
            .pos_x       (pos_x),
            .pos_y       (pos_y),
            .pos_data    (output_welcomepage) 
    );
    
    wire             enable_choosepanel;
    assign enable_choosepanel = (mode == `ChooseModePage)? 1'b1 : 1'b0;
    wire   [23:0]    output_choosepanel;
    ChoosePanel ChooseMode_inst(
            .vga_clk     (vga_clk),
            .rst_n       (rst_n),
            .pos_x       (pos_x),
            .pos_y       (pos_y),
            .next_mode   (next_mode),
            .pos_data    (output_choosepanel)
    );
    
    wire             enable_freemode;
    assign enable_freemode = ((pos_y <= 384) && (mode == `FreeMode))? 1'b1: 1'b0;
    wire    [23:0]   output_freemode;
    FreeMode_vga freemode_vga_inst(
            .vga_clk     (vga_clk),
            .rst_n       ((mode == `FreeMode)),
            .pos_x       (pos_x),
            .pos_y       (pos_y),
            .note        (note),
            .shift       (shift),
            .pos_data    (output_freemode)
    );
    
    wire            enable_songchoosepanel;
    assign enable_songchoosepanel  = (mode == `Song_PlayMode || mode == `Song_LearnMode || mode == `Song_GameMode) ? 1'b1 : 1'b0;
    wire    [23:0]  output_songchoosepanel;
    SongChoosePanel_vga songchoosepanel_vga_inst(
            .vga_clk     (vga_clk),
            .rst_n       (rst_n),
            .pos_x       (pos_x),
            .pos_y       (pos_y),
            .repertoire_page (repertoire_page),
            .page_song_id    (page_song_id),
            .pos_data    (output_songchoosepanel) 
    );
    
    wire            enable_playmode;
    assign enable_playmode = ((pos_y <= 384) && (mode == `PlayMode))? 1'b1 : 1'b0;
    wire    [23:0]  output_playmode;
    Playmode_vga  playmode_vga_inst(
            .vga_clk     (vga_clk),
            .rst_n       ((mode == `PlayMode)),
            .pos_x       (pos_x),
            .pos_y       (pos_y),
            
            .note        (data_out[9:2]),//Input for note
            .shift       (data_out[1:0]),//Input for shift
            .output_ready(output_ready),//Input for determing whether the song ends.
            .vga_bottom  (vga_bottom_pm),//Output for the bottom of the blocks
            
            .pos_data    (output_playmode)//Output for vga
    );
    
    wire            enable_learnmode;
    assign enable_learnmode = ((pos_y <= 384) && (mode == `LearnMode )) ? 1'b1 : 1'b0;
    wire    [23:0]  output_learnmode;
    LearnMode_vga  learnmode_vga_inst(
            .vga_clk     (vga_clk),
            .rst_n       (mode == `LearnMode),
            .pos_x       (pos_x),
            .pos_y       (pos_y),
                
            .note        (data_out[9:2]),//Input for note
            .shift       (data_out[1:0]),//Input for shift
            .output_ready(output_ready),//Input for determing whether the song ends.
            .key         (note),//Input for user inputs
            .vga_bottom  (vga_bottom_lm),//Output for the bottom of the blocks
                
            .pos_data    (output_learnmode)//Output for vga
    );
    
    wire            enable_gamemode;
    assign enable_gamemode = ((pos_y <= 384) && (mode == `GameMode )) ? 1'b1 : 1'b0;
    wire    [23:0]  output_gamemode;
    GameMode_vga  gamemode_vga_inst(
            .vga_clk     (vga_clk),
            .rst_n       (mode == `GameMode),
            .pos_x       (pos_x),
            .pos_y       (pos_y),
                    
            .note        (data_out[9:2]),//Input for note
            .shift       (data_out[1:0]),//Input for shift
            .output_ready(output_ready),//Input for determing whether the song ends.
            .key         (note),//Input for user inputs
            .vga_bottom  (vga_bottom_gm),//Output for the bottom of the blocks
                    
            .pos_data    (output_gamemode)//Output for vga
    );
    
    wire     [23:0]      notes_data;
    wire                 notes_enable;
    assign notes_enable = ((pos_y >= 416) && (mode == `LearnMode || mode == `PlayMode || mode == `FreeMode || mode == `GameMode)) ? 1'b1 : 1'b0;
    notes_display notes_display_inst_1(
        .vga_clk     (vga_clk),
        .pos_x       (pos_x),
        .pos_y       (pos_y),
        .pos_data    (notes_data)
    );
    
    wire     [23:0]      output_settingmode;
    wire                 enable_settingmode;
    assign enable_settingmode = (mode == `SettingMode) ? 1'b1 : 1'b0;
    SettingMode_vga #(
        .start_point_y   (224)
    )settingmode_inst (
        .vga_clk     (vga_clk),
        .pos_x       (pos_x),
        .pos_y       (pos_y),
        .setting_cnt (setting_cnt),
        .pos_data    (output_settingmode)
    );


assign pos_data = (enable_welcomepage) ? output_welcomepage :
                 ((enable_choosepanel) ? output_choosepanel :
                 ((enable_freemode) ? output_freemode :
                 ((enable_songchoosepanel) ? output_songchoosepanel :
                 ((enable_playmode) ? output_playmode :
                 ((enable_learnmode) ? output_learnmode :
                 ((enable_gamemode) ? output_gamemode :
                 ((enable_settingmode) ? output_settingmode :
                 ((notes_enable) ? notes_data : 24'hFFFFFF ))))))));

endmodule                              
