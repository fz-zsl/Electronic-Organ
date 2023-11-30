module Octave(
    input clk, input rst_n, input [7:0] key,
    output [1:0] octave
    );
    
    reg [1:0] oct_reg = 2'b0;
    
    always @(posedge clk) begin
        if (~rst_n) oct_reg <= 2'b0;
        else if (key) begin
            case (key)
                8'h12: oct_reg <= 2'b10;
                8'h59: oct_reg <= 2'b01;
                8'h29: oct_reg <= 2'b00;
                default: oct_reg <= oct_reg;
            endcase
        end
    end
    
    assign octave = oct_reg;
endmodule