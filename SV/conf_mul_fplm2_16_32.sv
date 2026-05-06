/*  Adaptation of floating-point logarithm multiplier-2 found       *
 *  in this article: https://ieeexplore.ieee.org/document/10305268  */

// Still need to finish: exception handling, testbench completion

module conf_mul_fplm2_16_32 (a, b, product, is32bit);

    input logic [31:0]      a, b;           // Inputs, IEEE 754 16b FP
    output logic [31:0]     product;        // Output, ""
    input logic             is32bit;        // Is this 32 bit multiplication

    logic [10:0]            Ma16, Mb16;         // Input mantissa 16bit
    logic [23:0]            Ma32, Mb32;         // Input Mantissa 32bit
    logic [4:0]             Ea16, Eb16, Ep16;   // 16 bit Input Exponents
    logic [7:0]             Ea32, Eb32, Ep32;   // 32 bit Input Exponents
    logic                   Sa, Sb, Sp;         // Input signs
    logic                   Ma00_16, Mb00_16, Ma00;   // Most significant bit of input 16 bit
    logic                   Ma00_32, Mb00_32, Mb00;   // Most significant bit of input 16 bit
    logic [2:0] [4:0]       CarryEin;           // Carry for the exponent
    logic [2:0]             CarryMin, CarryMout, CarryEout;
    logic [10:0]            Ma0, Mb0, Ma1, Mb1, Ma2, Mb2;
    logic [4:0]             Ea0, Eb0, Ea1, Eb1, Ea2, Eb2;
    logic [2:0] [4:0]       Ep;
    logic [2:0] [9:0]       Mp;
    logic [7:0]             EpAdjust32;



    logic                   Pzero16, Pzero32;   // Is the product zero  


    assign Ma00_16 = a[25];
    assign Mb00_16 = b[25];
    assign Ma00_32 = a[22];
    assign Mb00_32 = b[22];

    assign Ma00 = is32bit ? Ma00_32 : Ma00_16;
    assign Mb00 = is32bit ? Mb00_32 : Mb00_16;

    // Determine if Product is Zero, =1 if product should be zero
    assign Pzero16 = ~(|a[30:16]) | ~(|b[30:16]);   
    assign Pzero32 = ~(|a[30:0]) | ~(|b[30:0]);   

    // Unpacking the Mantissa
    assign Ma16 = {1'b1, a[25:16]};
    assign Mb16 = {1'b1, b[25:16]};
    assign Ma32 = {1'b1, a[22:0]};
    assign Mb32 = {1'b1, b[22:0]};
    
    // Unpacking the exponenets
    assign Ea16 = a[30:26];
    assign Eb16 = b[30:26];
    assign Ea32 = a[30:23];
    assign Eb32 = b[30:23];
    
    // Unpacking the Signs
    assign Sa = a[31];
    assign Sb = b[31];

    // Setting up Exponent A Inputs
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
    fplm2_conf_16 fplm2_conf_0(.Ea(Ea0), .Eb(Eb0), .Ma(Ma0), .Mb(Mb0), .Ep(Ep[0]), .Mp(Mp[0]), .Ma0(Ma00), .Mb0(Mb00), 
                                .isMSMult(1'b1), .CarryEin(CarryEin[0]), .CarryMin(CarryMin[0]),
                                .CarryEout(CarryEout[0]), .CarryMout(CarryMout[0]));
    fplm2_conf_16 fplm2_conf_1(.Ea(Ea1), .Eb(Eb1), .Ma(Ma1), .Mb(Mb1), .Ep(Ep[1]), .Mp(Mp[1]), .Ma0(Ma00), .Mb0(Mb00), 
                                .isMSMult(1'b0), .CarryEin(CarryEin[1]), .CarryMin(CarryMin[1]), 
                                .CarryEout(CarryEout[1]), .CarryMout(CarryMout[1]));
    fplm2_conf_16 fplm2_conf_2(.Ea(Ea2), .Eb(Eb2), .Ma(Ma2), .Mb(Mb2), .Ep(Ep[2]), .Mp(Mp[2]), .Ma0(Ma00), .Mb0(Mb00), 
                                .isMSMult(1'b0), .CarryEin(CarryEin[2]), .CarryMin(CarryMin[2]), 
                                .CarryEout(CarryEout[2]), .CarryMout(CarryMout[2]));

    // Calculate sign for the output
    assign Sp = Sa ^ Sb;

    assign EpAdjust32 = {Ep[0], Ep[1][4:2]} - 8'b0111_1111;

    // Packing of the product, if either input is zero product becomes zero
    //assign product = Pzero ? {Sp, 15'b0} : {Sp, Ep, Mp};
    assign product = {Sp, ((Pzero32 | Pzero16) ? 31'b0 : (is32bit ? {EpAdjust32, Mp[0], Mp[1], Mp[2][9:7]} : {(Ep[0]-5'b0_1111), Mp[0], 16'b0}))};

endmodule