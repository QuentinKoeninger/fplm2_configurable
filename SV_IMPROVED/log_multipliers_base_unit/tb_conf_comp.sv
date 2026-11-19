// Test bench to generate outputs from logarithm approximation

module tb_conf_comp;

    logic [23:0] a;
    logic [23:0] b;
    logic [1:0]  mode;
    logic [23:0] p_lm, p_fplm2;

    int handle0, handle1, handle2, handle3;

    proposed_lm_conf_16 lm (.a, .b, .mode, .p(p_lm));
    fplm2_conf_16 fplm2 (.a, .b, .mode, .p(p_fplm2));

    initial begin
        handle0 = $fopen("outputs_conf/8bit.out");
        handle1 = $fopen("outputs_conf/16bit.out");
        handle2 = $fopen("outputs_conf/16bitb.out");
        handle3 = $fopen("outputs_conf/24bit.out");
    end

    initial begin
        a = 24'b0;
        b = 24'b0;
        mode = 2'b00;

        for (int i = 0; i < 256; i++) begin
            a[23:16] = {4'b0011, i[7:4]};
            b[23:16] = {4'b0100, i[3:0]};
            a[15:8] = {4'b0011, i[7:4]};
            b[15:8] = {4'b0100, i[3:0]};
            a[7:0] = {4'b0011, i[7:4]};
            b[7:0] = {4'b0100, i[3:0]};
            #20
            $fdisplay(handle0, "%b_%b_%b_%b", a[22:16], b[22:16], p_lm[22:16], p_fplm2[22:16]);
            if ((p_lm[23:16] != p_lm[15:8]) || p_lm[7:0] != p_lm[23:16]) begin
                $display("Fail: %b_%b_%b", p_lm[23:16],p_lm[15:8], p_lm[7:0]);
            end
        end

        mode = 2'b01;

        for (int i = 0; i < 65536; i++) begin
            a[23:8] = {6'b001111, i[15:8], 2'b0};
            b[23:8] = {6'b010001, i[7:0], 2'b0};
            #20
            $fdisplay(handle1, "%b_%b_%b_%b", a[22:8], b[22:8], p_lm[22:8], p_fplm2[22:8]);
        end

        mode = 2'b10;

        for (int i = 0; i < 16384; i++) begin
            a[23:8] = {9'b001111111, i[13:7]};
            b[23:8] = {9'b010000010, i[6:0]};
            #20
            $fdisplay(handle2, "%b_%b_%b_%b", a[22:8], b[22:8], p_lm[22:8], p_fplm2[22:8]);
        end

        mode = 2'b11;

        for (int i = 0; i < 262144; i++) begin
            a[23:2] = {10'b0011111111, i[17:9], 3'b0};
            b[23:2] = {10'b0100000000, i[8:0], 3'b0};
            #20
            $fdisplay(handle3, "%b_%b_%b", a[22:8], b[22:8], p_lm[22:8], p_fplm2[22:8]);
        end

        $stop;
    end

endmodule