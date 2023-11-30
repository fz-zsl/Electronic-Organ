module FreeMode(
    input sys_clk, rst_n,
    input PS2_clk, PS2_data,
    output pwm, sd,
    output [7:0] note
);
    wire PS2_trig, PS2_ovf;
    wire [7:0] oData;
    
    PS2Decoder PS2Decoder_dut(
        .sys_clk(sys_clk), .rst_n(rst_n),
        .ps2_clk(PS2_clk), .ps2_data(PS2_data), .in_en(1'b1),
        .data(oData), .out_en(PS2_trig), .overflow(PS2_ovf)
    );

    Key2Note Key2Note_dut(
        .clk(sys_clk), .rst_n(rst_n), .key(PS2_trig ? oData : 0),
        .note(note)
    );

    wire [1:0] octave;
    Octave Octave_dut(
        .clk(sys_clk), .rst_n(rst_n), .key(PS2_trig ? oData : 0),
        .octave(octave)
    );
    
    sound_top soundtop_dut(
        .clk(sys_clk), .rst_n(rst_n), .shift(octave),
        .notes(note),
        .pwm(pwm), .sd(sd)
    );
    // Note2Sound();
endmodule