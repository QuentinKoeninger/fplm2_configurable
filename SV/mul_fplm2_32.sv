/*  Adaptation of floating-point logarithm multiplier-2 found       *
 *  in this article: https://ieeexplore.ieee.org/document/10305268  */

// Still need to finish: exception handling, testbench completion

module mul_fplm2_32 (a, b, product);

    input logic [31:0]      a, b;           // Inputs, IEEE 754 16b FP
    output logic [31:0]     product;        // Output, ""

    logic [22:0]            Ma, Mb, Mp;     // Input mantissa minus 1
    logic [7:0]             Ea, Eb, Ep;     // Input Exponents
    logic                   Sa, Sb, Sp;     // Input signs

    logic                   Pzero;          // Is the product zero  

    // Determine if Product is Zero, =1 if product should be zero
    assign Pzero = ~(|a[30:0]) | ~(|b[30:0]);              

    // Unpacking the Mantissa
    assign Ma = a[22:0];
    assign Mb = b[22:0];
    
    // Unpacking the exponenets
    assign Ea = a[30:23];
    assign Eb = b[30:23];
    
    // Unpacking the Signs
    assign Sa = a[31];
    assign Sb = b[31];

    // Use fplm2 to calculate exponent and mantissa values of the product
    fplm2_32 fplm2_1(.Ea, .Eb, .Ma, .Mb, .Ep, .Mp);

    // Calculate sign for the output
    assign Sp = Sa ^ Sb;

    // Packing of the product, if either input is zero product becomes zero
    //assign product = Pzero ? {Sp, 15'b0} : {Sp, Ep, Mp};
    assign product = {Sp, (Pzero ? 31'b0 : {Ep, Mp})};

endmodule