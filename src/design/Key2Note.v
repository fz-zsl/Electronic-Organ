`include "KeyParams.v"

module Key2Note(
    input clk, input rst_n,
    input [7:0] key, input [7:0] pattern[7:0]
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
            pattern[0]: begin // do
                if ((sgn >> 8) == 8'hf0)
                    note_reg <= note_reg & ~8'h01;
                else
                    note_reg <= note_reg | 8'h01;
            end
            pattern[1]: begin // re
                if ((sgn >> 8) == 8'hf0)
                    note_reg <= note_reg & ~8'h02;
                else
                    note_reg <= note_reg | 8'h02;
            end
            pattern[2]: begin // mi
                if ((sgn >> 8) == 8'hf0)
                    note_reg <= note_reg & ~8'h04;
                else
                    note_reg <= note_reg | 8'h04;
            end
            pattern[3]: begin // fa
                if ((sgn >> 8) == 8'hf0)
                    note_reg <= note_reg & ~8'h08;
                else
                    note_reg <= note_reg | 8'h08;
            end
            pattern[4]: begin // so
                if ((sgn >> 8) == 8'hf0)
                    note_reg <= note_reg & ~8'h10;
                else
                    note_reg <= note_reg | 8'h10;
            end
            pattern[5]: begin // la
                if ((sgn >> 8) == 8'hf0)
                    note_reg <= note_reg & ~8'h20;
                else
                    note_reg <= note_reg | 8'h20;
            end
            pattern[6]: begin // si
                if ((sgn >> 8) == 8'hf0)
                    note_reg <= note_reg & ~8'h40;
                else
                    note_reg <= note_reg | 8'h40;
            end
            pattern[7]: begin // do of next octave
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