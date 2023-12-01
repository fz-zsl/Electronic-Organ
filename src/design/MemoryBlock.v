`timescale 1ns / 1ps
`include "MemoryPara.v"
module MemoryBlock(
    input wire                      clk,
    input wire                      rst_n,
    input wire                      write_en,
    input wire                      read_en,
    input wire                      read_rst,
    input wire [`STATE_WIDTH-1:0]    current_state,  // 00 for autoplay, 01 for learning, 10 and 11 other state
    input wire [`MAX_MEMORY_BIT-1:0] select,         // select memory unit
    input wire [`DATA_WIDTH-1:0]     data_in,
    output reg [`DATA_WIDTH-1:0]     data_out,
    output reg                      name_info,      // name of music
    output reg                      output_ready,
    output                           full_flag,      // 1 if full, 0 otherwise
    output reg  [`MAX_MEMORY_BIT:0]  count
);



wire                    unit0_write_en;
wire [`DATA_WIDTH-1:0]   unit0_data_out;
wire                    unit0_output_ready;
wire                    unit1_write_en;
wire [`DATA_WIDTH-1:0]   unit1_data_out;
wire                    unit1_output_ready;
wire                    unit2_write_en;
wire [`DATA_WIDTH-1:0]   unit2_data_out;
wire                    unit2_output_ready;
wire                    unit3_write_en;
wire [`DATA_WIDTH-1:0]   unit3_data_out;
wire                    unit3_output_ready;

Internal_MemoryUnit_1 unit0(clk, rst_n, unit0_write_en, read_en, read_rst, current_state, data_in, unit0_data_out, unit0_output_ready);
MemoryUnit unit1(clk, rst_n, unit1_write_en, read_en, read_rst, current_state, data_in, unit1_data_out, unit1_output_ready);
MemoryUnit unit2(clk, rst_n, unit2_write_en, read_en, read_rst, current_state, data_in, unit2_data_out, unit2_output_ready);
MemoryUnit unit3(clk, rst_n, unit3_write_en, read_en, read_rst, current_state, data_in, unit3_data_out, unit3_output_ready);

assign unit0_write_en = write_en & (count == 0);
assign unit1_write_en = write_en & (count == 1);
assign unit2_write_en = write_en & (count == 2);
assign unit3_write_en = write_en & (count == 3);
assign full_flag = (count == `MAX_MEMORY);

always@(*)
begin
    case(select)
        0: 
        begin
            data_out = unit0_data_out;
            output_ready = unit0_output_ready;
        end
        1: 
        begin
            data_out = unit1_data_out;
            output_ready = unit1_output_ready;
        end
        2: 
        begin
            data_out = unit2_data_out;
            output_ready = unit2_output_ready;
        end
        3: 
        begin
            data_out = unit3_data_out;
            output_ready = unit3_output_ready;
        end
        default:
        begin
            data_out = 0;
            output_ready = 0;
        end
    endcase
end

always @(negedge write_en)
begin
    if(~full_flag) begin
        count <= count + 1;
    end
end

always @(posedge clk) 
begin
    if(~rst_n) begin
        count <= `PRE_WRITTEN_COUNT;
    end
end

endmodule
