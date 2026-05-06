
module tb_fplm2_conf_16_32;

   localparam WIDTH = 16;
   localparam EXP_WIDTH = 5;
   localparam SIG_WIDTH = 10;

    logic clk, reset;

    logic [15:0]    a, b, product_16, expected;

    logic [31:0]    conf_product_16, conf_product_32, product_32;

    logic [1:0]     rnd;

    integer handle3;

    logic [47:0] testvectors[];

    logic [31:0] vectornum, errors16, passes16, errors32, passes32;
    logic [63:0] expError, manError;

    mul_fplm2_16 fplm2_16(.a, .b, .product(product_16));
    conf_mul_fplm2_16_32 fplm2_conf_16(.product(conf_product_16), .a({a, 16'b0}), .b({b, 16'b0}), .is32bit(1'b0));
    conf_mul_fplm2_16_32 fplm2_conf_32(.product(conf_product_32), .a({a, a}), .b({b, b}), .is32bit(1'b1));
    mul_fplm2_32 fplm2_32(.a({a, a}), .b({b, b}), .product(product_32));

    initial 
     begin
        handle3 = $fopen("fplm2.out");
     end

    // generate clock
    always 
     begin
	    clk = 1; #10; clk = 0; #10;
     end

    initial
     begin
       $readmemh("./fplm2_testvectors.tv", testvectors);
       //$readmemh("../tests/baby_torture.tv", testvectors);
       //$readmemh("../tests_softfloat/f16_mulAdd_rnm.tv", testvectors);
       vectornum = 0; errors16 = 0; errors32 = 0; expError=0; manError=0;
     end

     // apply test vectors on rising edge of clk
  always @(posedge clk)
    begin
       #1; {a, b, expected} = testvectors[vectornum];
    end

   // check results on falling edge of clk
   always @(negedge clk) begin
      if ((product_16 != conf_product_16[31:16])) begin
         errors16 += 1;
	      $fdisplay(handle3,
                   "fplm16 : a=%h b=%h", a,  b);	 
         $fdisplay(handle3, "FAIL: fplm=%h conf=%h",
                   product_16, conf_product_16[31:16]);
      end else begin
         passes16 += 1;
         $fdisplay(handle3,
                   "fplm16 : a=%h b=%h", a,  b);	 
         $fdisplay(handle3, "PASS: fplm=%h conf=%h",
                   product_16, conf_product_16[31:16]);
      end

      $fdisplay(handle3, "----");

      if ((product_32 != conf_product_32)) begin
         errors32 += 1;
	      $fdisplay(handle3,
                   "fplm32 : a=%h b=%h", {a, a},  {b, b});	 
         $fdisplay(handle3, "FAIL: fplm=%h conf=%h",
                   product_32, conf_product_32);
      end else begin
         passes32 += 1;
         $fdisplay(handle3,
                   "fplm32 : a=%h b=%h", {a, a},  {b, b});	 
         $fdisplay(handle3, "PASS: fplm=%h conf=%h",
                   product_32, conf_product_32);
      end
      $fdisplay(handle3, "------------");
   
      vectornum = vectornum + 1;
      if (testvectors[vectornum] === 'x) begin 
         vectornum = vectornum;
         $fdisplay(handle3, "%d 16bit tests completed with %d errors", 
	           vectornum, errors16);
         $fdisplay(handle3, "%d 32bit tests completed with %d errors", 
	           vectornum, errors32);
         $stop;
      end      
   end

endmodule
