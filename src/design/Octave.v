module Octave(
    input clk, input rst_n, input [7:0] key,
    output signed [1:0] octave
    );
    
    reg signed [1:0] oct_reg = 2'b0;
    
    always @(posedge clk) begin
        if (~rst_n) oct_reg <= 2'b0;
        else if (key) begin
            case (key)
                ps2_lshift, ps2_rshift: oct_reg <= oct_reg + 1; // octave up
                ps2_crtl: oct_reg <= oct_reg - 1; // octave down
                ps2_space: oct_reg <= 2'b00; // reset octave
                default: oct_reg <= oct_reg;
            endcase
        end
    end
    
    assign octave = oct_reg;
endmodule