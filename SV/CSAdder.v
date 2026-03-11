/******************************************************************
*
*@author	TuanND
*@date 		Carry-Select Adder	
******************************************************************/
module CSAdder(SPlus1, SPlus0, Cout1, Cout0, A, B);
    parameter   WIDTH=54;

    output [WIDTH-1:0] SPlus1, SPlus0;
    output Cout1, Cout0;
    input [WIDTH-1:0] A, B;

    assign {Cout1, SPlus1} = A + B + 1;
    assign {Cout0, SPlus0} = A + B;

endmodule
