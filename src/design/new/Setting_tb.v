module Setting_tb();
    reg slow_clk, rst_n;
    reg [7:0] pose_buts;
    reg pose_esc;
    wire [2:0] perm0, perm1, perm2, perm3, perm4, perm5, perm6, perm7;
    wire [2:0] setting_cnt;
    Setting setting(
        .slow_clk(slow_clk),
        .rst_n(rst_n),
        .pose_buts(pose_buts),
        .pose_esc(pose_esc),
        .perm0(perm0),
        .perm1(perm1),
        .perm2(perm2),
        .perm3(perm3),
        .perm4(perm4),
        .perm5(perm5),
        .perm6(perm6),
        .perm7(perm7),
        .setting_cnt(setting_cnt)
    );

    initial begin
        slow_clk = 0;
        forever begin
            #5 slow_clk = ~slow_clk;
        end
    end

    initial begin
        rst_n = 0;
        #7 rst_n = 1;
    end

    initial begin
        pose_buts = 0;
        pose_esc = 0;
        #10 pose_buts = 8'b00000001;
        #10 pose_buts = 8'b00000010;
        #10 pose_buts = 8'b00000100;
        #10 pose_buts = 8'b00001000;
        #10 pose_buts = 8'b00010000;
        #10 pose_buts = 8'b00100000;
        #10 pose_buts = 8'b01000000;
        #10 pose_buts = 8'b10000000;
        #10 pose_buts = 0;
    end
endmodule