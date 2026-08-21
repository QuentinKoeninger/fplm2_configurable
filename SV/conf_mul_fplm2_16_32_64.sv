/*  Adaptation of floating-point logarithm multiplier-2 found       *
 *  in this article: https://ieeexplore.ieee.org/document/10305268  */

// Still need to finish: exception handling, testbench completion

module conf_mul_fplm2_16_32 (a, b, product, precision);

    input logic [95:0]      a, b;           // Inputs, IEEE 754, first 64 bits used for 64 and 2x32 bit multiplication, the final bits are used for 2x64 bit multiplication 
    output logic [63:0]     product;        // Output, ""
    input logic [1:0]       precision;      // Is this 16/32/64 bit multiplication 00 = 16bit, 01 = 32bit, 1X = 64bit

    logic [5:0] [10:0]      Ma16, Mb16;         // Input mantissa 16bit
    logic [1:0] [23:0]      Ma32, Mb32;         // Input Mantissa 32bit
    logic       [54:0]      Ma64, Mb64;         // Input Mantissa 64bit
    logic [5:0] [4:0]       Ea16, Eb16, Ep16;   // 16 bit Input/Output Exponents
    logic [1:0] [7:0]       Ea32, Eb32, Ep32;   // 32 bit Input/Output Exponents
    logic [10:0]            Ea64, Eb64, Ep64;   // 64 bit Input/Output Exponents
    logic [5:0]             Sa, Sb, Sp;         // Input/output Signs
    logic [5:0]             Ma00, Mb00;         // Most significant bit of input 16 bit
    logic [5:0] [4:0]       CarryEin;           // Carry for the exponent
    logic [5:0]             CarryMin, CarryMout, CarryEout;
    logic [5:0] [10:0]      Ma, Mb;
    logic [5:0] [4:0]       Ea, Eb;
    logic [5:0] [4:0]       Ep;
    logic [5:0] [9:0]       Mp;
    logic [7:0]             EpAdjust32;

    logic [5:0]             isMSMult;
    logic [5:0]             Pzero16;
    logic [1:0]             Pzero32;   // Is the product zero
    logic                   Pzero64;  

    // Determine if Product is Zero, =1 if product should be zero for given multiplication option
    assign Pzero16[5] = ~(|a[94:80]) | ~(|b[94:80]);
    assign Pzero16[4] = ~(|a[78:64]) | ~(|b[78:64]);
    assign Pzero16[3] = ~(|a[62:48]) | ~(|b[62:48]);
    assign Pzero16[2] = ~(|a[46:32]) | ~(|b[46:32]);
    assign Pzero16[1] = ~(|a[30:16]) | ~(|b[30:16]);
    assign Pzero16[0] = ~(|a[14:0]) | ~(|b[14:10]);

    assign Pzero32[1] = ~(|a[94:64]) | ~(|b[94:64]);
    assign Pzero32[0] = ~(|a[62:32]) | ~(|b[62:32]);

    assign Pzero64 = ~(|a[94:32]) | ~(|b[94:32]); 

    // Unpacking the 16-bit Inputs
    assign {Sa[5], Ea16[5], Ma16[5]} = {a[95:90], 1'b1, a[89:80]};
    assign {Sb[5], Eb16[5], Mb16[5]} = {b[95:90], 1'b1, b[89:80]};

    assign {Sa[4], Ea16[4], Ma16[4]} = {a[79:74], 1'b1, a[73:64]};
    assign {Sb[4], Eb16[4], Mb16[4]} = {b[79:74], 1'b1, b[73:64]};

    assign {Sa[3], Ea16[3], Ma16[3]} = {a[63:58], 1'b1, a[57:48]};
    assign {Sb[3], Eb16[3], Mb16[3]} = {b[63:58], 1'b1, b[57:48]};

    assign {Sa[2], Ea16[2], Ma16[2]} = {a[47:42], 1'b1, a[41:32]};
    assign {Sb[2], Eb16[2], Mb16[2]} = {b[47:42], 1'b1, b[41:32]};

    assign {Sa[1], Ea16[1], Ma16[1]} = {a[31:26], 1'b1, a[25:16]};
    assign {Sb[1], Eb16[1], Mb16[1]} = {b[31:26], 1'b1, b[25:16]};

    assign {Sa[0], Ea16[0], Ma16[0]} = {a[15:10], 1'b1, a[9:0]};
    assign {Sb[0], Eb16[0], Mb16[0]} = {b[15:10], 1'b1, b[9:0]};

    // Unpacking the 32-bit Inputs
    assign {Ea32[1], Ma32[1]} = {a[94:87], 1'b1, a[86:64]};
    assign {Eb32[1], Mb32[1]} = {b[94:87], 1'b1, b[86:64]};

    assign {Ea32[0], Ma32[0]} = {a[62:55], 1'b1, a[54:32]};
    assign {Eb32[0], Mb32[0]} = {b[62:55], 1'b1, b[54:32]};

    // Unpacking the 64-bit Input
    assign {Ea64, Ma64} = {a[94:84], 1'b1, a[83:32]};
    assign {Eb64, Mb64} = {b[94:84], 1'b1, b[83:32]};

    // Determining MS bits for each unit multiplier
    assign Ma00[5] = Ma16[5][10];
    assign Mb00[5] = Mb16[5][10];

    assign Ma00[4] = (|precision) ? Ma16[5][10] : Ma16[4][10];
    assign Mb00[4] = (|precision) ? Mb16[5][10] : Mb16[4][10];
    
    assign Ma00[3] = (|precision) ? Ma16[5][10] : Ma16[3][10];
    assign Mb00[3] = (|precision) ? Mb16[5][10] : Mb16[3][10];

    assign Ma00[2] = precision[1] ? Ma16[5][10] : Ma16[2][10];
    assign Mb00[2] = precision[1] ? Mb16[5][10] : Mb16[2][10];

    assign Ma00[1] = precision[1] ? Ma16[5][10] : (precision[0] ? Ma16[2][10] : Ma[1][10]);
    assign Mb00[1] = precision[1] ? Mb16[5][10] : (precision[0] ? Mb16[2][10] : Mb[1][10]);

    assign Ma00[0] = precision[1] ? Ma16[5][10] : (precision[0] ? Ma16[2][10] : Ma[0][10]);
    assign Mb00[0] = precision[1] ? Mb16[5][10] : (precision[0] ? Mb16[2][10] : Mb[0][10]);

    // Setting up Mantissa Inputs to unit multipliers <- START HERE NEXT TIME
    assign Ea0 = is32bit ? Ea32[7:3] : Ea16;
    assign Ea1 = is32bit ? {Ea32[2:0], 2'b0} : 5'b0;
    assign Ea2 = 5'b0;

    // Setting up Exponent B Inputs
    assign Eb0 = is32bit ? Eb32[7:3] : Eb16;
    assign Eb1 = is32bit ? {Eb32[2:0], 2'b0} : 5'b0;
    assign Eb2 = 5'b0;

    // Setting up Mantissa A inputs
    assign Ma0 = is32bit ? Ma32[23:13] : Ma16;
    assign Ma1 = is32bit ? Ma32[13:3] : 11'b0;
    assign Ma2 = is32bit ? {Ma32[3:0], 7'b0} : 11'b0;

    // Setting up Mantissa B inputs
    assign Mb0 = is32bit ? Mb32[23:13] : Mb16;
    assign Mb1 = is32bit ? Mb32[13:3] : 11'b0;
    assign Mb2 = is32bit ? {Mb32[3:0], 7'b0} : 11'b0;

    // Setting up Exponent carry Inputs
    assign CarryEin[0] = {4'b0, (is32bit ? CarryEout[1] : CarryMout[0])};
    assign CarryEin[1] = {2'b0, (is32bit ? CarryMout[0] : 1'b0), 2'b0};
    assign CarryEin[2] = 5'b0;

    // Setting up Mantissa Carry Inputs
    assign CarryMin[0] = is32bit ? CarryMout[1] : 1'b0;
    assign CarryMin[1] = is32bit ? CarryMout[2] : 1'b0;
    assign CarryMin[2] = 1'b0;

    // Use fplm2 to calculate exponent and mantissa values of the product
    fplm2_conf_16 fplm2_conf(.Ea(Ea), .Eb(Eb), .Ma(Ma), .Mb(Mb), .Ep(Ep), .Mp(Mp), .Ma0(Ma0), .Mb0(Mb0), 
                                .isMSMult(isMSMult), .CarryEin(CarryEin), .CarryMin(CarryMin),
                                .CarryEout(CarryEout), .CarryMout(CarryMout));

    // Calculate sign for the output
    assign Sp = Sa ^ Sb;

    assign EpAdjust32 = {Ep[0], Ep[1][4:2]} - 8'b0111_1111;

    // Packing of the product, if either input is zero product becomes zero
    //assign product = Pzero ? {Sp, 15'b0} : {Sp, Ep, Mp};
    assign product = {Sp, ((Pzero32 | Pzero16) ? 31'b0 : (is32bit ? {EpAdjust32, Mp[0], Mp[1], Mp[2][9:7]} : {(Ep[0]-5'b0_1111), Mp[0], 16'b0}))};

endmodule