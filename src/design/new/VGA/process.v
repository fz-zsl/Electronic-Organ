`timescale 1ns / 1ps
`include "VGAparams.v"

module process(
    input   wire            clk     ,
    input   wire            showProcess ,
    input   wire    [9:0]   pos_x       ,
    input   wire    [9:0]   pos_y       ,
    input   wire    [9:0]   duration    ,
    output  [23:0]          pos_data    
);
    reg     [19:0]          cnt;
    reg     [19:0]          counter;
    reg                    slow_clk;
    parameter               half_period    =   10000;
    always @(posedge clk or posedge showProcess)begin
        if(showProcess) begin
            cnt <= 20'b0;
            slow_clk <= 1'b0;
        end
        else begin
            if(cnt == half_period - 1) begin
                cnt <= 20'b0;
                slow_clk <= ~slow_clk;
            end
            else begin
                cnt <= cnt +1;
                slow_clk <= slow_clk;
            end
        end
    end
    
    always @(posedge slow_clk or posedge showProcess)begin
        if(showProcess)
            counter <= 20'b0;
        else begin
             if(counter == duration * `SAMPLE_INTERVAL  - 1) 
                 counter <= 20'b0;
             else 
                 counter <= counter +1;
        end
    end

    wire  [23:0]    process_color;
    wire  [29:0]    red_color;
    wire  [29:0]    green_color;
    assign  red_color  = 30'd256 - (counter * 30'd256) / (duration * `SAMPLE_INTERVAL);
    assign  green_color = (counter * 30'd256) / (duration * `SAMPLE_INTERVAL);
    assign  process_color = {red_color[7:0], green_color[7:0], 8'h00};

    wire enable;
    assign enable = (pos_x * duration * `SAMPLE_INTERVAL <= counter * 640) ? 1'b1 : 1'b0;
    assign pos_data =  (enable) ? process_color: 24'hFFFFFF;
endmodule
