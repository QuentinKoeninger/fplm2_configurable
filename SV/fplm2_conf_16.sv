/*  Adaptation of floating-point logarithm multiplier-2 found, configurable precision unit       *
 *  in this article: https://ieeexplore.ieee.org/document/10305268                               */

// Still need to finish: exception handling, testbench completion
// Radix-4 anti-logarithm approximation

module fplm2_conf_16 (Ea, Eb, Ma, Mb, Ep, Mp, Ma0, Mb0, isMSMult, CarryEin, CarryMin, CarryEout, CarryMout);

    input logic [10:0]      Ma, Mb;                 // Input Mantissa (appended with hidden 1 already)
    input logic [4:0]       Ea, Eb;                 // Input Exponents
    input logic             Ma0, Mb0;               // input mantissa most significant bit
    input logic             isMSMult;               // Determines if this is the most significant multiplier
    input logic             CarryMin;               // Carry in from log addition
    input logic [4:0]       CarryEin;               // Carry in from exp adder 

    output logic [9:0]      Mp;                     // Output Mantissa
    output logic [4:0]      Ep;                     // Output Exponents
    output logic            CarryEout, CarryMout;   // Carry out from exp/log addition

    logic [9:0]             Map, Mbp, Mpp;  // Log of input/output mantissa, M'

    logic                   CEandMpp9;      // Carry out and first bit of adder both 1'b1  

    // Log approximation equals M if less than 0.5 and equals ... 
    // (1+M)/2 otherwise, Multiplexers used for this process
    assign Map = Ma0 ? Ma[10:1] : Ma[9:0];
    assign Mbp = Mb0 ? Mb[10:1] : Mb[9:0];

    // Adds the log approximations of the mantissa
    fplm2MpAddConf MpAddConf(.Map, .Mbp, .CarryMin, .CarryMout, .Mpp);
    
    // Adds exponents with carryout from log addition
    fplm2ExpAddConf ExpAddConf(.Ea, .Eb, .CarryEin, .CarryEout, .Ep);

    // Value that determines if CarryOut and first bit are both 1, and that this is the most significant bit
    assign CEandMpp9 = CarryMout & Mpp[9] & isMSMult;

    // Calculation of antilog and packing of Mantissa, radix 4
    // Mpp < 1 => 1+Mpp
    // 1 <= Mpp < 1.5 => Mpp
    // 1.5 <= Mpp < 1.75 => Mpp-0.5
    // 1.75 <= Mpp < 2 => Mpp-0.25
    assign Mp[9] = (CEandMpp9) ? Mpp[8] : Mpp[9];
    assign Mp[8] = (CEandMpp9) ? (~Mpp[8]|Mpp[7]) : Mpp[8];
    assign Mp[7] = (CEandMpp9 & Mpp[8]) ? ~Mpp[7] : Mpp[7];
    assign Mp[6:0] = Mpp[6:0];

endmodule