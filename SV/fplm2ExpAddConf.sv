module fplm2ExpAddConf (
    input   logic [4:0] Ea, Eb,
    input   logic [4:0] CarryEin,
    output  logic       CarryEout,
    output  logic [4:0] Ep
);


    // CarryEin + Ea + Eb - 15 to maintain IEEE-754 format
    assign {CarryEout, Ep} = {1'b0, Ea} + {1'b0, Eb} + {1'b0, CarryEin};

endmodule