import numpy as np
import matplotlib.pyplot as plt

def f32_num(h): # Helper function for get_data()
    return np.frombuffer(bytes.fromhex(h), dtype='>f4')[0]

def f16_num(h): # Helper function for get_data()
    return np.frombuffer(bytes.fromhex(h), dtype='>f2')[0]

def f32_exponent(h): # Helper fucntion for get_data()
    bits = int(h, 16)
    exponent_unadjusted = (bits >> 23) & 0xFF   # 8 bits
    return exponent_unadjusted - 127

def f16_exponent(h): # Helper fucntion for get_data()
    bits = int(h, 16)
    exponent_unadjusted = (bits >> 10) & 0x1F   # 8 bits
    return exponent_unadjusted - 15

def get_data(file_path): # Reads the output file and grabs the data from it.

    data_list = []

    with open(file_path) as f:
        for line in f:
            line = line.split("//")[0].strip()
            if not line:
                continue

            h1, h2, h3, h4 = line.split("_")

            e1 = f32_exponent(h1.strip())
            e2 = f16_exponent(h2.strip())

            v1 = (f32_num(h1.strip()) / np.power(2.0, e1)).astype(np.float32)
            v2 = (f16_num(h2.strip()) / np.power(2.0, e2)).astype(np.float32)
            v3 = (f32_num(h3.strip()) / np.power(2.0, e1)).astype(np.float32)
            v4 = (f32_num(h4.strip()) / np.power(2.0, e1)).astype(np.float32)

            data_list.append([v1, v2, v3, v4])

    data = np.array(data_list, dtype=np.float32)

    return data

if __name__ == "__main__":

    unsorted_data = get_data("sim_results.out")
    sorted_data = unsorted_data[unsorted_data[:, 0].argsort()]

    sorted_data_no_zeros = sorted_data[sorted_data[:, 0] != 0]

    sorted_error_FPLM32 = (sorted_data_no_zeros[:, 0] - sorted_data_no_zeros[:, 2]) / sorted_data_no_zeros[:, 0]
    sorted_error_CONF32 = (sorted_data_no_zeros[:, 0] - sorted_data_no_zeros[:, 3]) / sorted_data_no_zeros[:, 0]

    cumsum_error_FPLM32 = (np.cumsum(sorted_error_FPLM32))[-1] * np.ones_like(sorted_error_FPLM32)
    cumsum_error_CONF32 = (np.cumsum(sorted_error_CONF32))[-1] * np.ones_like(sorted_error_CONF32)

    np.set_printoptions(floatmode='maxprec')
    print((cumsum_error_CONF32[0].astype(np.float64) - cumsum_error_FPLM32[0].astype(np.float64)) / cumsum_error_CONF32[0].astype(np.float64))

    fig1, ax1 = plt.subplots(1, 1, figsize=(8,4))
    ax1.plot(sorted_data_no_zeros[:, 0], sorted_error_FPLM32, linestyle='', marker='.' , color='tab:purple', alpha=0.002)
    ax1.plot(sorted_data_no_zeros[:, 0], cumsum_error_FPLM32 / sorted_error_FPLM32.size, lw=3, color='black', alpha=1)
    ax1.grid(True)
    min_x = sorted_data_no_zeros[:, 0].min()
    max_x = sorted_data_no_zeros[:, 0].max()
    min_y = sorted_error_FPLM32.min()
    max_y = sorted_error_FPLM32.max()
    ax1.set_xlim(min_x, max_x)
    ax1.set_ylim(min_y, max_y)
    ax1.set_xlabel("Expected Mantissa Value of Multiplier")
    ax1.set_ylabel("Simulated Mantissa Error (FP32 - FPLM32) / FP32")
    ax1.set_title("Simulated Error from 32-bit FPLM compared to Standard FP Multiplier")
    ax1.legend(("16-bit FPLM Simulated Value", "Cummulative Sum of Simmulated Error"), loc="lower left")


    # fig2, ax2 = plt.subplots(1, 1, figsize=(8,4))
    # # Original
    # #ax1.plot(sorted_data[:, 0], sorted_data[:, 0], lw=3, color='black', alpha=0.5)
    # # FPLM2 Approximation
    # ax2.plot(sorted_data[:, 0], (sorted_data[:, 3] - sorted_data[:, 0]) / sorted_data[:, 0], linestyle='', marker='.' , color='tab:purple', alpha=0.002)
    # ax2.grid(True)
    # min_x = unsorted_data[:, 0].min()
    # max_x = unsorted_data[:, 0].max()
    # min_y = unsorted_data.min()
    # max_y = unsorted_data.max()
    # ax2.set_xlim(min_x, max_x)
    # ax2.set_ylim(-1.0, 1.0)
    # ax2.set_xlabel("Expected Value of Multiplier")
    # ax2.set_ylabel("Simulated Value from Multiplier")
    # ax2.set_title("Simulated Values from 16-bit FPLM compared to Expected Values")
    # ax2.legend(("Expected Value of Multiplication", "16-bit FPLM Simulated Value",))

    plt.show()

