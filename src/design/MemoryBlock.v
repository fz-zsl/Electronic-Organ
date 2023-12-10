`timescale 1ns / 1ps
`include "MemoryPara.v"
module MemoryBlock(
    input wire                      clk,
    input wire                      rst_n,
    input wire                      write_en,
    input wire                      read_en,
    input wire                      read_rst,
    input wire [`STATE_WIDTH-1:0]   current_state,  // code for current state
    input wire [`MAX_MEMORY_BIT:0]  select,         // select memory unit
    input wire [`DATA_WIDTH-1:0]    data_in,
    input wire                      save,
    input wire                      discard,
    input wire                      delete,
    output wire [`DATA_WIDTH-1:0]   data_out,
    output wire                      output_ready,
    output wire                      full_flag,      // 1 if full, 0 otherwise
    output reg  [`MAX_MEMORY_BIT:0]  count,
    output reg  [`MAX_MEMORY_BIT:0]  next,
    output wire [`MAX_DEPTH_BIT-1:0] duration,
    output reg  [`MAX_MEMORY:0]      unit_status
);

wire                        unit_write_en [0:8];
wire [`DATA_WIDTH-1:0]      unit_data_out [0:8];
wire                        unit_output_ready [0:8];
wire [`MAX_DEPTH_BIT-1:0]   unit_duration [0:8];
wire                        unit_rst_n [0:8];
reg                         custom_rst_n [0:8];


Internal_MemoryUnit_1 unit0(clk, unit_rst_n[0], unit_write_en[0], read_en, read_rst, current_state, data_in, unit_data_out[0], unit_output_ready[0], unit_duration[0]);
Internal_MemoryUnit_2 unit1(clk, unit_rst_n[1], unit_write_en[1], read_en, read_rst, current_state, data_in, unit_data_out[1], unit_output_ready[1], unit_duration[1]);
Internal_MemoryUnit_3 unit2(clk, unit_rst_n[2], unit_write_en[2], read_en, read_rst, current_state, data_in, unit_data_out[2], unit_output_ready[2], unit_duration[2]);
Internal_MemoryUnit_4 unit3(clk, unit_rst_n[3], unit_write_en[3], read_en, read_rst, current_state, data_in, unit_data_out[3], unit_output_ready[3], unit_duration[3]);
Internal_MemoryUnit_5 unit4(clk, unit_rst_n[4], unit_write_en[4], read_en, read_rst, current_state, data_in, unit_data_out[4], unit_output_ready[4], unit_duration[4]);
MemoryUnit unit5(clk, unit_rst_n[5], unit_write_en[5], read_en, read_rst, current_state, data_in, unit_data_out[5], unit_output_ready[5], unit_duration[5]);
MemoryUnit unit6(clk, unit_rst_n[6], unit_write_en[6], read_en, read_rst, current_state, data_in, unit_data_out[6], unit_output_ready[6], unit_duration[6]);
MemoryUnit unit7(clk, unit_rst_n[7], unit_write_en[7], read_en, read_rst, current_state, data_in, unit_data_out[7], unit_output_ready[7], unit_duration[7]);
MemoryUnit unit8(clk, unit_rst_n[8], unit_write_en[8], read_en, read_rst, current_state, data_in, unit_data_out[8], unit_output_ready[8], unit_duration[8]);

assign unit_write_en[0] = write_en & (next == 0);
assign unit_write_en[1] = write_en & (next == 1);
assign unit_write_en[2] = write_en & (next == 2);
assign unit_write_en[3] = write_en & (next == 3);
assign unit_write_en[4] = write_en & (next == 4);
assign unit_write_en[5] = write_en & (next == 5);
assign unit_write_en[6] = write_en & (next == 6);
assign unit_write_en[7] = write_en & (next == 7);
assign unit_write_en[8] = write_en & (next == 8);
assign unit_rst_n[0] = rst_n & custom_rst_n[0] & ~(delete & (select == 0));
assign unit_rst_n[1] = rst_n & custom_rst_n[1] & ~(delete & (select == 1));
assign unit_rst_n[2] = rst_n & custom_rst_n[2] & ~(delete & (select == 2));
assign unit_rst_n[3] = rst_n & custom_rst_n[3] & ~(delete & (select == 3));
assign unit_rst_n[4] = rst_n & custom_rst_n[4] & ~(delete & (select == 4));
assign unit_rst_n[5] = rst_n & custom_rst_n[5] & ~(delete & (select == 5));
assign unit_rst_n[6] = rst_n & custom_rst_n[6] & ~(delete & (select == 6));
assign unit_rst_n[7] = rst_n & custom_rst_n[7] & ~(delete & (select == 7));
assign unit_rst_n[8] = rst_n & custom_rst_n[8] & ~(delete & (select == 8));

assign full_flag = (count == `MAX_MEMORY);
assign data_out = unit_data_out[select];
assign output_ready = unit_output_ready[select];
assign duration = unit_duration[select];

initial begin
    custom_rst_n[0] = 1;
    custom_rst_n[1] = 1;
    custom_rst_n[2] = 1;
    custom_rst_n[3] = 1;
    custom_rst_n[4] = 1;
    custom_rst_n[5] = 1;
    custom_rst_n[6] = 1;
    custom_rst_n[7] = 1;
    custom_rst_n[8] = 1;
end

always @(posedge save)
begin
    unit_status[next] <= 1;
    unit_status[(next  == `MAX_MEMORY ? `PRE_WRITTEN_COUNT : next + 1)] <= 0;
    custom_rst_n[(next  == `MAX_MEMORY ? `PRE_WRITTEN_COUNT : next + 1)] <= 0;
    next <= (next  == `MAX_MEMORY ? `PRE_WRITTEN_COUNT : next + 1);
    if(~full_flag) begin
        count <= count + 1;
    end
end

always @(negedge save)
begin
    custom_rst_n[next] <= 1;
end

always @(posedge discard)
begin
    custom_rst_n[next] <= 0;
end

always @(negedge discard)
begin
    custom_rst_n[next] <= 1;
end

always @(posedge clk) 
begin
    if(~rst_n) begin
        count <= `PRE_WRITTEN_COUNT;
        next <= `PRE_WRITTEN_COUNT;
        unit_status <= (1<<`PRE_WRITTEN_COUNT) - 1;
        custom_rst_n[0] <= 1;
        custom_rst_n[1] <= 1;
        custom_rst_n[2] <= 1;
        custom_rst_n[3] <= 1;
        custom_rst_n[4] <= 1;
        custom_rst_n[5] <= 1;
        custom_rst_n[6] <= 1;
        custom_rst_n[7] <= 1;
        custom_rst_n[8] <= 1;
    end
end

endmodule
