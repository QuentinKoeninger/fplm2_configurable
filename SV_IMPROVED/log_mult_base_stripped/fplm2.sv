// Computes the logarithm approximation for a 4-bit floating point value

module fplm2(
    input logic [3:0] ma, mb,    // Input mantissa (yes leading 1)
    input logic [1:0] Ea, Eb,

    output logic [3:0] mp,      // Output mantissa (no leading 1)
    output logic [1:0] Ep,
    output logic Ecout
);
    logic [3:0] La, Lb, lp;
    logic Lcout;

    log_fplm2_4bit log_approx_a(.M({1'b1, ma}), .l(La), .ms_m_bit(ma[3]));
    log_fplm2_4bit log_approx_b(.M({1'b1, mb}), .l(Lb), .ms_m_bit(mb[3]));

    assign {Lcout, lp} = {1'b0, La} + {1'b0, Lb};

    assign {Ecout, Ep} = {1'b0, Ea} + {1'b0, Eb} + {2'b0, Lcout} +3'b111;

    anti_log_fplm2_4bit anti_log_approx(.s({Lcout, lp}), .p(mp), .is_ms_mult(1'b1));
endmodule