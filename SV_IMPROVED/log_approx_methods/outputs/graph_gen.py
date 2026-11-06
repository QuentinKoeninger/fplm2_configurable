import numpy as np
import matplotlib.pyplot as plt

def convert_to_num(b): # Helper function for get_data()
    num = 0.0
    for i, bi in enumerate(b):
        if (bi == '1'):
            num = num + 2.0 ** (-1 - i)
    return num

def get_data(file_path): # Reads the output file and grabs the data from it.

    data_list = []

    with open(file_path) as f:
        for line in f:
            line = line.strip()

            b_in, b_out = line.split("_")
            num_in = (convert_to_num(b_in))
            num_out = (convert_to_num(b_out))

            data_list.append([num_in, num_out])

    data = np.array(data_list, dtype=np.float32)

    return data

def fplm_log_approx(input):
    return np.where(input < 0.5, input, (input + 1.0) / 2)

if __name__ == "__main__":

    data4 = get_data("log_approx_4bit.out")

    data12 = get_data("log_approx_12bit.out")

    fig1, ax1 = plt.subplots(1, 1, figsize=(3.5, 2.5))
    ax1.plot(data4[:, 0], fplm_log_approx(data4[:, 0]), label="FPLM2 Log", 
             linestyle='', marker='o', markersize=1, fillstyle="full", color='tab:blue')
    ax1.plot(data4[:, 0], data4[:, 1], label="Approximated Log", 
             linestyle='', marker='o', markersize=1, fillstyle="full", color='tab:purple')
    ax1.plot(data4[:, 0], np.log2(1+data4[:, 0]), label="Actual Log", 
             lw=1, color='black')
    ax1.grid(True)
    min_x = -0.1
    max_x = 1.1
    min_y = -0.1
    max_y = 1.1
    ax1.set_xlim(min_x, max_x)
    ax1.set_ylim(min_y, max_y)
    ax1.set_xlabel(r"m", fontsize=9)
    ax1.set_ylabel(r"log2(m+1)", fontsize=9)
    ax1.legend(
        fontsize=7,            # 7-8 pt font size
        frameon=True,          # Keep frame enabled
        framealpha=0.8,        # Slight transparency to avoid obscuring data behind it
        edgecolor='gray',      # Subtle border line
        handlelength=1.5,      # Keep line sample length compact (default is 2.0)
        labelspacing=0.3,      # Compact vertical spacing between labels
        loc='lower right'             # Automatically select best low-density area
    )
    ax1.tick_params(labelsize=8)
    fig1.savefig("./log_approx_4bit.png", format="png", dpi=600, bbox_inches="tight")
    plt.close(fig1)

    fig2, ax2 = plt.subplots(1, 1, figsize=(3.5, 2.5))
    ax2.plot(data12[:, 0], fplm_log_approx(data12[:, 0]), label="FPLM2 Log", 
                 linestyle='', marker='o', markersize=0.2, fillstyle="full", color='tab:blue')
    ax2.plot(data12[:, 0], data12[:, 1], label="Approximated Log", 
             linestyle='', marker='o', markersize=0.2, fillstyle="full", color='tab:purple')
    ax2.plot(data12[:, 0], np.log2(1+data12[:, 0]), label="Actual Log", 
             lw=1, color='black')
    ax2.grid(True)
    min_x = -0.1
    max_x = 1.1
    min_y = -0.1
    max_y = 1.1
    ax2.set_xlim(min_x, max_x)
    ax2.set_ylim(min_y, max_y)
    ax2.set_xlabel(r"m", fontsize=9)
    ax2.set_ylabel(r"log2(m+1)", fontsize=9)
    ax2.legend(
        fontsize=7,            # 7-8 pt font size
        frameon=True,          # Keep frame enabled
        framealpha=0.8,        # Slight transparency to avoid obscuring data behind it
        edgecolor='gray',      # Subtle border line
        handlelength=1.5,      # Keep line sample length compact (default is 2.0)
        labelspacing=0.3,      # Compact vertical spacing between labels
        loc='lower right'             # Automatically select best low-density area
    )
    ax2.tick_params(labelsize=8)
    fig2.savefig("./log_approx_12bit.png", format="png", dpi=600, bbox_inches="tight")
    plt.close(fig2)

    print("Average Error 4-bit FPLM2 (net then total)")
    print(np.mean(fplm_log_approx(data4[:, 0]) - np.log2(1+data4[:, 0])))
    print(np.mean(np.abs(fplm_log_approx(data4[:, 0]) - np.log2(1+data4[:, 0]))))
    print("Average Error 4-bit New Method (net then total)")
    print(np.mean(data4[:, 1] - np.log2(1+data4[:, 0])))
    print(np.mean(np.abs(data4[:, 1] - np.log2(1+data4[:, 0]))))

    fig3, ax3 = plt.subplots(1, 1, figsize=(3.5, 2.5))
    ax3.plot(data4[:, 0], fplm_log_approx(data4[:, 0]) - np.log2(1+data4[:, 0]), label="FPLM2 Log", 
             linestyle='', marker='o', markersize=1, fillstyle="full", color='tab:blue')
    ax3.plot(data4[:, 0], data4[:, 1] - np.log2(1+data4[:, 0]), label="Approximated Log", 
             linestyle='', marker='o', markersize=1, fillstyle="full", color='tab:purple')
    ax3.grid(True)
    min_x = -0.1
    max_x = 1.1
    min_y = -0.1
    max_y = 0.3
    ax3.set_xlim(min_x, max_x)
    ax3.set_ylim(min_y, max_y)
    ax3.set_xlabel(r"$m$", fontsize=9)
    ax3.set_ylabel(r"$approxlog2(m+1) - log2(m+1)$", fontsize=9)
    ax3.legend(
        fontsize=7,            # 7-8 pt font size
        frameon=True,          # Keep frame enabled
        framealpha=0.8,        # Slight transparency to avoid obscuring data behind it
        edgecolor='gray',      # Subtle border line
        handlelength=1.5,      # Keep line sample length compact (default is 2.0)
        labelspacing=0.3,      # Compact vertical spacing between labels
        loc='upper center'             # Automatically select best low-density area
    )
    ax3.tick_params(labelsize=8)
    fig3.savefig("./error_log_approx_4bit.png", format="png", dpi=600, bbox_inches="tight")
    plt.close(fig3)

    print("Average Error 4-bit FPLM2 (net then total)")
    print(np.mean(fplm_log_approx(data12[:, 0]) - np.log2(1+data12[:, 0])))
    print(np.mean(np.abs(fplm_log_approx(data12[:, 0]) - np.log2(1+data12[:, 0]))))
    print("Average Error 4-bit New Method (net then total)")
    print(np.mean(data12[:, 1] - np.log2(1+data12[:, 0])))
    print(np.mean(np.abs(data12[:, 1] - np.log2(1+data12[:, 0]))))

    fig4, ax4 = plt.subplots(1, 1, figsize=(3.5, 2.5))
    ax4.plot(data12[:, 0], fplm_log_approx(data12[:, 0]) - np.log2(1+data12[:, 0]), label="FPLM2 Log", 
                 linestyle='', marker='o', markersize=0.2, fillstyle="full", color='tab:blue')
    ax4.plot(data12[:, 0], data12[:, 1] - np.log2(1+data12[:, 0]), label="Approximated Log", 
             linestyle='', marker='o', markersize=0.2, fillstyle="full", color='tab:purple')
    ax4.grid(True)
    min_x = -0.1
    max_x = 1.1
    min_y = -0.1
    max_y = 0.3
    ax4.set_xlim(min_x, max_x)
    ax4.set_ylim(min_y, max_y)
    ax4.set_xlabel(r"$m$", fontsize=9)
    ax4.set_ylabel(r"$approx_log2(m+1) - log2(m+1)$", fontsize=9)
    ax4.legend(
        fontsize=7,            # 7-8 pt font size
        frameon=True,          # Keep frame enabled
        framealpha=0.8,        # Slight transparency to avoid obscuring data behind it
        edgecolor='gray',      # Subtle border line
        handlelength=1.5,      # Keep line sample length compact (default is 2.0)
        labelspacing=0.3,      # Compact vertical spacing between labels
        loc='upper center'             # Automatically select best low-density area
    )
    ax4.tick_params(labelsize=8)
    fig4.savefig("./error_log_approx_12bit.png", format="png", dpi=600, bbox_inches="tight")
    plt.close(fig4)


