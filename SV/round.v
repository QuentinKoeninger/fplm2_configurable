/******************************************************************************
*@module	Exponent Adder
*@author	TuanND
*@date 		2017-03-27
*@desc      double precision exponent adder	    
******************************************************************************/

module  round(Carry, Sum, Z, rnd, ovf, sign);
   parameter	WIDTH	=	52;
   localparam	FULL_WIDTH =	2 * (WIDTH+1);   

   input   [FULL_WIDTH-1:0] Carry, Sum;   
   input   [1:0]			rnd;
   input                    sign;
  
   output [WIDTH:0] 		Z;   
   output 			ovf;//normalization shift

   sbh_round #(WIDTH) round0(.Carry(Carry),
                                .Sum(Sum),
                                .Z(Z),
                                .rnd(rnd),
                                .ovf(ovf),
                                .sign(sign)
                            );

endmodule
