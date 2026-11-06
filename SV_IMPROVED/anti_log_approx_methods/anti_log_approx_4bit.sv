// Computes the logarithm approximation for a 4-bit floating point value

module anti_log_approx_4bit (
    input logic [3:0] s,    // Input mantissa (no leading 1)
    output logic [3:0] p    // Log approx of the input
    );

    assign p[3] = s[3] & (s[2] | s[1] | s[0]);
    assign p[2] = (s[3] & ~s[2] & ~s[1] & ~s[0]) | (s[2] & s[1]) | (s[2] & s[0]);
    assign p[1] = (s[1] & s[0]) | (s[2] & ~s[1] & ~s[0]) | (s[3] & ~s[1] & ~s[0]);
    assign p[0] = (s[1] & ~s[0]) | (s[2] & ~s[0]) | (s[3] & s[2] & s[1]) | (s[3] & ~s[2] & ~s[0]) | (~s[3] & ~s[2] & ~s[1] & s[0]);
endmodule