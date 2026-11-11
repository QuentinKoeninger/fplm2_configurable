// Test bench to generate outputs from logarithm approximation

module log_mult_comparisons_tb;

    logic [5:0] in_a, in_b;
    logic [5:0] out_a, out_b;
    logic Lcout_a, Lcout_b;
    logic Ecout_a, Ecout_b;

    int handle0, handle1;

    logic [3:0] min_c [1:0];
    logic [3:0] min_d [1:0];
    logic [1:0] Ein_c [1:0];
    logic [1:0] Ein_d [1:0];

    logic Lcin_c [1:0];
    logic Lcout_c [1:0];
    logic Ecin_c [1:0];
    logic Ecout_c [1:0];

    logic [3:0] mout_c [1:0];
    logic [3:0] eout_c [1:0];


    assign in_a[5:4] = 2'b01;
    assign in_b[5:4] = 2'b01;

    assign Lcin_c[1] = Lcout_c[0];
    assign Lcin_c[0] = 1'b0;
    assign Ecin_c[1] = Ecout_c[0];
    assign Ecin_c[0] = Lcout_c[1];

    proposed_lm lm_a(.ma(in_a[3:0]), .mb(in_b[3:0]), .Ea(in_a[5:4]), .Eb(in_b[5:4]), .Ecin(Lcout_a), .Lcin(1'b0),
                    .mp(out_a[3:0]), .Ep(out_a[5:4]), .Ecout(Ecout_a), .Lcout(Lcout_a));

    fplm2 lm_b(.ma({1'b1, in_a[3:0]}), .mb({1'b1, in_b[3:0]}), .Ea(in_a[5:4]), .Eb(in_b[5:4]), .Ecin(Lcout_b), .Lcin(1'b0), 
                    .is_ms_mult(1'b1), .ma_1(in_a[3]), .mb_1(in_b[3]), .mp(out_b[3:0]), .Ep(out_b[5:4]), .Ecout(Ecout_b), .Lcout(Lcout_b));

    proposed_lm lm_c [1:0](.ma(min_c), .mb(min_d), .Ea(Ein_c), .Eb(Ein_d), .Ecin(Ecin_c), .Lcin(Lcin_c),
                    .mp(mout_c), .Ep(), .Ecout(Ecout_c), .Lcout(Lcout_c));
                    
    // NEED TO ADD LOGIC TO HANDLE SUBTRACTION OF BIAS FROM EXPONENT!!!!

    initial begin
        handle0 = $fopen("outputs/mult_comparison_7bit.out");
        // handle1 = $fopen("outputs/mult_comparison_13bit.out");
    end

    initial begin
        for (int i = 0; i < 256; i++) begin
            in_a[3:0] = i[3:0];
            in_b[3:0] = i[7:4];
            #10
            $fdisplay(handle0, "%b_%b_%b_%b", in_a, in_b, out_a, out_b);
        end

        // for (int i = 0; i < 512; i++) begin
        //     in_b[1] = i[7:4];
        //     in_b[0] = i[3:0];
        //     exp_carry_b = i[8];
        //     #10
        //     $fdisplay(handle1, "%b%b_%b%b_%b", in_b[1], in_b[0], out_b[1], out_b[0], exp_carry_b);
        // end

        $stop;
    end

endmodule