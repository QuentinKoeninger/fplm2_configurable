// Computes the logarithm approximation for a 4-bit floating point value

module anti_log_fplm2_4bit (
    input logic [4:0] s,    // Input mantissa (no leading 1)
    input logic is_ms_mult,
    output logic [3:0] p    // Log approx of the input
    );

    assign p[3] = is_ms_mult ? s[3] : ((s[4] & s[3]) ? s[3] : s[2]);
    assign p[2] = is_ms_mult ? s[3] : ((s[4] & s[3]) ? (~s[2]|s[1]) : s[2]);
    assign p[1] = is_ms_mult ? s[3] : ((s[4] & s[3] & s[2]) ? ~s[1] : s[1]);
    assign p[0] = s[0];
endmodule