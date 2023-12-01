module PS2Decoder(
    input sys_clk, rst_n, ps2_clk, ps2_data, in_en,
    output [7:0] data,
    output out_en,
    output reg overflow
);
    reg [3:0] cnt; // counter for buffer 1
    reg [9:0] buf1; // use buffer1 to store a datum
    reg [7:0] buf2[31:0]; // use a queue to store all unread data
    reg [4:0] head = 5'b0, tail = 5'b0; // head and tail pointer of buffer2
    always @(posedge ps2_clk) begin
        if (~rst_n) begin
            tail <= 0;
            overflow <= 0;
            cnt <= 0;
        end
        else begin
            if (cnt == 4'hA) begin // buf1 is full
                buf2[tail] <= buf1[8:1];
                overflow <= overflow | (head == (tail + 1));
                if (head != (tail + 1))
                    tail <= tail + 1;
                cnt <= 0;
            end
            else begin
                buf1[cnt] <= ps2_data;
                cnt <= cnt + 1;
            end
        end
    end

    always @(posedge sys_clk) begin
        if (~rst_n)
            head <= 0;
        else if (in_en && out_en)
            head <= head + 1;
    end

    assign out_en = (head != tail);
    assign data = buf2[head];
endmodule