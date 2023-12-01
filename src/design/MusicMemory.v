`timescale 1ns / 1ps
`include "MemoryPara.v"
module MusicMemory(
    input wire                  clk,
    input wire                  rst_n,
    input wire                  write_en,
    input wire                  read_en,
    input wire                  read_rst,
    input wire [`DATA_WIDTH-1:0] data_in,
    output reg [`DATA_WIDTH-1:0] data_out,
    output reg                  output_ready
);

reg [`DATA_WIDTH-1:0]            memory  [0:`MAX_DEPTH-1]; // memory for notes and octave
reg [`MAX_DEPTH_BIT-1:0]         count;                      // number of notes in memory
reg [`MAX_DEPTH_BIT-1:0]         read_pointer;               // position of read pointer
reg [`MAX_DEPTH_BIT-1:0]         write_pointer;              // position of write pointer
reg [`MAX_SAMPLE_INTERVAL-1:0]   write_sample_counter;
reg [`MAX_SAMPLE_INTERVAL-1:0]   read_sample_counter;


// Initialize internal signals
initial begin
    count = 0;
    read_pointer = 0;
    write_pointer = 0;
    write_sample_counter = 1;
    read_sample_counter = 1;
end

// Storage and output control logic
always @(posedge clk) begin
    if (~rst_n) begin
        // Reset memory contents and counters
        count <= 0;
        read_pointer <= 0;
        output_ready <= 0;
        write_pointer <= 0;
        write_sample_counter <= 1;
        read_sample_counter <= 1;
    end else if(read_rst) begin
        read_pointer <= 0;
        output_ready <= 0;
        read_sample_counter <= 1;
    end else begin
        // Write data into memory if write_en is asserted
        if (write_en) begin
            if(count < `MAX_DEPTH && write_sample_counter == `SAMPLE_INTERVAL) begin
                memory[write_pointer] <= data_in;
                write_pointer <= write_pointer + 1;
                count <= count + 1;
            end
            if (write_sample_counter == `SAMPLE_INTERVAL) begin
                write_sample_counter <= 1;
            end else begin
                write_sample_counter <= write_sample_counter + 1;
            end
        end
          
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