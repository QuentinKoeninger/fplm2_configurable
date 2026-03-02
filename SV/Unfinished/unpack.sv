// Module still isn't finished, starting to work on edge cases in the IEEE-754 standard

module unpack (a, Sa, Ea, Ma, aQNAN, aSNAN, aZero, aInf, aSub);

    input logic [15:0]      a, b;
    output logic [9:0]      Ma;
    output logic [4:0]      Ea;
    output logic            Sa, aQNAN, aSNAN;
    output logic            aInf, aSub, aZero;

    logic                   aExpMax, overflow_a;

    assign {Sa, Ea, Ma} = a;

    assign aExpMax = &Ea;

    assign aQNAN = Ma[9] & overflow_a;

    assign aSNAN = (|Ma[8:0]) & (~Ma[9]) & aExpMax;

    assign aZero = ~(|Ma);

    assign aInf = (~(|Ma)) & overflow_a;

    assign aSub = ~(|Ea);

endmodule