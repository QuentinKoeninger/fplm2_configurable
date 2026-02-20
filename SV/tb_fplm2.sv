
module tb_fplm2;

    logic clk, reset;

    logic [15:0]    a, b, product, expected;

    integer handle3;

    assign a = 16'h3e00;
    assign b = 16'h4000;
    assign expected = 16'h4300;

    mul_fplm2_16 fplm2(.a, .b, .product);

    initial 
     begin
        handle3 = $fopen("fplm2.out");
     end

    // generate clock
    always 
     begin
	    clk = 1; #5; clk = 0; #5;
     end

    initial 
     begin
        #20;
        $fdisplay(handle3, "Result: %h, Expected: %h", product, expected);
        $stop;
     end

endmodule
