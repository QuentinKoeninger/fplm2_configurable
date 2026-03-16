module tb;
 
    reg  [15:0] A;
    reg  [15:0] B;
    reg  [15:0] expected;
    wire [15:0] P;
 
    integer pass_count;
    integer fail_count;
    integer i;
 
    // 10 vectors × 48 bits each (16+16+16)
    reg [47:0] testvectors [0:9];
 
    fp_mult dut (
        .A(A),
        .B(B),
        .P(P)
    );
 
    initial begin
        pass_count = 0;
        fail_count = 0;
 
        // Load vector file
        //$readmemh("testvectors_fplm2.tv", testvectors);
        $readmemh("testvector16_test4_1.tv", testvectors);
 
        // Run 10 tests
        for (i = 0; i < 10; i = i + 1) begin
            {A, B, expected} = testvectors[i];
            #5;
            check_result();
        end
 
        $display("----------------------------------------");
        $display("TOTAL TESTS = %0d", i);
        $display("PASS        = %0d", pass_count);
        $display("FAIL        = %0d", fail_count);
 
        $finish;
    end
 
    task check_result;
    begin
        if (P === expected) begin
            $display("PASS: A=%h B=%h Result=%h", A, B, P);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: A=%h B=%h got=%h expected=%h", A, B, P, expected);
            fail_count = fail_count + 1;
        end
    end
    endtask
 
endmodule