/*  Adaptation of floating-point logarithm multiplier-2 found       *
 *  in this article: https://ieeexplore.ieee.org/document/10305268  */

// Still need to finish: exception handling, testbench completion

module conf_mul_fplm2 (a, b, product);

    input logic [15:0]      a, b;           // Inputs, IEEE 754 16b FP
    output logic [15:0]     product;        // Output, ""

    logic [10:0]            Ma, Mb;         // Input mantissa
    logic [9:0]             Mp;             // Output mantissa minus 1
    logic [4:0]             Ea, Eb, Ep;     // Input Exponents
    logic                   Sa, Sb, Sp;     // Input signs
    logic                   Ma0, Mb0;       // Most significant bit of input
    logic                   isMSMult;       // Is this the most significant multiplier
    logic [4:0]             CarryEin;       // Carry for the exponent
    logic                   CarryMin, CarryMout, CarryEout;



    logic                   Pzero;          // Is the product zero  

    assign Ma0 = a[9];
    assign Mb0 = b[9];
    assign isMSMult = 1'b1;
    assign CarryEin = {4'b0000, CarryMout};
    assign CarryMin = 1'b0;

    // Determine if Product is Zero, =1 if product should be zero
    assign Pzero = ~(|a[14:0]) | ~(|b[14:0]);              

    // Unpacking the Mantissa
    assign Ma = {1'b1, a[9:0]};
    assign Mb = {1'b1, b[9:0]};
    
    // Unpacking the exponenets
    assign Ea = a[14:10];
    assign Eb = b[14:10];
    
    // Unpacking the Signs
    assign Sa = a[15];
    assign Sb = b[15];

    // Use fplm2 to calculate exponent and mantissa values of the product
    fplm2_conf_16 fplm2_conf(.Ea, .Eb, .Ma, .Mb, .Ep, .Mp, .Ma0, .Mb0, .isMSMult, .CarryEin, .CarryMin, .CarryEout, .CarryMout);

    // Calculate sign for the output
    assign Sp = Sa ^ Sb;

    // Packing of the product, if either input is zero product becomes zero
    //assign product = Pzero ? {Sp, 15'b0} : {Sp, Ep, Mp};
    assign product = {Sp, (Pzero ? 15'b0 : {Ep, Mp})};

endmodule