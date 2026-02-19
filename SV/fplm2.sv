/*  Adaptation of floating-point logarithm multiplier-2 found       *
 *  in this article: https://ieeexplore.ieee.org/document/10305268  */

// Still need to finish: exception handling, testbench completion

module fplm2_16 (a, b, product);

    input logic [15:0]      a, b;
    output logic [15:0]     product;

    logic [9:0]             Ma, Mb, Mp;     // Input mantissa minus 1
    logic [4:0]             Ea, Eb, Ep;     // Input Exponents
    logic                   Sa, Sb, Sp;     // Input signs

    logic [9:0]             Map, Mbp, Mpp;  // Log of input/output mantissa, M'

    logic                   CarryE;         // Carry out from log addition
    logic                   CEandMpp9;      // Carry out and first bit of adder both 1'b1

    logic                   Pzero;          // Is the product zero  

    // Determine if Product is Zero, =1 if product should be zero
    assign Pzero = ~(|a) | ~(|b);              

    // Unpacking the Mantissa
    assign Ma = a[9:0];
    assign Mb = b[9:0];
    
    // Unpacking the exponenets
    assign Ea = a[14:10];
    assign Eb = b[14:10];
    // Unpacking the Signs
    assign Sa = a[9:0];
    assign Sb = b[9:0];

    // Log approximation equals M if less than 0.5 and equals ... 
    // (1+M)/2 otherwise, Multiplexers used for this process
    assign Map = Ma[9] ? {1'b1, Ma[9:1]} : Ma;
    assign Mbp = Mb[9] ? {1'b1, Mb[9:1]} : Mb;

    // Adds the log approximations of the mantissa
    fplm2MpAdd MpAdd(.Map, .Mbp, .CarryE, .Mpp);
    
    // Adds exponents with carryout from log addition
    fplm2ExpAdd ExpAdd(.Ea, .Eb, .CarryE, .Ep);

    // Calculate sign for the output
    assign Sp = Sa ^ Sb;

    // Value that determines if CarryOut and first bit are both 1
    assign CEandMpp9 = CarryE & Mpp[9];

    // Calculation of antilog and packing of Mantissa
    // Mpp < 1 => 1+Mpp
    // 1 <= Mpp < 1.5 => Mpp
    // 1.5 <= Mpp < 1.75 => Mpp-0.5
    // 1.75 <= Mpp < 2 => Mpp-0.25
    assign Mp[9] = (CEandMpp9) ? Mpp[8] : Mpp[9];
    assign Mp[8] = (CEandMpp9) ? (~Mpp[8]|Mpp[7]) : Mpp[8];
    assign Mp[7] = (CEandMpp9 & Mpp[8]) ? ~Mpp[7] : Mpp[7];
    assign Mp[6:0] = Mpp[6:0];

    // Packing of the product, if either input is zero product becomes zero
    assign product = Pzero ? 16'b0 : {Sp, Ep, Mp};

endmodule