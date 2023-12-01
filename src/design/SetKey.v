module SetKey(
    input clk, input rst_n, input write_en, input [7:0] key,
    output reg [7:0] pattern[7:0], output reg oTrig
);
    reg pnt = 0;
    reg [7:0] next_key = 8'h00;

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin // reset the pattern
            pattern[0] <= def_do;
            pattern[1] <= def_re;
            pattern[2] <= def_mi;
            pattern[3] <= def_fa;
            pattern[4] <= def_so;
            pattern[5] <= def_la;
            pattern[6] <= def_si;
            pattern[7] <= def_do2;
            oTrig <= 1'b1;
        end
        else if (write_en) begin
            if (pnt == 0) begin // start writing
                oTrig <= 1'b0;
            end
            if (key != 8'he0 && key != 8'hf0) begin // ignore the break code
                next_key <= key;
            end
        end
    end

    always @(next_key) begin // fill the pattern
        pattern[pnt] = next_key;
        pnt = pnt + 1;
        if (pnt == 8) begin
            pnt = 0;
            oTrig = 1'b1;
        end
    end
endmodule