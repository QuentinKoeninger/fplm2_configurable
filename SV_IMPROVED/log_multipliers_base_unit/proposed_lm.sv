// Computes the logarithm approximation for a 4-bit floating point value

module proposed_lm(
    input logic [3:0] ma, mb,    // Input mantissa (no leading 1)
    input logic [1:0] Ea, Eb,
    input logic Ecin, Lcin,

    output logic [3:0] mp,      //
    output logic [1:0] Ep,
    output logic Ecout, Lcout
);
    logic [3:0] La, Lb, lp;

    log_approx_4bit log_approx_a(.m(ma), .l(La));
    log_approx_4bit log_approx_b(.m(mb), .l(Lb));

    assign {Lcout, lp} = {1'b0, La} + {1'b0, Lb} + {4'b0, Lcin};

    assign {Ecout, Ep} = {1'b0, Ea} - 3'b001 + {1'b0, Eb} + {2'b0, Ecin};

    anti_log_approx_4bit anti_log_approx(.s(lp), .p(mp));
endmodule