module  vga_top (     
    input   wire            sys_clk     ,   //Input Clock: 100 MHz 
    input   wire            sys_rst_n   ,   //Reset Signal: Low active
    
    input           [7:0]   key         ,
    input   wire	[7:0]	mode	    ,
    input   wire    [7:0]   next_mode   ,     
    input   wire    [1:0]   shift       ,
    
    input   wire            repertoire_page,
    input   wire    [1:0]   page_song_id,
    
    input   wire            output_ready,
    input   wire    [9:0]   data_out    ,
    
    input   wire    [2:0]   setting_cnt ,
    
    output  wire    [9:0]   vga_bottom_pm,
    output  wire    [9:0]   vga_bottom_lm,
    output  wire    [9:0]   vga_bottom_gm,
    output  wire            hsync       ,   //Horizontal Sync Signal
    output  wire            vsync       ,   //Vertical Sync Signal
    output  wire    [23:0]  color           //RGB Data
);

wire               vga_clk ; 
wire               rst_n   ; 
wire    [9:0]      pos_x   ; 
wire    [9:0]      pos_y   ; 
wire    [23:0]     pix_data; 


//------------- clk_gen_inst ------------- 
clk_wiz_0 clk_gen_inst (
    .clk_in1         (sys_clk    ), 
    .resetn          (sys_rst_n  ), 
    .clk_out1        (vga_clk    )
);  
    
//------------- vga_ctrl_inst ------------- 
vga_ctrl  vga_ctrl_inst(     
    .vga_clk        (vga_clk    ),  
    .sys_rst_n      (sys_rst_n  ), 
    .pix_data       (pix_data   ),  
    .pos_x          (pos_x      ),  
    .pos_y          (pos_y      ),  
    .hsync          (hsync      ),  
    .vsync          (vsync      ),  
    .rgb            (color      )
 );
 
//------------- vga_pic_inst ------------- 
vga_pic vga_pic_inst 
(     .vga_clk          (vga_clk    ), 
      .rst_n            (sys_rst_n  ), 
      .pos_x            (pos_x      ), 
      .pos_y            (pos_y      ), 
      
      .mode             (mode       ),
      .next_mode        (next_mode  ),
      
      .note             (key        ),
      .shift            (shift      ),
      
      .repertoire_page  (repertoire_page),
      .page_song_id     (page_song_id),
      //Play Mode
      .output_ready     (output_ready),
      .data_out         (data_out),
      .vga_bottom_pm    (vga_bottom_pm),
      //Learn Mode
      .vga_bottom_lm    (vga_bottom_lm),
      .vga_bottom_gm    (vga_bottom_gm),
      
      .setting_cnt      (setting_cnt ),
      
      .pos_data         (pix_data   )  
 );

 endmodule
