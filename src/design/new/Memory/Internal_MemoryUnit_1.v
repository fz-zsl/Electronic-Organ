`timescale 1ns / 1ps
`include "MemoryPara.v"
module Internal_MemoryUnit_1(
    input wire                          clk,
    input wire                          rst_n,
    input wire                          write_en,
    input wire                          read_en,
    input wire                          read_rst,
    input wire [`STATE_WIDTH-1:0]        current_state,  // 00 for autoplay, 01 for learning, 10 and 11 other state
    input wire [`DATA_WIDTH-1:0]         data_in,
    output reg [`DATA_WIDTH-1:0]         data_out,
    output reg                          output_ready,
    output wire [`MAX_DEPTH_BIT-1:0]  duration
);

wire [`DATA_WIDTH-1:0]   note_data_out;
wire [`DATA_WIDTH-1:0]   music_data_out;
wire                    note_output_ready;
wire                    music_output_ready;
wire                    read_rst_in;

Internal_NoteMemory_1 Note(clk, rst_n, write_en, read_en, read_rst_in, data_in, note_data_out, note_output_ready);
Internal_MusicMemory_1 Music(clk, rst_n, write_en, read_en, read_rst_in, data_in, music_data_out, music_output_ready, duration);

assign read_rst_in = ((current_state == `AUTOPLAY | current_state == `LEARNING | current_state == `GAME) ? 0 : 1) | read_rst;

always @(*)
begin
    case(current_state)
        `AUTOPLAY, `GAME, `LEARNING: 
        begin
            data_out = music_data_out; 
            output_ready = music_output_ready;
        end
        /*`LEARNING:
        begin
            data_out = note_data_out; 
            output_ready = note_output_ready;
        end*/
        default:
        begin
            data_out = 0;
            output_ready = 0;
        end
    endcase
end
endmodule
