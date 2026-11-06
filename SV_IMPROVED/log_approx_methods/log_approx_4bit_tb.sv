// Test bench to generate outputs from logarithm approximation

module log_approx_4bit_tb;

    logic [3:0] in_a;
    logic [3:0] out_a;

    logic [3:0] in_b [2:0];
    logic [3:0] out_b [2:0];

    int handle0, handle1;

    log_approx_4bit loga(.m(in_a), .l(out_a));

    log_approx_4bit logb [2:0](.m(in_b), .l(out_b));

    initial begin
        handle0 = $fopen("outputs/log_approx_4bit.out");
        handle1 = $fopen("outputs/log_approx_12bit.out");
    end

    initial begin
        
        for (int i = 0; i < 16; i++) begin
            in_a = i[3:0];
            #10
            $fdisplay(handle0, "%b_%b", in_a, out_a);
        end

        for (int i = 0; i < 4096; i++) begin
            in_b[2] = i[11:8];
            in_b[1] = i[7:4];
            in_b[0] = i[3:0];
            #10
            $fdisplay(handle1, "%b%b%b_%b%b%b", in_b[2], in_b[1], in_b[0], out_b[2], out_b[1], out_b[0]);
        end

        $stop;

    end

endmodule