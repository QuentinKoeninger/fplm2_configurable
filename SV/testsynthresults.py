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

    sorted_error_FPLM32 = -(sorted_data_no_zeros[:, 0] - sorted_data_no_zeros[:, 2])# / sorted_data_no_zeros[:, 0]
    #sorted_error_CONF32 = (sorted_data_no_zeros[:, 0] - sorted_data_no_zeros[:, 3])# / sorted_data_no_zeros[:, 0]

    #cumsum_error_FPLM32 = (np.cumsum(sorted_error_FPLM32))[-1] * np.ones_like(sorted_error_FPLM32)
    #cumsum_error_CONF32 = (np.cumsum(sorted_error_CONF32))[-1] * np.ones_like(sorted_error_CONF32)

    #np.set_printoptions(floatmode='maxprec')
    print(np.sum((sorted_data_no_zeros[:, 2] - sorted_data_no_zeros[:, 3]) / sorted_data_no_zeros[:, 2]) / sorted_data_no_zeros[:, 2].size)

    num_bins = 150

    data_size = sorted_error_FPLM32.size

    bin_size = int(data_size / num_bins)

    average_error = []
    avg_err_pt = []

    for n in range(num_bins):
        N = (n + 1) * bin_size
        if N > data_size:
            N = data_size
        num_el = N - n * bin_size
        average_error.append(np.sum(sorted_error_FPLM32[(n * bin_size):(N - 1)]) / num_el)
        avg_err_pt.append(np.sum(sorted_data_no_zeros[(n * bin_size):(N - 1), 0]) / num_el)

    average_error = np.array(average_error)
    avg_err_pt = np.array(avg_err_pt)

    #print(average_error)
    #print(avg_err_pt)

    fig1, ax1 = plt.subplots(1, 1, figsize=(3.5, 2.5))
    ax1.plot(sorted_data_no_zeros[:, 0], sorted_error_FPLM32, #label="Simulated Mantissa Error", 
             linestyle='', marker=',', markersize=1, fillstyle="full", color='tab:purple', alpha=0.1)
    #ax1.plot(sorted_data_no_zeros[:, 0], cumsum_error_FPLM32 / sorted_error_FPLM32.size, label="Average Mantissa Error", 
    #         lw=3, color='black', alpha=1)
    ax1.plot(avg_err_pt, average_error, label="Average Mantissa Error", 
             lw=1, color='black', alpha=1)
    ax1.grid(True)
    min_x = sorted_data_no_zeros[:, 0].min()
    max_x = sorted_data_no_zeros[:, 0].max()
    min_y = sorted_error_FPLM32.min()
    max_y = sorted_error_FPLM32.max()
    y_buff = 0.05 * (max_y - min_y)
    ax1.set_xlim(min_x, max_x)
    ax1.set_ylim(min_y-y_buff, max_y+y_buff)
    ax1.set_xlabel(r"$M_{FP32}$", fontsize=9)
    ax1.set_ylabel(r"$M_{FPLM32}-M_{FP32}$", fontsize=9)
    ax1.legend(
        fontsize=7,            # 7-8 pt font size
        frameon=True,          # Keep frame enabled
        framealpha=0.8,        # Slight transparency to avoid obscuring data behind it
        edgecolor='gray',      # Subtle border line
        handlelength=1.5,      # Keep line sample length compact (default is 2.0)
        labelspacing=0.3,      # Compact vertical spacing between labels
        loc='lower center'             # Automatically select best low-density area
    )
    ax1.tick_params(labelsize=8)
    fig1.savefig("./output_figures/error_fplm_conf.eps", format="eps", dpi=300, bbox_inches="tight")
    fig1.savefig("./output_figures/error_fplm_conf.png", format="png", dpi=600, bbox_inches="tight")
    plt.close(fig1)

    sorted_error_FPLM32 = sorted_error_FPLM32 / sorted_data_no_zeros[:, 0]
    average_error = average_error / avg_err_pt

    fig1, ax1 = plt.subplots(1, 1, figsize=(3.5, 2.5))
    ax1.plot(sorted_data_no_zeros[:, 0], sorted_error_FPLM32, #label="Simulated Mantissa Error", 
             linestyle='', marker=',', markersize=1, fillstyle="full", color='tab:purple', alpha=0.1)
    #ax1.plot(sorted_data_no_zeros[:, 0], cumsum_error_FPLM32 / sorted_error_FPLM32.size, label="Average Mantissa Error", 
    #         lw=3, color='black', alpha=1)
    ax1.plot(avg_err_pt, average_error, label="Average Mantissa Error", 
             lw=1, color='black', alpha=1)
    ax1.grid(True)
    min_x = sorted_data_no_zeros[:, 0].min()
    max_x = sorted_data_no_zeros[:, 0].max()
    min_y = sorted_error_FPLM32.min()
    max_y = sorted_error_FPLM32.max()
    y_buff = 0.05 * (max_y - min_y)
    ax1.set_xlim(min_x, max_x)
    ax1.set_ylim(min_y-y_buff, max_y+y_buff)
    ax1.set_xlabel(r"$M_{FP32}$", fontsize=9)
    ax1.set_ylabel(r"$(M_{FPLM32}-M_{FP32})/M_{FP32}$", fontsize=9)
    ax1.legend(
        fontsize=7,            # 7-8 pt font size
        frameon=True,          # Keep frame enabled
        framealpha=0.8,        # Slight transparency to avoid obscuring data behind it
        edgecolor='gray',      # Subtle border line
        handlelength=1.5,      # Keep line sample length compact (default is 2.0)
        labelspacing=0.3,      # Compact vertical spacing between labels
        loc='lower center'             # Automatically select best low-density area
    )
    ax1.tick_params(labelsize=8)
    fig1.savefig("./output_figures/error_fplm_conf_ratio.eps", format="eps", dpi=300, bbox_inches="tight")
    fig1.savefig("./output_figures/error_fplm_conf_ratio.png", format="png", dpi=600, bbox_inches="tight")
    plt.close(fig1)


