module PlayMode(
    input                       clk,
    input                       rst_n,
    input                       output_ready,
    input [9:0]                 data_out,
    output                      read_en,
    output	                    pwm,
    output                      sd
    );
    
    wire    [9:0]                       data_temp;
    assign data_temp = (rst_n & output_ready) ? data_out : 9'b0;
    assign read_en = rst_n;
    
    //Generatee VGA clock to match the vga display.
    wire    vga_clk;
    clk_wiz_0 clk_wiz_inst(
        .resetn     (rst_n),
        .clk_in1    (clk),
        .clk_out1   (vga_clk)
    );
    parameter  period           =   100000;
    reg        read_flag                  ;
    reg [19:0] count                      ;
    
    always @(posedge vga_clk or negedge rst_n) begin
        if(~rst_n) begin
            count <= 20'b0;
            read_flag <= 1'b0;
        end
        else if (count == period - 1) begin
            count <= 20'b0;
            read_flag <= 1'b1;
        end
        else begin
            count <= count + 20'b1;
            read_flag <= 1'b0;
        end
    end
    //Used to shift the note
    reg     [`DISPLAY_LENGTH - 1: 0]    buffer_sound [7:0];
    
    always @(posedge vga_clk or negedge rst_n) begin
        if(~rst_n) begin
            {buffer_sound[0]} <= `DISPLAY_LENGTH'b0;
            {buffer_sound[1]} <= `DISPLAY_LENGTH'b0;
            {buffer_sound[2]} <= `DISPLAY_LENGTH'b0;
            {buffer_sound[3]} <= `DISPLAY_LENGTH'b0;
            {buffer_sound[4]} <= `DISPLAY_LENGTH'b0;
            {buffer_sound[5]} <= `DISPLAY_LENGTH'b0;
            {buffer_sound[6]} <= `DISPLAY_LENGTH'b0;
            {buffer_sound[7]} <= `DISPLAY_LENGTH'b0;
        end
        else begin
            if(read_flag == 1'b1) begin
                {buffer_sound[0]} <= {buffer_sound[0][`DISPLAY_LENGTH-2:0], data_temp[2]};//C
                {buffer_sound[1]} <= {buffer_sound[1][`DISPLAY_LENGTH-2:0], data_temp[3]};//D
                {buffer_sound[2]} <= {buffer_sound[2][`DISPLAY_LENGTH-2:0], data_temp[4]};//E
                {buffer_sound[3]} <= {buffer_sound[3][`DISPLAY_LENGTH-2:0], data_temp[5]};//F
                {buffer_sound[4]} <= {buffer_sound[4][`DISPLAY_LENGTH-2:0], data_temp[6]};//G
                {buffer_sound[5]} <= {buffer_sound[5][`DISPLAY_LENGTH-2:0], data_temp[7]};//A
                {buffer_sound[6]} <= {buffer_sound[6][`DISPLAY_LENGTH-2:0], data_temp[8]};//B
                {buffer_sound[7]} <= {buffer_sound[7][`DISPLAY_LENGTH-2:0], data_temp[9]};//C
            end
        end
    end

    SoundTop SoundTop_inst_play(
            .clk          (clk               ),
            .rst_n        (rst_n             ),
            .shift        (data_temp[1:0]    ),
            .notes        ({buffer_sound[7][`DISPLAY_LENGTH-1]
                           ,buffer_sound[6][`DISPLAY_LENGTH-1]
                           ,buffer_sound[5][`DISPLAY_LENGTH-1]
                           ,buffer_sound[4][`DISPLAY_LENGTH-1]
                           ,buffer_sound[3][`DISPLAY_LENGTH-1]
                           ,buffer_sound[2][`DISPLAY_LENGTH-1]
                           ,buffer_sound[1][`DISPLAY_LENGTH-1]
                           ,buffer_sound[0][`DISPLAY_LENGTH-1]}),
            .pwm          (pwm               ),
            .sd           (sd                )
    );
endmodule