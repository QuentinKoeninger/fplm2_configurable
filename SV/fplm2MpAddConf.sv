module fplm2MpAddConf (
    input   logic [9:0] Map, Mbp,
    input   logic       CarryMin,
    output  logic       CarryMout,
    output  logic [9:0] Mpp
);

    // Adding logs of mantissa as well as the carry in if necessary
    assign {CarryMout, Mpp} = {1'b0, Map} + {1'b0, Mbp} + {10'b0, CarryMin};

endmodule