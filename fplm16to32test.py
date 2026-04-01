import torch

# -----------------------------
# FPLM-2: Approximate floating-point multiplication (Method-2) 32
# -----------------------------
def approx_mul_fplm2_32(a: torch.Tensor, b: torch.Tensor) -> torch.Tensor:
    sign = torch.sign(a) * torch.sign(b)
    aa = a.abs().clamp_min(torch.finfo(torch.float32).tiny)
    bb = b.abs().clamp_min(torch.finfo(torch.float32).tiny)
    m_a, e_a = torch.frexp(aa)
    m_b, e_b = torch.frexp(bb)

    M_a = 2.0 * m_a
    M_b = 2.0 * m_b
    x_a = M_a - 1.0
    x_b = M_b - 1.0

    bXa = torch.where(x_a < 0.5, x_a, 0.5 * (1.0 + x_a))
    bXb = torch.where(x_b < 0.5, x_b, 0.5 * (1.0 + x_b))

    s = bXa + bXb
    carry = (s >= 1.0).to(e_a.dtype)
    e_p = (e_a + e_b - 2).to(torch.int32) + carry.to(torch.int32)

    Xp = torch.where(s < 1.0, 1.0 + s,
             torch.where(s < 1.5, s,
             torch.where(s < 1.75, s - 0.25,
                         s - 0.125)))

    return sign * torch.ldexp(Xp, e_p)

# -----------------------------
# FPLM-2: Approximate floating-point multiplication (Method-2) 32-bit configurable
# -----------------------------
def approx_mul_fplm2_32_conf(a: torch.Tensor, b: torch.Tensor) -> torch.Tensor:
    sign = torch.sign(a) * torch.sign(b)
    aa = a.abs().clamp_min(torch.finfo(torch.float32).tiny)
    bb = b.abs().clamp_min(torch.finfo(torch.float32).tiny)
    m_a, e_a = torch.frexp(aa)
    m_b, e_b = torch.frexp(bb)

    M_a = 2.0 * m_a
    M_b = 2.0 * m_b
    x_a = M_a - 1.0
    x_b = M_b - 1.0

    # Start Calculate log on separate pieces
    bXa2 = torch.where(x_a < 0.5, x_a, m_a) % (2.0**(-20))
    bXb2 = torch.where(x_b < 0.5, x_b, m_b) % (2.0**(-20))
    
    bXa1 = torch.where(x_a < 0.5, x_a, m_a) % (2.0**(-10)) - bXa2
    bXb1 = torch.where(x_b < 0.5, x_b, m_b) % (2.0**(-10)) - bXb2

    bXa0 = torch.where(x_a < 0.5, x_a, m_a) - bXa1 - bXa2
    bXb0 = torch.where(x_b < 0.5, x_b, m_b) - bXb1 - bXb2
    # End Calculate log
    
    # Start sum pieces
    s2i = bXa2 + bXb2
    s2 = torch.where(s2i > (2.0**(-20)), s2i - (2.0**(-20)), s2i)
    s1i = bXa1 + bXb1 + torch.where(s2i > (2.0**(-20)),  (2.0**(-20)), 0.0)
    s1 = torch.where(s1i > (2.0**(-10)), s1i - (2.0**(-10)), s1i)
    s0i = bXa0 + bXb0 + torch.where(s1i > (2.0**(-10)), (2.0**(-10)), 0.0)
    # End sum pieces

    # Start Calc separate exponents
    ea = e_a - 1
    eb = e_b - 1

    ea2 = ea % (2**(5))
    eb2 = eb % (2**(5))

    ea1 = ea - ea2
    eb1 = eb - eb2
    # End Calc separate Exponents

    # Start sum exponents separate
    carry = (s0i >= 1.0).to(e_a.dtype)

    ep2i = (ea2 + eb2).to(torch.int32) + carry.to(torch.int32)
    ep2 = torch.where(ep2i > (2**(5)), ep2i - (2**(5)), ep2i)
    ep1 = (ea1 + eb1).to(torch.int32) + torch.where(ep2i > (2**(5)), (2**(5)), 0).to(torch.int32)
    # End sum exponents separate

    # Start Compute Anti-log (only done on most significant bits)
    s0 = torch.where(s0i < 1.0, 1.0 + s0i,
             torch.where(s0i < 1.5, s0i,
             torch.where(s0i < 1.75, s0i - 0.25,
                         s0i - 0.125)))
    # End Compute Anti-log
    
    # Add pieces back together
    Xp = s0 + s1 + s2
    e_p = ep1 + ep2

    return sign * torch.ldexp(Xp, e_p)

if __name__ == "__main__":
    a = torch.normal(mean=0.0, std=150.0, size=(1000,1), dtype=torch.float32)
    b = torch.normal(mean=0.0, std=150.0, size=(1000,1), dtype=torch.float32)

    print("\nGetting Results...")
    fplm2_result_32_conf = approx_mul_fplm2_32_conf(a, b)
    fplm2_result_32 = approx_mul_fplm2_32(a, b)
    comp_res = torch.eq(fplm2_result_32_conf, fplm2_result_32)

#    print(fplm2_result_32)
#    print(fplm2_result_32_conf)
#    print(comp)

    err_sum = 0
    for x in comp_res:
        if not x:
            err_sum += 1
    
    print("Number of errors = " + str(err_sum))


#    print("Generating .tv file...")
#    generate_vector_file(a, b, fplm2_result)
    
    print("Done!\n")

