/*  Adaptation of floating-point logarithm multiplier-2 found       *
 *  in this article: https://ieeexplore.ieee.org/document/10305268  */

// Still need to finish: exception handling, testbench completion

module conf_mul_fplm2_16_32 (a, b, product, precision);

    input logic [95:0]      a, b;           // Inputs, IEEE 754, first 64 bits used for 64 and 2x32 bit multiplication, the final bits are used for 2x64 bit multiplication
    output logic [95:0]     product;        // Output, ""
    input logic [1:0]       precision;      // Is this 16/32/64 bit multiplication 00 = 16bit, 01 = 32bit, 1X = 64bit

    logic [5:0] [10:0]      Ma16, Mb16;         // Input mantissa 16bit
    logic [1:0] [23:0]      Ma32, Mb32;         // Input Mantissa 32bit
    logic       [52:0]      Ma64, Mb64;         // Input Mantissa 64bit
    logic [5:0] [4:0]       Ea16, Eb16, Ep16;   // 16 bit Input/Output Exponents
    logic [1:0] [7:0]       Ea32, Eb32, Ep32;   // 32 bit Input/Output Exponents
    logic [10:0]            Ea64, Eb64, Ep64;   // 64 bit Input/Output Exponents
    logic [5:0]             Sa, Sb, Sp;         // Input/output Signs
    logic [5:0]             Ma00, Mb00;         // Most significant bit of mantissa input 16 bit
    logic [5:0] [4:0]       CarryEin;           // Carry for the exponent
    logic [5:0]             CarryMin, CarryMout, CarryEout;
    logic [5:0] [10:0]      Ma, Mb;
    logic [5:0] [4:0]       Ea, Eb;
    logic [5:0] [4:0]       Ep;
    logic [5:0] [9:0]       Mp;
    logic [5:0] [5:0]       EpAdjusted16;
    logic [1:0] [8:0]       EpAdjusted32;
    logic [11:0]            EpAdjusted64;

    logic [5:0]             isMSMult;
    logic [5:0]             Pzero16;
    logic [1:0]             Pzero32;   // Is the product zero
    logic                   Pzero64;
    logic                   is64bit, is32bit, isNot16bit;

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

    assign {Ea32[0], Ma32[0]} = {a[46:39], 1'b1, a[38:16]};
    assign {Eb32[0], Mb32[0]} = {b[46:39], 1'b1, b[38:16]};

    // Unpacking the 64-bit Input
    assign {Ea64, Ma64} = {a[94:84], 1'b1, a[83:32]};
    assign {Eb64, Mb64} = {b[94:84], 1'b1, b[83:32]};

    assign {is64bit, is32bit} = precision;  // is32bit = operation is 32bit if the operation is not 64bit
    assign isNot16bit = is64bit | is32bit; 

    // Determining MS bits for each unit multiplier
    assign Ma00[5] = Ma16[5][9];
    assign Mb00[5] = Mb16[5][9];

    assign Ma00[4] = (isNot16bit) ? Ma16[5][9] : Ma16[4][9];
    assign Mb00[4] = (isNot16bit) ? Mb16[5][9] : Mb16[4][9];
    
    assign Ma00[3] = (isNot16bit) ? Ma16[5][9] : Ma16[3][9];
    assign Mb00[3] = (isNot16bit) ? Mb16[5][9] : Mb16[3][9];

    assign Ma00[2] = is64bit ? Ma16[5][9] : Ma16[2][9];
    assign Mb00[2] = is64bit ? Mb16[5][9] : Mb16[2][9];

    assign Ma00[1] = is64bit ? Ma16[5][9] : (is32bit ? Ma16[2][9] : Ma16[1][9]);
    assign Mb00[1] = is64bit ? Mb16[5][9] : (is32bit ? Mb16[2][9] : Mb16[1][9]);

    assign Ma00[0] = is64bit ? Ma16[5][9] : (is32bit ? Ma16[2][9] : Ma16[0][9]);
    assign Mb00[0] = is64bit ? Mb16[5][9] : (is32bit ? Mb16[2][9] : Mb16[0][9]);

    // Setting up Mantissa Inputs to unit multipliers
    assign Ma[5] = is64bit ? Ma64[52:42] : (is32bit ? Ma32[1][23:13] : Ma16[5][10:0]);
    assign Mb[5] = is64bit ? Mb64[52:42] : (is32bit ? Mb32[1][23:13] : Mb16[5][10:0]);

    assign Ma[4] = is64bit ? Ma64[42:32] : (is32bit ? Ma32[1][13:3] : Ma16[4][10:0]);
    assign Mb[4] = is64bit ? Mb64[42:32] : (is32bit ? Mb32[1][13:3] : Mb16[4][10:0]);

    assign Ma[3] = is64bit ? Ma64[32:22] : (is32bit ? {Ma32[1][3:0], 7'b0} : Ma16[3][10:0]);
    assign Mb[3] = is64bit ? Mb64[32:22] : (is32bit ? {Mb32[1][3:0], 7'b0} : Mb16[3][10:0]);

    assign Ma[2] = is64bit ? Ma64[22:12] : (is32bit ? Ma32[0][23:13] : Ma16[2][10:0]);
    assign Mb[2] = is64bit ? Mb64[22:12] : (is32bit ? Mb32[0][23:13] : Mb16[2][10:0]);

    assign Ma[1] = is64bit ? Ma64[12:2] : (is32bit ? Ma32[0][13:3] : Ma16[1][10:0]);
    assign Mb[1] = is64bit ? Mb64[12:2] : (is32bit ? Mb32[0][13:3] : Mb16[1][10:0]);

    assign Ma[0] = is64bit ? {Ma64[2:0], 8'b0} : (is32bit ? {Ma32[0][3:0], 7'b0} : Ma16[0][10:0]);
    assign Mb[0] = is64bit ? {Mb64[2:0], 8'b0} : (is32bit ? {Mb32[0][3:0], 7'b0} : Mb16[0][10:0]);

    // Setting up the Exponent Inputs to the unit multipliers
    assign Ea[5] = is64bit ? Ea64[10:6] : (is32bit ? Ea32[1][7:3] : Ea16[5]);
    assign Eb[5] = is64bit ? Eb64[10:6] : (is32bit ? Eb32[1][7:3] : Eb16[5]);

    assign Ea[4] = is64bit ? Ea64[5:1] : (is32bit ? {Ea32[1][2:0], 2'b0} : Ea16[4]);
    assign Eb[4] = is64bit ? Eb64[5:1] : (is32bit ? {Eb32[1][2:0], 2'b0} : Eb16[4]);

    assign Ea[3] = is64bit ? {Ea64[0], 4'b0} : (is32bit ? 5'b0 : Ea16[3]);
    assign Eb[3] = is64bit ? {Eb64[0], 4'b0} : (is32bit ? 5'b0 : Eb16[3]);

    assign Ea[2] = is64bit ? 5'b0 : (is32bit ? Ea32[0][7:3] : Ea16[2]);
    assign Eb[2] = is64bit ? 5'b0 : (is32bit ? Eb32[0][7:3] : Eb16[2]);

    assign Ea[1] = is64bit ? 5'b0 : (is32bit ? {Ea32[0][2:0], 2'b0} : Ea16[1]);
    assign Eb[1] = is64bit ? 5'b0 : (is32bit ? {Eb32[0][2:0], 2'b0} : Eb16[1]);

    assign Ea[0] = (isNot16bit) ? 5'b0 : Ea16[0];
    assign Eb[0] = (isNot16bit) ? 5'b0 : Eb16[0];

    // Setting up the Mantissa Carry Inputs to the unit multipliers
    // assign CarryMin = is64bit ? {CarryMout[4:0], 1'b0} : (is32bit ? {CarryMout[4:3], 1'b0, CarryMout[1:0], 1'b0} : 5'b0); OLD CODE
    assign CarryMin = {((isNot16bit) ? CarryMout[4:3] : 2'b0), (is64bit ? CarryMout[2] : 1'b0), ((isNot16bit) ? CarryMout[1:0] : 2'b0), 0'b0};
    
    // Setting up the Exponent Carry Inputs to the unit multipliers
    assign CarryEin[5] = {4'b0, ((isNot16bit) ? CarryEout[4] : CarryMout[5])};
    assign CarryEin[4] = is64bit ? {4'b0, CarryEout[3]} : (is32bit ? {2'b0, CarryMout[5], 2'b0} : {4'b0, CarryMout[4]});
    assign CarryEin[3] = is64bit ? {CarryMout[5], 4'b0} : (is32bit ? 5'b0 : {4'b0, CarryMout[3]});
    assign CarryEin[2] = {4'b0, (is64bit ? 1'b0 : (is32bit ? CarryEout[1] : CarryMout[2]))};
    assign CarryEin[1] = is64bit ? 5'b0 : (is32bit ? {2'b0, CarryMout[2], 2'b0} : {4'b0, CarryMout[1]});
    assign CarryEin[0] = {4'b0, ((isNot16bit) ? 1'b0 : CarryMout[0])};

    // Setup isMSMult
    assign isMSMult = {1'b1, (isNot16bit ? 2'b0 : 2'b11), (is64bit ? (1'b0 : 1'b1)), (isNot16bit ? 2'b0 : 2'b11)};

    // Use fplm2 to calculate exponent (unadjusted) and mantissa values of the product
    fplm2_conf_16 fplm2_conf [5:0] (.Ea(Ea), .Eb(Eb), .Ma(Ma), .Mb(Mb), .Ep(Ep), .Mp(Mp), .Ma0(Ma00), .Mb0(Mb00),
                                .isMSMult(isMSMult), .CarryEin(CarryEin), .CarryMin(CarryMin),
                                .CarryEout(CarryEout), .CarryMout(CarryMout));

    // Calculate sign for the output
    assign Sp = Sa ^ Sb;

    // Calculate the Exponent Adjustments
    assign Ep16[5] = {CarryEout[5], Ea[5]} - 6'b00_1111;
    assign Ep16[4] = {CarryEout[4], Ea[4]} - 6'b00_1111;
    assign Ep16[3] = {CarryEout[3], Ea[3]} - 6'b00_1111;
    assign Ep16[2] = {CarryEout[2], Ea[2]} - 6'b00_1111;
    assign Ep16[1] = {CarryEout[1], Ea[1]} - 6'b00_1111;
    assign Ep16[0] = {CarryEout[0], Ea[0]} - 6'b00_1111;

    assign Ep32[1] = {CarryEout[5], Ea[5], Ea[4][4:2]} - 9'b0_0111_1111;
    assign Ep32[0] = {CarryEout[2], Ea[2], Ea[1][4:2]} - 9'b0_0111_1111;

    assign Ep64 = {CarryEout[5], Ea[5], Ea[4], Ea[3][4]} - 12'b0011_1111_1111;

    // Packing of the product, if either input is zero product becomes zero
    //assign product = Pzero ? {Sp, 15'b0} : {Sp, Ep, Mp};
    assign product = is64bit ? {Sp[5], (Pzero64 ? {Ep64[10:0], Mp[5], Mp[4], Mp[3], Mp[2], Mp[1], Mp[0][9:8]} : 63'b0), 32'b0}
                        : (is32bit ? {Sp[5], (Pzero32[1] ? {Ep32[1][7:0], Mp[5], Mp[4], Mp[3][9:7]} : 31'b0), 16'b0,
                            Sp[2], (Pzero32[0] ? {Ep32[0][7:0], Mp[2], Mp[1], Mp[0][9:7]} : 31'b0), 16'b0}
                            : {Sp[5], (Pzero16[5] ? {Ep16[5][4:0], Ma[5]} : 15'b0), Sp[5], (Pzero16[4] ? {Ep16[4][4:0], Ma[4]} : 15'b0),
                                Sp[3], (Pzero16[3] ? {Ep16[3][4:0], Ma[3]} : 15'b0), Sp[2], (Pzero16[2] ? {Ep16[2][4:0], Ma[2]} : 15'b0),
                                Sp[1], (Pzero16[1] ? {Ep16[1][4:0], Ma[1]} : 15'b0), Sp[0], (Pzero16[0] ? {Ep16[0][4:0], Ma[0]} : 15'b0)});

endmodule