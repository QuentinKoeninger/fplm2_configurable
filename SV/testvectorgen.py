import torch

def generate_vector_file(A16, B16, A32, B32):
    a = A16.to(torch.float16).view(torch.uint16)
    b = B16.to(torch.float16).view(torch.uint16)
    c = A32.to(torch.float32).view(torch.uint32)
    d = B32.to(torch.float32).view(torch.uint32)
    e = (A32 * B32).to(torch.float32).view(torch.uint32)

    a_d = A16.to(torch.float16)
    b_d = B16.to(torch.float16)
    e_d = (A32 * B32).to(torch.float32)


    with open("./fplm2_testvectors.tv", "w", encoding="utf-8") as file:

        for w1, w2, w3, w4, w5, w6, w7, w8 in zip(a, b, c, d, a_d, b_d, e, e_d):
            file.write(f"{w1.item():04x}_{w2.item():04x}_{w3.item():08x}_{w4.item():08x}_{w7.item():08x}\t\t// {w5.item():<8} * {w6.item():<8} = {w8.item():}\n")

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

if __name__ == "__main__":
    base = torch.linspace(start=0.0, end=2.0, steps=1003)
    A = torch.tile(input=base, dims=(1003,))
    B = torch.sort(input=A)

    #print(A)
    #print(B)

    a16=A.to(dtype=torch.float16)
    b16=B.values.to(dtype=torch.float16)
    a32=A.to(dtype=torch.float32)
    b32=B.values.to(dtype=torch.float32)

    #print("\nGetting Results...")
    #fplm2_result = approx_mul_fplm2(a, b, 1)

    print("Generating .tv file...")
    generate_vector_file(a16, b16, a32, b32)

    print("Done!\n")

