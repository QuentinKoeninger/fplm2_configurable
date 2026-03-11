/******************************************************************************
*@module	Mantissa Multiplier 
*@author	TuanND
*@date 		2018-02-12
*@desc	    Multiplication with rounding 
*           manA, manB: inputs (53 bits with hidden 1)
            rnd: 00 (RNE), 01 (RPI), 10 (RNI), 11 (RZ)
******************************************************************************/

module  man_mult(manZ, ovf, manA, manB, rnd, sign);
    parameter   SIG_WIDTH   =   52;

    input   [SIG_WIDTH:0]       manA, manB;
    input   [1:0]               rnd;
    input                       sign;
    
    output                      ovf;
    output  [SIG_WIDTH:0]       manZ;

    wire    [2*SIG_WIDTH+1:0] Carry, Sum;

    /*----------------------------------------------------------------------------
    | PP Reduction
    ----------------------------------------------------------------------------*/
    wire [63:0] manA_xt, manB_xt;
    wire [127:0] sum_xt, carry_xt;
    assign manA_xt = {{(63 - SIG_WIDTH){1'b0}}, manA};
    assign manB_xt = {{(63 - SIG_WIDTH){1'b0}}, manB};

    multiplier pp_reduction0(.Carry(carry_xt),
                                  .Sum(sum_xt),
                                  .x(manA_xt),
                                  .y(manB_xt)
                              );
    assign Carry = carry_xt[2*SIG_WIDTH+1:0];
    assign Sum = sum_xt[2*SIG_WIDTH+1:0];

    /*----------------------------------------------------------------------------
    | Rounding
    ----------------------------------------------------------------------------*/
    round #(SIG_WIDTH) round0(.Carry(Carry),
                                .Sum(Sum),
                                .Z(manZ),
                                .rnd(rnd),
                                .ovf(ovf),
                                .sign(sign)
                                );

 endmodule
