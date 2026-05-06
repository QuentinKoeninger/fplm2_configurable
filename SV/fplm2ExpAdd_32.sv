module fplm2ExpAdd_32 (
    input   logic [7:0] Ea, Eb,
    input   logic       CarryE,
    output  logic [7:0] Ep
);

    // CarryE + Ea + Eb - 15 to maintain IEEE-754 format
    assign Ep = Ea + Eb + {7'b0, CarryE} - 8'h7F;

endmodule