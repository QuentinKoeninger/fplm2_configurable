// Computes the logarithm approximation for a 4-bit floating point value

module log_approx_4bit (
    input logic [3:0] m,    // Input mantissa (no leading 1)
    output logic [3:0] l    // Log approx of the input
    );

    assign l[3] = m[3] | (m[2] & m[1] & m[0]);
    assign l[2] = (m[2] & ~m[0]) | (m[2] & ~m[1]) | (m[3] & m[2]) | (~m[2] & m[1] & m[0]);
    assign l[1] = (~m[1] & m[0]) | (m[1] & ~m[0]) | (m[3] & m[2] & m[1]);
    assign l[0] = (m[3] & ~m[2] & ~m[0]) | (m[2] & ~m[1] & ~m[0]) | (~m[3] & m[1] & ~m[0]) | (m[3] & m[2] & m[1] & m[0]);

endmodule