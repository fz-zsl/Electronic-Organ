`timescale 1ns / 1ps
`include "MemoryPara.v"
module Internal_NoteMemory_1(
    input wire                  clk,
    input wire                  rst_n,
    input wire                  write_en,
    input wire                  read_en,
    input wire                  read_rst,
    input wire [`DATA_WIDTH-1:0] data_in,
    output reg [`DATA_WIDTH-1:0] data_out,
    output reg                  output_ready
);

wire [`DATA_WIDTH-1:0]        memory  [0:15]; // memory for notes and octave     
reg  [4:0]     count;                      // number of notes in memory
reg  [4:0]     read_pointer;               // position of read pointer

assign memory[0] = 10'b0000000100;
assign memory[1] = 10'b0001000000;
assign memory[2] = 10'b0010000000;
assign memory[3] = 10'b0001000000;
assign memory[4] = 10'b0000100000;
assign memory[5] = 10'b0000010000;
assign memory[6] = 10'b0000001000;
assign memory[7] = 10'b0000000100;
assign memory[8] = 10'b0001000000;
assign memory[9] = 10'b0000100000;
assign memory[10] = 10'b0000010000;
assign memory[11] = 10'b0000001000;
assign memory[12] = 10'b0001000000;
assign memory[13] = 10'b0000100000;
assign memory[14] = 10'b0000010000;
assign memory[15] = 10'b0000001000;

initial begin
    count = 16;
    read_pointer = 0;
end

always @(posedge clk)
begin
    // reset whole memory module
    if(~rst_n || read_rst) begin
        read_pointer <= 0;
        output_ready <= 0; 
    end else begin
        // write to data_out, one note at a time
        if(read_en) begin
            // check is output is complete
            if(read_pointer < count) begin
                data_out <= memory[read_pointer];
                read_pointer <= read_pointer + 1;
                output_ready <= 1;
            end else begin
                output_ready <= 0;
            end
        end
    end
end
endmodule
