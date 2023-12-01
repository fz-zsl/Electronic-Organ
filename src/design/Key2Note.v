`include "KeyParams.v"

module Key2Note #(
    parameter key_do = `def_do,
    parameter key_re = `def_re,
    parameter key_mi = `def_mi,
    parameter key_fa = `def_fa,
    parameter key_so = `def_so,
    parameter key_la = `def_la,
    parameter key_si = `def_si,
    parameter key_do2 = `def_do2
) (
    input clk, input rst_n, input [7:0] key,
    output [7:0] note
);

    reg [15:0] sgn = 16'h0000;
    reg [7:0] note_reg = 8'h00;
    
    always @(posedge clk) begin
        if (~rst_n) begin
            sgn <= 16'h0000;
        end
        else if (key) begin
            sgn <= {sgn[7:0], key};
        end
        case (sgn[7:0])
            key_do: begin // do
                if ((sgn >> 8) == 8'hf0)
                    note_reg <= note_reg & ~8'h01;
                else
                    note_reg <= note_reg | 8'h01;
            end
            key_re: begin // re
                if ((sgn >> 8) == 8'hf0)
                    note_reg <= note_reg & ~8'h02;
                else
                    note_reg <= note_reg | 8'h02;
            end
            key_mi: begin // mi
                if ((sgn >> 8) == 8'hf0)
                    note_reg <= note_reg & ~8'h04;
                else
                    note_reg <= note_reg | 8'h04;
            end
            key_fa: begin // fa
                if ((sgn >> 8) == 8'hf0)
                    note_reg <= note_reg & ~8'h08;
                else
                    note_reg <= note_reg | 8'h08;
            end
            key_so: begin // so
                if ((sgn >> 8) == 8'hf0)
                    note_reg <= note_reg & ~8'h10;
                else
                    note_reg <= note_reg | 8'h10;
            end
            key_la: begin // la
                if ((sgn >> 8) == 8'hf0)
                    note_reg <= note_reg & ~8'h20;
                else
                    note_reg <= note_reg | 8'h20;
            end
            key_si: begin // si
                if ((sgn >> 8) == 8'hf0)
                    note_reg <= note_reg & ~8'h40;
                else
                    note_reg <= note_reg | 8'h40;
            end
            key_do2: begin // do of next octave
                if ((sgn >> 8) == 8'hf0)
                    note_reg <= note_reg & ~8'h80;
                else
                    note_reg <= note_reg | 8'h80;
            end
            default:
                note_reg <= note_reg;
        endcase
    end

    assign note = note_reg;
endmodule