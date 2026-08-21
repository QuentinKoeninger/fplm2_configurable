/*  Adaptation of floating-point logarithm multiplier-2 found       *
 *  in this article: https://ieeexplore.ieee.org/document/10305268  */

// Still need to finish: exception handling, testbench completion

module fplm2_32 (Ea, Eb, Ma, Mb, Ep, Mp);

    input logic [22:0]      Ma, Mb; // Input Mantissa
    input logic [7:0]       Ea, Eb; // Input Exponents
    output logic [22:0]     Mp;     // Output Mantissa
    output logic [7:0]      Ep;     // Output Exponents

    logic [23:0]            Map, Mbp; 
    logic [22:0]            Mpp;  // Log of input/output mantissa, M'

    logic                   CarryE;         // Carry out from log addition
    logic                   CEandMpp22;     // Carry out and first bit of adder both 1'b1           

    // Log approximation equals M if less than 0.5 and equals ... 
    // (1+M)/2 otherwise, Multiplexers used for this process
    assign Map = Ma[22] ? {1'b1, Ma} : {Ma, 1'b0};    // CORRECT: assign Map = Ma[22] ? {1'b1, Ma[22:1]} : Ma;
    assign Mbp = Mb[22] ? {1'b1, Mb} : {Mb, 1'b0};    // CORRECT: assign Mbp = Mb[22] ? {1'b1, Mb[22:1]} : Mb;

    // Adds the log approximations of the mantissa
    fplm2MpAdd_32 MpAdd(.Map, .Mbp, .CarryE, .Mpp);
    
    // Adds exponents with carryout from log addition
    fplm2ExpAdd_32 ExpAdd(.Ea, .Eb, .CarryE, .Ep);

    // Value that determines if CarryOut and first bit are both 1
    assign CEandMpp22 = CarryE & Mpp[22];

    // Calculation of antilog and packing of Mantissa
    // Mpp < 1 => 1+Mpp
    // 1 <= Mpp < 1.5 => Mpp
    // 1.5 <= Mpp < 1.75 => Mpp-0.5
    // 1.75 <= Mpp < 2 => Mpp-0.25
    assign Mp[22] = (CEandMpp22) ? Mpp[21] : Mpp[22];
    assign Mp[21] = (CEandMpp22) ? (~Mpp[21]|Mpp[20]) : Mpp[21];
    assign Mp[20] = (CEandMpp22 & Mpp[21]) ? ~Mpp[20] : Mpp[20];
    assign Mp[19:0] = Mpp[19:0];

endmodule