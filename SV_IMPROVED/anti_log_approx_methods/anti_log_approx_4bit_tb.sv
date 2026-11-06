// Test bench to generate outputs from logarithm approximation

module anti_log_approx_4bit_tb;

    logic [3:0] in_a;
    logic       exp_carry_a;
    logic [3:0] out_a;

    logic [3:0] in_b [1:0];
    logic       exp_carry_b;
    logic [3:0] out_b [1:0];

    int handle0, handle1;

    anti_log_approx_4bit loga(.s(in_a), .p(out_a));

    anti_log_approx_4bit logb [1:0](.s(in_b), .p(out_b));

    initial begin
        handle0 = $fopen("outputs/anti_log_approx_4bit.out");
        handle1 = $fopen("outputs/anti_log_approx_9bit.out");
    end

    initial begin
        for (int i = 0; i < 32; i++) begin
            in_a = i[3:0];
            exp_carry_a = i[4];
            #10
            $fdisplay(handle0, "%b_%b_%b", in_a, out_a, exp_carry_a);
        end

        for (int i = 0; i < 512; i++) begin
            in_b[1] = i[7:4];
            in_b[0] = i[3:0];
            exp_carry_b = i[8];
            #10
            $fdisplay(handle1, "%b%b_%b%b_%b", in_b[1], in_b[0], out_b[1], out_b[0], exp_carry_b);
        end

        $stop;
    end

endmodule