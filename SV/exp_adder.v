/******************************************************************************
*@module	Exponent Adder
*@author	TuanND
*@date 		2017-03-27
*@desc      double precision exponent adder	    
******************************************************************************/

module  exp_adder(expZ, cOut, expA, expB, cIn);
    parameter   EXP_WIDTH   =   11;
    //localparam  BIAS        =   (1<<(EXP_WIDTH-1)-1);

    input   [EXP_WIDTH-1:0]     expA, expB;
    input                       cIn;//cIn
    output  [EXP_WIDTH-1:0]     expZ;
    output                      cOut;//carry Out

    wire    [EXP_WIDTH-1:0]     bias;
    assign bias = {1'b0, {(EXP_WIDTH-1){1'b1}}};

    assign  {cOut, expZ}    =   expA + expB - bias + cIn;

endmodule
