import numpy as np
import struct
import random
 
# -----------------------------------------------------------------------
# IEEE 754 Half-Precision (16-bit) helpers
#   format: 1 sign | 5 exponent (bias=15) | 10 mantissa
# -----------------------------------------------------------------------
 
def float_to_fp16_bits(f):
    """Return raw 16-bit integer representation of a Python float as fp16."""
    arr = np.array([f], dtype=np.float16)
    return int(np.frombuffer(arr.tobytes(), dtype=np.uint16)[0])
 
def fp16_bits_to_float(bits):
    """Convert raw 16-bit integer back to Python float via fp16."""
    arr = np.frombuffer(np.array([bits], dtype=np.uint16).tobytes(), dtype=np.float16)
    return float(arr[0])
 
def unpack_fp16(bits):
    """Return (sign, exp5, mant10) from a 16-bit fp16 word."""
    s = (bits >> 15) & 0x1
    e = (bits >> 10) & 0x1F
    m = bits & 0x3FF
    return s, e, m
 
def pack_fp16(s, e, m):
    return ((s & 1) << 15) | ((e & 0x1F) << 10) | (m & 0x3FF)
 
# -----------------------------------------------------------------------
# FPLM-2 algorithm in Python — mirrors the SystemVerilog exactly
# -----------------------------------------------------------------------
BIAS = 15
Q    = 10
 
def fp_le(m):
    """FP-LE: eq.(16)
       M[q-1]=1 → {1'b1, m[q-1:1]}  (shift right, discard LSB)
       M[q-1]=0 → m                  (wire-through)
    """
    if (m >> (Q-1)) & 1:
        return (1 << (Q-1)) | (m >> 1)
    else:
        return m
 
def antilog_adjust(cout, mp):
    """Anti-log MUX chain: eq.(19)
       {cout, mp[Q-1], mp[Q-2]} selects region
    """
    b2 = (mp >> (Q-1)) & 1   # mp[9]
    b1 = (mp >> (Q-2)) & 1   # mp[8]
    b0 = (mp >> (Q-3)) & 1   # mp[7]
    sel = (cout << 2) | (b2 << 1) | b1
 
    if sel in (0b000, 0b001, 0b010, 0b011, 0b100):
        return mp
    elif sel == 0b110:
        low = mp & ((1 << (Q-2)) - 1)
        return (0b01 << (Q-2)) | low
    elif sel == 0b111:
        low = mp & ((1 << (Q-3)) - 1)
        if b0:
            return (0b110 << (Q-3)) | low
        else:
            return (0b101 << (Q-3)) | low
    else:
        return mp
 
def fplm2(a_bits, b_bits):
    """Full FPLM-2 multiplier — matches the SV module exactly."""
    sa, ea, ma = unpack_fp16(a_bits)
    sb, eb, mb = unpack_fp16(b_bits)
 
    sp     = sa ^ sb
    pzero  = (a_bits & 0x7FFF) == 0 or (b_bits & 0x7FFF) == 0
    a_nan  = (ea == 0x1F)
    b_nan  = (eb == 0x1F)
 
    map_   = fp_le(ma)
    mbp    = fp_le(mb)
 
    adder  = map_ + mbp
    cout   = (adder >> Q) & 1
    mp     =  adder & ((1 << Q) - 1)
 
    mp_final = antilog_adjust(cout, mp)
 
    ep_raw = ea + eb - BIAS + cout
    ep_ovf = (ep_raw == 0x1F)
    ep_udf = (ep_raw < 0)
    ep     = ep_raw & 0x1F
 
    if pzero:
        return pack_fp16(sp, 0, 0)
    elif a_nan:
        return (sp << 15) | (a_bits & 0x7FFF)
    elif b_nan:
        return (sp << 15) | (b_bits & 0x7FFF)
    elif ep_ovf:
        return pack_fp16(sp, 0x1F, 0)
    elif ep_udf:
        return pack_fp16(sp, 0, 0)
    else:
        return pack_fp16(sp, ep, mp_final)
 
# -----------------------------------------------------------------------
# Generate 10 test vectors
# -----------------------------------------------------------------------
random.seed(42)
 
vectors = []
for _ in range(10):
    a_f    = random.uniform(-30, 30)
    b_f    = random.uniform(-30, 30)
    a_bits = float_to_fp16_bits(a_f)
    b_bits = float_to_fp16_bits(b_f)
    r_bits = fplm2(a_bits, b_bits)       # FPLM-2 approximate result
    a_f16  = fp16_bits_to_float(a_bits)
    b_f16  = fp16_bits_to_float(b_bits)
    r_f16  = fp16_bits_to_float(r_bits)
    vectors.append((a_bits, b_bits, r_bits, a_f16, b_f16, r_f16))
 
# -----------------------------------------------------------------------
# Write .tv file
# $readmemh expects each entry as one continuous hex token (no underscores)
# Each entry = 48 bits = 12 hex digits: AAAABBBBCCCC
# where AAAA=A(16b), BBBB=B(16b), CCCC=expected(16b)
# -----------------------------------------------------------------------
with open("testvector16_test4_1.tv", "w") as f:
    for a, b, r, av, bv, rv in vectors:
        token = (a << 32) | (b << 16) | r      # pack into 48-bit value
        f.write(f"{token:012x}    // {av} * {bv} = {rv}\n")
 
print("Generated 10 half-precision FPLM-2 test vectors.")
for a, b, r, av, bv, rv in vectors:
    print(f"  {a:04x} * {b:04x} = {r:04x}   ({av:.4f} * {bv:.4f} ≈ {rv:.4f})")
 