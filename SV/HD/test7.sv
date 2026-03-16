module fp_mult(
    input logic [15:0] A, B,
    output logic [15:0] P   
);

localparam int q = 10;
localparam logic [4:0] bias = 5'd15;

logic [q-1:0] Ma, Mb, Mp, Map, Mbp, Mp_final;
logic [4:0] Ea, Eb, Ep;
logic Sa, Sb, Sp;
logic Pzero;
logic A_nan, B_nan;
logic Cout;
logic [5:0] Ep_raw;
logic Ep_ovf, Ep_udf;

assign Ma = A[q-1:0];
assign Mb = B[q-1:0];
assign Ea = A[14:10];
assign Eb = B[14:10];
assign Sa = A[15];
assign Sb = B[15];


assign Map = Ma[q-1] ? {1'b1, Ma[q-1:1]} : Ma; //FPLE (eq.16)
assign Mbp = Mb[q-1] ? {1'b1, Mb[q-1:1]} : Mb;
assign {Cout, Mp} = Map + Mbp; // adder

//antilog approx (eq.19)
always_comb begin
    casez({Cout, Mp[q-1], Mp[q-2]})
        3'b0??,
        3'b10? : Mp_final = Mp;
        3'b110  : Mp_final = {2'b01, Mp[q-3:0]};
        3'b111  : Mp_final = Mp[q-3] ? {3'b110, Mp[q-4:0]}
                                          : {3'b101, Mp[q-4:0]};
        default : Mp_final = Mp;

    endcase
end

//exponent eq.18
assign Ep_raw = {1'b0, Ea} + {1'b0, Eb} - {1'b0, bias} + {5'b0, Cout};
assign Ep_ovf = (~Ep_raw[5]) & (&Ep_raw[4:0]);
assign Ep_udf =   Ep_raw[5];
assign Ep     =   Ep_raw[4:0];


assign Pzero = (~|A[14:0]) | (~|B[14:0]);
assign A_nan = &Ea;
assign B_nan = &Eb;

assign Sp = Sa ^ Sb; //eq.5

always_comb begin
        if      (Pzero)  P = {Sp, 15'b0};
        else if (A_nan)  P = {Sp, A[14:0]};
        else if (B_nan)  P = {Sp, B[14:0]};
        else if (Ep_ovf) P = {Sp, 5'b11111, 10'b0};
        else if (Ep_udf) P = {Sp, 15'b0};
        else             P = {Sp, Ep, Mp_final};
    end

endmodule