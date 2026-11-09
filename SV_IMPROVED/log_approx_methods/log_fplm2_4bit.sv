// Computes the logarithm approximation for a 4-bit floating point value

module log_fplm2_4bit (
    input logic [4:0] M,    // Input mantissa (yes leading 1)
    input logic ms_m_bit,
    output logic [3:0] l    // Log approx of the input
    );

    assign l = ms_m_bit ? M[4:1] : M[3:0];

endmodule