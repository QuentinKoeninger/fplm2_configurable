module fplm2ExpAdd (
    input   logic [4:0] Ea, Eb,
    input   logic       CarryE,
    output  logic [4:0] Ep
);

    // CarryE + Ea + Eb - 15 to maintain IEEE-754 format
    assign Ep = Ea + Eb + {4'b0, CarryE} - 5'hF;

endmodule