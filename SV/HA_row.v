/******************************************************************
*
*@author	TuanND
*@date 		Row of Half Adder	
******************************************************************/

module HA_row (XS, XC, A, B);
    parameter WIDTH = 54;

    input [WIDTH-1:0] A, B;
    output [WIDTH-1:0] XS;
    output [WIDTH-1:0] XC;

    //generate a row of HA
    genvar i;
    generate
    for(i = 0; i < WIDTH; i = i + 1) begin: ha_inst
        half_adder  ha(.Cout(XC[i]),
                       .Sum(XS[i]),
                       .A(A[i]),
                       .B(B[i])
                   );
    end
    endgenerate
endmodule
