module fplm2MpAdd_32 (
    input   logic [22:0] Map, Mbp,
    output  logic       CarryE,
    output  logic [22:0] Mpp
);

    // CarryE + Ea + Eb - 15 to maintain IEEE-754 format
    assign {CarryE, Mpp} = {1'b0, Map} + {1'b0, Mbp};

endmodule