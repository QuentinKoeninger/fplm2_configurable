// Computes the logarithm approximation for a 4-bit floating point value

module fplm2(
    input logic [4:0] ma, mb,    // Input mantissa (yes leading 1)
    input logic [1:0] Ea, Eb,
    input logic Ecin, Lcin,
    input logic is_ms_mult,
    input logic ma_1, mb_1,

    output logic [3:0] mp,      // Output mantissa (no leading 1)
    output logic [1:0] Ep,
    output logic Ecout, Lcout
);
    logic [3:0] La, Lb, lp;

    log_fplm2_4bit log_approx_a(.M(ma), .l(La), .ms_m_bit(ma_1));
    log_fplm2_4bit log_approx_b(.M(mb), .l(Lb), .ms_m_bit(mb_1));

    assign {Lcout, lp} = {1'b0, La} + {1'b0, Lb} + {4'b0, Lcin};

    assign {Ecout, Ep} = {1'b0, Ea} + {1'b0, Eb} + {2'b0, Ecin};

    anti_log_fplm2_4bit anti_log_approx(.s({Lcout, lp}), .p(mp), .is_ms_mult(is_ms_mult));
endmodule