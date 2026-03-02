
module tb_fplm2;

    logic clk, reset;

    logic [15:0]    a, b, product, expected;

    integer handle3;

    logic [47:0] testvectors[];

    logic [31:0] vectornum, errors, passes;

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
       $readmemh("./fplm2_testvectors.tv", testvectors);
       //$readmemh("../tests/baby_torture.tv", testvectors);
       //$readmemh("../tests_softfloat/f16_mulAdd_rnm.tv", testvectors);
       vectornum = 0; errors = 0;
     end

     // apply test vectors on rising edge of clk
  always @(posedge clk)
    begin
       #1; {a, b, expected} = testvectors[vectornum];
    end

   // check results on falling edge of clk
   always @(negedge clk) begin
      if ((product != expected)) begin
         errors += 1;
	      $fdisplay(handle3,
                   "fplm : a=%h b=%h", a,  b);	 
         $fdisplay(handle3, "FAIL: got=%h expected=%h",
                   product, expected);
      end else begin
         passes += 1;
         $fdisplay(handle3,
                   "fplm : a=%h b=%h", a,  b);	 
         $fdisplay(handle3, "PASS: got=%h expected=%h",
                   product, expected);
      end
   
      vectornum = vectornum + 1;
      if (testvectors[vectornum] === 'x) begin 
         $fdisplay(handle3, "%d tests completed with %d errors", 
	           vectornum, errors);
         $stop;
      end      
   end

endmodule
