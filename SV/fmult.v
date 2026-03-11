/******************************************************************************
*@module	Floating Point Multipler 
*@author	TuanND
*@date 		2018-02-12
*@desc	    Rounding for double precision 
******************************************************************************/

module fmult(Z, A, B, rnd);
    parameter   WIDTH       =   64;
    parameter   EXP_WIDTH   =   11;
    parameter   SIG_WIDTH   =   52;

    input   [WIDTH-1:0]         A, B; //inputs
    input   [1:0]               rnd;//rounding mode: 00 (RNE), 01 (RPI), 10 (RNI), 11 (RZ)
    output  [WIDTH-1:0]         Z;//result

/******************************************************************************
*  UNPACKING
******************************************************************************/
    wire                        signA, signB, signZ;
    wire    [EXP_WIDTH-1:0]     expA, expB, expZ;
    wire    [SIG_WIDTH-1:0]     sigA, sigB, sigZ;//significant A, B
    wire    [SIG_WIDTH:0]       manA, manB, manZ;//mantissa A, B, Z

    assign  signA           =   A[WIDTH-1];
    assign  signB           =   B[WIDTH-1];

    assign  expA            =   A[WIDTH-2:SIG_WIDTH];
    assign  expB            =   B[WIDTH-2:SIG_WIDTH];

    assign  sigA            =   A[SIG_WIDTH-1:0];
    assign  sigB            =   B[SIG_WIDTH-1:0];

    assign  manA            =   {1'b1, sigA};
    assign  manB            =   {1'b1, sigB};

/******************************************************************************
* MAIN DATAPATH
******************************************************************************/
    // sign bit is trivial
    assign  signZ   =   signA ^ signB;
/*----------------------------------------------------------------------------
| Exponent Datapath
| Using Carry Select Adder (or Compound Adder), when mantissa overflow is
| available, it will select the correct output
----------------------------------------------------------------------------*/
    //carry select adder 
    wire    [EXP_WIDTH-1:0]     expZ_0, expZ_1;
    wire                        cOut_0, cOut_1;
    wire                        man_ovf; 
    //exponent adder with carry in 0
    exp_adder   #(EXP_WIDTH)   exp_adder0(.expZ(expZ_0),
                                            .cOut(cOut_0),
                                            .expA(expA),
                                            .expB(expB),
                                            .cIn(1'b0)
                                        );
    //exponent adder with carry in 1
    exp_adder   #(EXP_WIDTH)   exp_adder1(.expZ(expZ_1),
                                           .cOut(cOut_1),
                                            .expA(expA),
                                            .expB(expB),
                                            .cIn(1'b1)
                                        );
    //if mantissa > 1, update adder by adding 1 to exponent
    assign  expZ = (man_ovf==1'b1) ? expZ_1 : expZ_0;
/*----------------------------------------------------------------------------
| Mantissa Datapath
----------------------------------------------------------------------------*/
    man_mult    #(SIG_WIDTH)    man_mult1(.manZ(manZ),
                                            .ovf(man_ovf),
                                            .manA(manA),
                                            .manB(manB),
                                            .rnd(rnd),
                                            .sign(signZ)
                                         );

/*****************************************************************************
* OUTPUT
*****************************************************************************/
    assign  Z[WIDTH-1]              =   signZ;
    assign  Z[WIDTH-2:SIG_WIDTH]    =   expZ;
    assign  Z[SIG_WIDTH-1:0]        =   manZ[SIG_WIDTH-1:0];

endmodule
