import torch

def generate_vector_file(mul1, mul2, prod):
    a = mul1.to(torch.float16).view(torch.uint16)
    b = mul2.to(torch.float16).view(torch.uint16)
    c = prod.to(torch.float16).view(torch.uint16)

    a1 = mul1.to(torch.float16)
    b1 = mul2.to(torch.float16)
    c1 = prod.to(torch.float16) 


    with open("C:/Users/qkoen/Desktop/GitHub/fplm2_configurable/SV/fplm2_testvectors.tv", "w", encoding="utf-8") as file:

        for w1, w2, w3, w4, w5, w6 in zip(a, b, c, a1, b1, c1):
            file.write(f"{w1.item():4x}_{w2.item():4x}_{w3.item():4x}\t\t// {w4.item():<8} * {w5.item():<8} = {w6.item():<8}\n")

        file.close()



# -----------------------------
# FPLM-2: Approximate floating-point multiplication (Method-2)
# -----------------------------
def approx_mul_fplm2(a: torch.Tensor, b: torch.Tensor, z) -> torch.Tensor:
    sign = torch.sign(a) * torch.sign(b)
    aa = a.abs().clamp_min(torch.finfo(torch.float32).tiny)
    bb = b.abs().clamp_min(torch.finfo(torch.float32).tiny)
    m_a, e_a = torch.frexp(aa)
    m_b, e_b = torch.frexp(bb)

    M_a = 2.0 * m_a
    M_b = 2.0 * m_b
    x_a = M_a - 1.0
    x_b = M_b - 1.0

    bXa = torch.where(x_a < 0.5, x_a, 0.5 * (1.0 + x_a) - z * torch.fmod(x_a, 2**(-9)))
    bXb = torch.where(x_b < 0.5, x_b, 0.5 * (1.0 + x_b) - z * torch.fmod(x_b, 2**(-9)))

    s = bXa + bXb
    carry = (s >= 1.0).to(e_a.dtype)
    e_p = (e_a + e_b - 2).to(torch.int32) + carry.to(torch.int32)

    Xp = torch.where(s < 1.0, 1.0 + s,
             torch.where(s < 1.5, s,
             torch.where(s < 1.75, s - 0.25,
                         s - 0.125)))

    return sign * torch.ldexp(Xp, e_p)

if __name__ == "__main__":
    a = torch.normal(mean=0.0, std=150.0, size=(1003,1))
    b = torch.normal(mean=0.0, std=150.0, size=(1003,1))

    a=a.to(dtype=torch.float16)
    b=b.to(dtype=torch.float16)

    print("\nGetting Results...")
    fplm2_result = approx_mul_fplm2(a, b, 1)

    print("Generating .tv file...")
    generate_vector_file(a, b, fplm2_result)

    print("Done!\n")

