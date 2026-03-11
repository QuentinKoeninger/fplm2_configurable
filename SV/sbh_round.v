/******************************************************************************
*@module	Santoro et al. method
*@author	TuanND
*@date 		2017-03-27
*@desc      Santoro rounding
******************************************************************************/

module  sbh_round(Carry, Sum, Z, rnd, ovf, sign);
   parameter WIDTH = 52;
   localparam FULL_WIDTH = 2 * (WIDTH+1);   

   input [FULL_WIDTH-1:0] Carry, Sum;   
   input [1:0] rnd;
   input sign;
  
   output [WIDTH:0]	Z;   
   output ovf;//normalization shift

   //Rsum, Rcarry, Last, Guard, Overflow, Carry, Sticky
   wire rs, rc, l, g, v, c, t;
   wire p;//prediction
   wire [WIDTH+1:0] SH, CH;
   wire [WIDTH-1:0] CL, SL, PL;

   ////////////////////////////////////////////
   // UNBOXING
   ///////////////////////////////////////////
   //most significant halves
   assign SH = Sum[FULL_WIDTH-1:WIDTH];
   assign CH = Carry[FULL_WIDTH-1:WIDTH];

   //least significant halves
   assign CL = Carry[WIDTH-1:0];
   assign SL = Sum[WIDTH-1:0];

   //bits used to predict
   assign rs = Sum[WIDTH-1];
   assign rc = Carry[WIDTH-1];
   assign p = rs || rc;
   ////////////////////////////////////////////
   // CARRY - SELECT ADDER (COMPOUND ADDER) 
   ///////////////////////////////////////////
   wire [WIDTH+1:0] XS, XC;
   HA_row #(WIDTH+2)   ut0(.XC(XC),
                        .XS(XS),
                        .A(SH),
                        .B(CH)
                        );
   //inject the prediction bit
   wire [WIDTH+1:0] XC1;
   assign XC1 = {XC[WIDTH:0], p};

   //Carry Select Adder
   wire [WIDTH+1:0] P1, P0;
   wire Cout1, Cout0;

   CSAdder  #(WIDTH+2) csa0(.SPlus0(P0),
                        .SPlus1(P1),
                        .Cout1(Cout1),
                        .Cout0(Cout0),
                        .A(XS),
                        .B(XC1)
                    );

   //Overflow bit
   assign v = P0[WIDTH+1];

   //Normalization
   wire [WIDTH+1:0] NP0, NP1;
   assign NP0 = (P0[WIDTH+1] == 1'b1)? P0 >> 1: P0;
   assign NP1 = (P1[WIDTH+1] == 1'b1)? P1 >> 1: P1;

   ////////////////////////////////////////////
   // SELECT RESULT LOGIC (RIGHT PATH)
   ///////////////////////////////////////////

   //compute c and Sticky T
   assign {c, PL} = CL + SL; 
   assign g = PL[WIDTH-1];
   sticky #(WIDTH-1) sticky0(.Sticky(t),
                             .Sum(SL[WIDTH-2:0]),
                             .Carry(CL[WIDTH-2:0])
                         );
   //assign t = |PL[WIDTH-2:0];
   assign l = XS[0] ^ c;//Correct L bit is nothing but sum bit XS added carry in

   //Compute Csum
   wire r;
   wire [1:0] Csum;
   assign r = g||v;
   assign Csum = (c + r);

   //Compute sel
   wire sel;
   assign sel = Csum[0] ^ p;//sel = Csum - p;
   
   ////////////////////////////////////////////
   // FIX LSB
   ///////////////////////////////////////////
   //Compute Fix0, Fix1 such that Fix0 = 0 in tie-case (no overflow)
   //and Fix1 = 0 in tie-case (overlow)
   //Tie-case (no overflow): T = 0, G = 1. 
   wire Fix1, Fix0;
   assign Fix0 = ~g || t;
   //Tie-case (overflow): L = 1, G = 0, T = 0. 
   assign Fix1 = ~l || g || t;

   //Fixing is simple AND-ding the fix signal and the last bit (to pull it down)
   //Fix in parallel with both P0 and P1 and select the correct output later
   assign FixL0 = (P0[WIDTH+1]==1'b1) ? P0[1] && Fix1 : P0[0] && Fix0;
   assign FixL1 = (P1[WIDTH+1]==1'b1) ? P1[1] && Fix1 : P1[0] && Fix0;

   ////////////////////////////////////////////
   // FINAL MUX 
   ///////////////////////////////////////////
   assign Z[WIDTH:1] = (sel == 1'b1) ? NP1[WIDTH:1] : NP0[WIDTH:1];
   assign Z[0] = (sel == 1'b1) ? FixL1 : FixL0;
   assign ovf = (sel == 1'b1)? P1[WIDTH+1] : P0[WIDTH+1];

endmodule
