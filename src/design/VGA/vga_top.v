module  vga_top (     
    input   wire            sys_clk     ,   //Input Clock: 100 MHz 
    input   wire            sys_rst_n   ,   //Reset Signal: Low active
    input           [7:0]   key         ,
 
    output  wire            hsync       ,   //Horizontal Sync Signal
    output  wire            vsync       ,   //Vertical Sync Signal
    output  wire    [23:0]  color           //RGB Data
);

wire               vga_clk ; 
wire               rst_n   ; 
wire    [9:0]      pos_x   ; 
wire    [9:0]      pos_y   ; 
wire    [23:0]     pix_data; 
wire               locked  ;

assign  rst_n = (sys_rst_n & locked);

//------------- clk_gen_inst ------------- 
clk_gen clk_gen_inst (
    .clk            (sys_clk    ), 
    .rst_n          (sys_rst_n  ), 
    .vga_clk        (vga_clk    )
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
(     .vga_clk      (vga_clk    ), 
      .sys_rst_n    (rst_n      ), 
      .pos_x        (pos_x      ), 
      .pos_y        (pos_y      ), 
      .note         (key        ),
      .pos_data     (pix_data   )  
 );

 endmodule
