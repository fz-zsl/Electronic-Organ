`timescale 1ns / 1ps
module top_temp(
    input                   clk,
    input                   rst_n,
    input                   read_en,
    input                   read_rst,
    output                  L1,
    output                  L2,
    output                  L3,
    output                  L4,
    output                  L5,
    output                  L6,
    output                  L7,
    output                  L8,
    output                  pwm,
    output                  sd,
    output                  output_ready
);

reg                                 write_en;
reg     [STATE_WIDTH-1:0]           current_state;
reg     [MAX_MEMORY_BIT-1:0]        select;         // select memory unit
reg     [DATA_WIDTH-1:0]            data_in;
wire    [DATA_WIDTH-1:0]            data_out;
wire                                name_info;
wire                                full_flag;

wire       [1:0]        shift;
wire       [7:0]        notes;

MemoryBlock dut_1(
    .clk(clk),
    .rst_n(rst_n),
    .write_en(write_en),
    .read_en(read_en),
    .read_rst(read_rst),
    .current_state(current_state),
    .select(select),
    .data_in(data_in),
    .data_out(data_out),
    .name_info(name_info),
    .output_ready(output_ready),
    .full_flag(full_flag)
);

SoundTop dut_2(
    .clk(clk),
    .rst_n(rst_n),
    .shift(shift),
    .notes(notes),
    .pwm(pwm),
    .sd(sd)
);

assign {notes, shift} = data_out;
assign L1 = data_out[2];
assign L2 = data_out[3];
assign L3 = data_out[4];
assign L4 = data_out[5];
assign L5 = data_out[6];
assign L6 = data_out[7];
assign L7 = data_out[8];
assign L8 = data_out[9];

initial begin
    write_en = 1'b0;
    select = 3'b000;
    current_state = 3'b000;
end
endmodule
