`timescale 1ns / 1ps
`include "MemoryPara.v"
module NoteMemory(
    input wire                  clk,
    input wire                  rst_n,
    input wire                  write_en,
    input wire                  read_en,
    input wire                  read_rst,
    input wire [`DATA_WIDTH-1:0] data_in,
    output reg [`DATA_WIDTH-1:0] data_out,
    output reg                  output_ready
);

reg [`DATA_WIDTH-1:0]        memory  [0:`MAX_DEPTH-1]; // memory for notes and octave
reg [`DATA_WIDTH-1:0]        last_note;                  // previous note received         
reg [`MAX_DEPTH_BIT-1:0]     count;                      // number of notes in memory
reg [`MAX_DEPTH_BIT-1:0]     read_pointer;               // position of read pointer
reg [`MAX_DEPTH_BIT-1:0]     write_pointer;              // position of write pointer
reg                         pre_write_en;               // previous state of write_en

initial begin
    last_note = 0;
    count = 0;
    read_pointer = 0;
    write_pointer = 0;
    pre_write_en = 0;
end

always @(posedge clk)
begin
    // reset whole memory module
    if(~rst_n) begin
        count <= 0;
        last_note <= 0;
        read_pointer <= 0;
        write_pointer <= 0;
        output_ready <= 0;
        pre_write_en <= 0;
        
    //reset the read pointer for a new reading operation
    end else if(read_rst) begin
        read_pointer <= 0;
        output_ready <= 0;
        
    end else begin
        // read from data_in when write_en
        if(write_en) begin
            pre_write_en <= 1;
            // check last note and whether the memory is full
            if(data_in != last_note && count < `MAX_DEPTH) begin 
                memory[write_pointer] <= last_note;
                last_note <= data_in;
                write_pointer <= write_pointer + 1;
                count <= count + 1;
            end
        end else begin
            if(pre_write_en) begin
                pre_write_en <= 0;
                last_note <= 0;
                if(count < `MAX_DEPTH) begin
                    memory[write_pointer] <= last_note;
                    write_pointer <= write_pointer + 1;
                    count <= count + 1;
                end
            end
        end
        
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
