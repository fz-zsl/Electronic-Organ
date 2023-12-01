`timescale 1ns / 1ps
`include "MemoryPara.v"
module Internal_MusicMemory_1(
    input wire                  clk,
    input wire                  rst_n,
    input wire                  write_en,
    input wire                  read_en,
    input wire                  read_rst,
    input wire [`DATA_WIDTH-1:0] data_in,
    output reg [`DATA_WIDTH-1:0] data_out,
    output reg                  output_ready
);

wire [`DATA_WIDTH-1:0]    memory  [0:31]; // memory for notes and octave
reg [5:0]     count;                      // number of notes in memory
reg [5:0]     read_pointer;               // position of read pointer
reg [`MAX_SAMPLE_INTERVAL-1:0]     read_sample_counter;

assign memory[0] = 10'b0000000100;
assign memory[1] = 10'b0000000100;
assign memory[2] = 10'b0001000000;
assign memory[3] = 10'b0001000000;
assign memory[4] = 10'b0010000000;
assign memory[5] = 10'b0010000000;
assign memory[6] = 10'b0001000000;
assign memory[7] = 10'b0001000000;
assign memory[8] = 10'b0000100000;
assign memory[9] = 10'b0000100000;
assign memory[10] = 10'b0000010000;
assign memory[11] = 10'b0000010000;
assign memory[12] = 10'b0000001000;
assign memory[13] = 10'b0000001000;
assign memory[14] = 10'b0000000100;
assign memory[15] = 10'b0000000100;
assign memory[16] = 10'b0001000000;
assign memory[17] = 10'b0001000000;
assign memory[18] = 10'b0000100000;
assign memory[19] = 10'b0000100000;
assign memory[20] = 10'b0000010000;
assign memory[21] = 10'b0000010000;
assign memory[22] = 10'b0000001000;
assign memory[23] = 10'b0000001000;
assign memory[24] = 10'b0001000000;
assign memory[25] = 10'b0001000000;
assign memory[26] = 10'b0000100000;
assign memory[27] = 10'b0000100000;
assign memory[28] = 10'b0000010000;
assign memory[29] = 10'b0000010000;
assign memory[30] = 10'b0000001000;
assign memory[31] = 10'b0000001000;

// Initialize internal signals
initial begin
    count = 32;
    read_pointer = 0;
    read_sample_counter = 1;
end

// Storage and output control logic
always @(posedge clk) begin
    if (~rst_n || read_rst) begin
        read_pointer <= 0;
        output_ready <= 0;
        read_sample_counter <= 1;
    end else begin
        // Output data sequentially when output_enable is asserted
        if (read_en) begin
            if(count > 0 && read_pointer < count) begin
                output_ready <= 1;
                data_out <= memory[read_pointer];
                read_sample_counter <= read_sample_counter + 1;
                if (read_sample_counter == `SAMPLE_INTERVAL) begin
                    read_sample_counter <= 1;
                    read_pointer <= read_pointer + 1;
                end
            end else begin
                output_ready <= 0;
            end
        end    
    end
end

endmodule