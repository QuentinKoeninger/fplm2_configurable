// Computes the logarithm approximation for a 4-bit floating point value

module proposed_lm(
    input logic [3:0] ma, mb,    // Input mantissa (no leading 1)
    input logic [2:0] Ea, Eb,
    input logic [1:0] Ecin,
    input logic Lcin,
    input logic [4:0] Ebias,

    output logic [3:0] mp,      //
    output logic [2:0] Ep, 
    output logic [1:0] Ecout,
    output logic Lcout
);
    logic [3:0] La, Lb, lp;

    log_approx_4bit log_approx_a(.m(ma), .l(La));
    log_approx_4bit log_approx_b(.m(mb), .l(Lb));

    assign {Lcout, lp} = {1'b0, La} + {1'b0, Lb} + {4'b0, Lcin};

    assign {Ecout, Ep} = {2'b0, Ea} + {2'b0, Eb} + {3'b0, Ecin} + Ebias;

    anti_log_approx_4bit anti_log_approx(.s(lp), .p(mp));
endmodule

// Module supports 1 24' cfloat, 1 16' bfloat, 1 16' float, or 3 8' cfloat operation(s) per input
module proposed_lm_conf_16(
    input [23:0] a, b,  // Two input number(s)s
    input [1:0] mode,   // Determines the mode of operation (8' float 00, 16' float 01, 16b' float 10, 24' float, 11)
    output [23:0] p     // One output number(s)
);

    // Un-packed inputs
    logic [3:0] ma [2:0]; 
    logic [3:0] mb [2:0];    // Input mantissa (no leading 1)
    logic       Lcin [2:0];
    logic [2:0] Ea [2:0]; 
    logic [2:0] Eb [2:0];
    logic [1:0] Ecin [2:0];
    logic [4:0] Ebias [2:0];

    // Un-packed outputs
    logic [3:0] mp [2:0];      //
    logic       Lcout [2:0];
    logic [2:0] Ep [2:0];
    logic [1:0] Ecout [2:0];
    

    // Mantissa Inputs
    assign ma[2] = mode[1] ? (mode[0] ? a[13:10] : a[14:11]) : (mode[0] ? a[17:14] : a[19:16]);
    assign ma[1] = mode[1] ? (mode[0] ? a[9:6] : {a[10:8], 1'b0}) : (mode[0] ? a[13:10] : a[11:8]);
    assign ma[0] = mode[1] ? (mode[0] ? a[5:2] : 4'b0) : (mode[0] ? {a[9:8], 2'b0} : a[3:0]);

    assign mb[2] = mode[1] ? (mode[0] ? b[13:10] : b[14:11]) : (mode[0] ? b[17:14] : b[19:16]);
    assign mb[1] = mode[1] ? (mode[0] ? b[9:6] : {b[10:8], 1'b0}) : (mode[0] ? b[13:10] : b[11:8]);
    assign mb[0] = mode[1] ? (mode[0] ? b[5:2] : 4'b0) : (mode[0] ? {b[9:8], 2'b0} : b[3:0]);

    // Mantissa Carry Inputs
    assign Lcin[2] = mode[1] ? Lcout[1] : (mode[0] ? Lcout[1] : 1'b0);
    assign Lcin[1] = mode[0] ? Lcout[0] : 1'b0;
    assign Lcin[0] = 1'b0;

    // Exponent Inputs
    assign Ea[2] = a[22:20];
    assign Ea[1] = mode[1] ? a[19:17] : (mode[0] ? {a[19:18], 1'b0}: a[14:12]);
    assign Ea[0] = mode[1] ? (mode[0] ? a[16:14] : {a[16:15], 1'b0}) : (mode[0] ? 3'b0 : a[6:4]);

    assign Eb[2] = b[22:20];
    assign Eb[1] = mode[1] ? b[19:17] : (mode[0] ? {b[19:18], 1'b0}: b[14:12]);
    assign Eb[0] = mode[1] ? (mode[0] ? b[16:14] : {b[16:15], 1'b0}) : (mode[0] ? 3'b0 : b[6:4]);

    // Exponent Carry Inputs    
    assign Ecin[2] = mode[1] ? Ecout[1] : (mode[0] ? Ecout[1] : 2'b0);
    assign Ecin[1] = mode[1] ? Ecout[0] : (mode[0] ? {Lcout[2], 1'b0} : 2'b0);
    assign Ecin[0] = mode[1] ? (mode[0] ? {1'b0, Lcout[2]} : {Lcout[2], 1'b0}) : 2'b0;

    // Exponent Bias Inputs (dependent on mode), already two's complemented
    assign Ebias[2] = (mode[1] | mode[0]) ? 5'b11100 : 5'b11101;
    assign Ebias[1] = mode[1] ? 5'b00000 : (mode[0] ? 5'b00010 : 5'b11101);
    assign Ebias[0] = mode[1] ? (mode[0] ? 5'b00001 : 5'b00010) : (mode[0] ? 5'b00000 : 5'b11101); 

    proposed_lm lm [2:0] (.ma, .mb, .Ea, .Eb, .Ecin, .Lcin, .Ebias, .mp, .Ep, .Ecout, .Lcout);

    assign p = mode[1] ? (mode[0] ? {(a[23] ^ b[23]), Ep[2], Ep[1], Ep[0], mp[2], mp[1], mp[0], 2'b0} : 
                            {(a[23] ^ b[23]), Ep[2], Ep[1], Ep[0][2:1], mp[2], mp[1][3:1], 8'b0}) :
                        (mode[0] ? {(a[23] ^ b[23]), Ep[2], Ep[1][2:1], mp[2], mp[1], mp[0][3:2]} :
                            {(a[23] ^ b[23]), Ep[2], Mp[2], (a[15] ^ b[15]), Ep[1], Mp[1], (a[7] ^ b[7]), Ep[0], Mp[0]});

endmodule