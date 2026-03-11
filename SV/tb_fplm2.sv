
module tb_fplm2;

   localparam WIDTH = 16;
   localparam EXP_WIDTH = 5;
   localparam SIG_WIDTH = 10;

    logic clk, reset;

    logic [15:0]    a, b, product, expected, base_product;

    logic [1:0]     rnd;

    integer handle3;

    logic [47:0] testvectors[];

    logic [31:0] vectornum, errors, passes;
    logic [63:0] expError, manError;

    mul_fplm2_16 fplm2(.a, .b, .product);
    fmult #(WIDTH, EXP_WIDTH, SIG_WIDTH) mul(.Z(base_product), .A(a), .B(b), .rnd(rnd));

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
       vectornum = 0; errors = 0; expError=0; manError=0;
     end

     // apply test vectors on rising edge of clk
  always @(posedge clk)
    begin
       #1; {a, b, expected} = testvectors[vectornum];
    end

   // check results on falling edge of clk
   always @(negedge clk) begin
      expError += $unsigned(base_product[14:10]) - $unsigned(product[14:10]);
      manError += $unsigned(base_product[9:0]) - $unsigned(product[9:0]);
      if ((product != expected)) begin
         errors += 1;
	      $fdisplay(handle3,
                   "fplm : a=%h b=%h", a,  b);	 
         $fdisplay(handle3, "FAIL: got=%h expected=%h base=%h",
                   product, expected, base_product);
      end else begin
         passes += 1;
         $fdisplay(handle3,
                   "fplm : a=%h b=%h", a,  b);	 
         $fdisplay(handle3, "PASS: got=%h expected=%h base=%h",
                   product, expected, base_product);
      end
      $fdisplay(handle3, "------------");
   
      vectornum = vectornum + 1;
      if (testvectors[vectornum] === 'x) begin 
         $fdisplay(handle3, "%d tests completed with %d errors", 
	           vectornum, errors);
         $fdisplay(handle3, "%d Exponential Error and %d Mantissa Error between fplm2 and baseline", expError, manError);
         $stop;
      end      
   end

endmodule
