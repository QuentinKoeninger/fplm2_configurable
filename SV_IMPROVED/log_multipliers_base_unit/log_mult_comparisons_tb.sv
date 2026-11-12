// Test bench to generate outputs from logarithm approximation

module log_mult_comparisons_tb;

    int count;

    logic [5:0] in_a, in_b;
    logic [5:0] out_a, out_b;
    logic Lcout_a, Lcout_b;
    logic [1:0] Ecout_a; 
    logic Ecout_b;

    int handle0, handle1;

    logic [3:0] min_c [1:0];
    logic [3:0] min_d [1:0];
    logic [1:0] Ein_c [1:0];
    logic [1:0] Ein_d [1:0];

    logic [4:0] min_1c [1:0];
    logic [4:0] min_1d [1:0];

    logic Lcin_c [1:0];
    logic Lcout_c [1:0];
    logic [1:0] Ecin_c [1:0];
    logic [1:0] Ecout_c [1:0];
    logic [3:0] Ebias_c [1:0];

    logic Lcin_d [1:0];
    logic Lcout_d [1:0];
    logic Ecin_d [1:0];
    logic Ecout_d [1:0];
    logic is_ms_mult [1:0];
    logic mc_1 [1:0];
    logic md_1 [1:0];

    logic [3:0] mout_c [1:0];
    logic [1:0] Eout_c [1:0];

    logic [3:0] mout_d [1:0];
    logic [1:0] Eout_d [1:0];

    logic [4:0] Efout_c;
    logic [4:0] Efout_d;


    assign in_a[5:4] = 2'b01;
    assign in_b[5:4] = 2'b01;

    assign Lcin_c[1] = Lcout_c[0];
    assign Lcin_c[0] = 1'b0;
    assign Ecin_c[1] = Ecout_c[0];
    assign Ecin_c[0] = {1'b0, Lcout_c[1]};

    assign Ein_c[1] = 2'b01;
    assign Ein_c[0] = 2'b11;
    assign Ein_d[1] = 2'b01;
    assign Ein_d[0] = 2'b11;

    assign min_1c[0] = {min_c[1][0], min_c[0]};
    assign min_1c[1] = {1'b1, min_c[1]};
    assign min_1d[0] = {min_d[1][0], min_d[0]};
    assign min_1d[1] = {1'b1, min_d[1]};

    assign is_ms_mult[0] = 1'b0;
    assign is_ms_mult[1] = 1'b1;
    assign mc_1[0] = min_c[1][3];
    assign mc_1[1] = min_c[1][3];
    assign md_1[0] = min_d[1][3];
    assign md_1[1] = min_d[1][3];

    assign Lcin_d[1] = Lcout_d[0];
    assign Lcin_d[0] = 1'b0;
    assign Ecin_d[1] = Ecout_d[0];
    assign Ecin_d[0] = Lcout_d[1];

    assign Ebias_c[1] = 4'b1110;
    assign Ebias_c[0] = 4'b0001;

    logic [1:0] efa, efb;

    logic [2:0] efc1, efc2;

    assign efc1 = $unsigned({Ecout_c[1], Eout_c[1]}) + $unsigned(3'b110) + $unsigned({2'b0, efc2[2]});
    assign efc2 = $unsigned({1'b0, Eout_c[0]}) + $unsigned(3'b001);

    proposed_lm lm_a (.ma(in_a[3:0]), .mb(in_b[3:0]), .Ea(in_a[5:4]), .Eb(in_b[5:4]), .Ecin({1'b0, Lcout_a}), .Lcin(1'b0),
                    .mp(out_a[3:0]), .Ep(efa), .Ecout(Ecout_a), .Lcout(Lcout_a), .Ebias(4'b1111));

    fplm2 lm_b (.ma({1'b1, in_a[3:0]}), .mb({1'b1, in_b[3:0]}), .Ea(in_a[5:4]), .Eb(in_b[5:4]), .Ecin(Lcout_b), .Lcin(1'b0), 
                    .is_ms_mult(1'b1), .ma_1(in_a[3]), .mb_1(in_b[3]), .mp(out_b[3:0]), .Ep(efb), .Ecout(Ecout_b), .Lcout(Lcout_b));

    proposed_lm lm_c [1:0] (.ma(min_c), .mb(min_d), .Ea(Ein_c), .Eb(Ein_d), .Ecin(Ecin_c), .Lcin(Lcin_c), 
                    .Ebias(Ebias_c), .mp(mout_c), .Ep(Eout_c), .Ecout(Ecout_c), .Lcout(Lcout_c));
    
    fplm2 lm_d [1:0] (.ma(min_1c), .mb(min_1d), .Ea(Ein_c), .Eb(Ein_d), .Ecin(Ecin_d), .Lcin(Lcin_d), 
                    .is_ms_mult(is_ms_mult), .ma_1(mc_1), .mb_1(md_1), .mp(mout_d), .Ep(Eout_d), .Ecout(Ecout_d), .Lcout(Lcout_d));
                    
    //assign Efout_c = {Ecout_c[1], Eout_c[1], Eout_c[0]} - 5'b00111;
    assign Efout_c = {Ecout_c[1][0], Eout_c[1], Eout_c[0]};
    assign Efout_d = {Ecout_d[1], Eout_d[1], Eout_d[0]} - 5'b00111;

    assign out_a[5:4] = efa;
    assign out_b[5:4] = {Ecout_b, efb} - 3'b001;

    initial begin
        handle0 = $fopen("outputs/mult_comparison_7bit.out");
        handle1 = $fopen("outputs/mult_comparison_13bit.out");
    end

    initial begin
        for (int i = 0; i < 256; i++) begin
            in_a[3:0] = i[3:0];
            in_b[3:0] = i[7:4];
            #10
            $fdisplay(handle0, "%b_%b_%b_%b", in_a, in_b, out_a, out_b);
        end
        count = 0;
        for (int i = 0; i < 65536; i++) begin
            min_c[1] = i[15:12];
            min_c[0] = i[11:8];
            min_d[1] = i[7:4];
            min_d[0] = i[3:0];
            //Ein_c[1] = i[3:2];
            //Ein_c[0] = i[1:0];
            #20
            $fdisplay(handle1, "%b%b%b%b_%b%b%b%b_%b%b%b_%b%b%b", 
                        Ein_c[1], Ein_c[0], min_c[1], min_c[0], 
                        Ein_d[1], Ein_d[0], min_d[1], min_d[0], 
                        Efout_c[3:0], mout_c[1], mout_c[0],
                        Efout_d[3:0], mout_d[1], mout_d[0]);
            if (Efout_d[3:0] != Efout_c[3:0]) $display("%b_%b_", Efout_d[3:0], Efout_c[3:0]);
            else count = count + 1;
        end
        $display("%d Passes", count);
        $stop;
    end

endmodule