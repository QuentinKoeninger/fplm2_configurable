import numpy as np
import matplotlib.pyplot as plt

def get_mantissa(m): # Helper function for get_data()
    num = 1.0
    for i, bi in enumerate(m):
        if (bi == '1'):
            num = num + 2.0 ** (-1 - i)
    return num

def get_exponent(e): # Helper function for get_data()
    num_bits = len(e)
    exp = 1 - (2 ** (num_bits - 1))
    for i, bi in enumerate(e):
        if (bi == '1'):
            exp = exp + 2 ** (num_bits - 1 - i)
    return 2 ** exp

def get_data(file_path, e_ind, m_ind): # Reads the output file and grabs the data from it.

    data_list = []

    with open(file_path) as f:
        for line in f:
            line = line.strip()

            a_in, b_in, p_out, f_out = line.split("_")
            #print(a_in[0:2] + "_" + a_in[2:6])
            a_in = get_mantissa(a_in[e_ind:m_ind]) * get_exponent(a_in[0:e_ind])
            b_in = get_mantissa(b_in[e_ind:m_ind]) * get_exponent(b_in[0:e_ind])
            a_out = a_in * b_in
            p_out = get_mantissa(p_out[e_ind:m_ind]) * get_exponent(p_out[0:e_ind])
            f_out = get_mantissa(f_out[e_ind:m_ind]) * get_exponent(f_out[0:e_ind])

            if a_out >= 2.0:
                a_out = a_out / 2
                p_out = p_out / 2
                f_out = f_out / 2

            data_list.append([a_out, p_out, f_out])

    data = np.array(data_list, dtype=np.float32)

    return data

if __name__ == "__main__":

    data4 = get_data("mult_comparison_7bit.out", 2, 6)
    data8 = get_data("mult_comparison_13bit.out", 4, 12)

    #print(data4)

    fig1, ax1 = plt.subplots(1, 1, figsize=(3.5, 2.5))
    ax1.plot(data4[:,0], data4[:,0], label="Actual Mult", 
             lw=1, color='black')
    ax1.plot(data4[:,0], data4[:, 2]+0.01, label="FPLM2 Mult", alpha=0.2,
             linestyle='', marker='o', markersize=1, fillstyle="full", color='tab:blue')
    ax1.plot(data4[:,0], data4[:, 1], label="Approximated Mult", alpha=0.2,
             linestyle='', marker='o', markersize=1, fillstyle="full", color='tab:purple')
    
    ax1.grid(True)
    min_x = 0.9
    max_x = 2.1
    min_y = 0.9
    max_y = 2.2
    ax1.set_xlim(min_x, max_x)
    ax1.set_ylim(min_y, max_y)
    ax1.set_xlabel(r"a*b", fontsize=9)
    ax1.set_ylabel(r"approx(a*b)", fontsize=9)
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
    fig1.savefig("./mult_4bit.png", format="png", dpi=600, bbox_inches="tight")
    plt.close(fig1)

    err1 = (data4[:, 1] - data4[:, 0]) / data4[:, 0]
    err2 = (data4[:, 2] - data4[:, 0]) / data4[:, 0]
    print(np.mean(np.abs(err1)))
    print(np.mean(np.abs(err2)))
    print(np.mean(err1))
    print(np.mean(err2))

    fig1, ax1 = plt.subplots(1, 1, figsize=(3.5, 2.5))
    #ax1.plot(data4[:,0], np.mean(np.abs(err1))*np.ones_like(data4[:,0]), label="Average Error Approx", 
    #         lw=1, color='black')
    ax1.plot(data4[:,0], err2+0.001, label="FPLM2 Mult", alpha=0.2,
             linestyle='', marker='o', markersize=1, fillstyle="full", color='tab:blue')
    ax1.plot(data4[:,0], err1, label="Approximated Mult", alpha=0.2,
             linestyle='', marker='o', markersize=1, fillstyle="full", color='tab:purple')
    
    ax1.grid(True)
    min_x = 0.9
    max_x = 2.1
    min_y = np.min(err2) - 0.2
    max_y = np.max(err2) + 0.2
    ax1.set_xlim(min_x, max_x)
    ax1.set_ylim(min_y, max_y)
    ax1.set_xlabel(r"a*b", fontsize=9)
    ax1.set_ylabel(r"approx(a*b)", fontsize=9)
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
    fig1.savefig("./mult_4bit_err.png", format="png", dpi=600, bbox_inches="tight")
    plt.close(fig1)



    #print(data8)

    fig1, ax1 = plt.subplots(1, 1, figsize=(3.5, 2.5))
    ax1.plot(data8[:,0], data8[:,0], label="Actual Mult", 
             lw=1, color='black')
    ax1.plot(data8[:,0], data8[:, 2]+0.01, label="FPLM2 Mult", alpha=0.1,
             linestyle='', marker='o', markersize=0.2, fillstyle="full", color='tab:blue')
    ax1.plot(data8[:,0], data8[:, 1], label="Approximated Mult", alpha=0.1,
             linestyle='', marker='o', markersize=0.2, fillstyle="full", color='tab:purple')
    
    ax1.grid(True)
    min_x = 0.9
    max_x = 2.1
    min_y = 0.9
    max_y = 2.2
    ax1.set_xlim(min_x, max_x)
    ax1.set_ylim(min_y, max_y)
    ax1.set_xlabel(r"a*b", fontsize=9)
    ax1.set_ylabel(r"approx(a*b)", fontsize=9)
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
    fig1.savefig("./mult_8bit.png", format="png", dpi=600, bbox_inches="tight")
    plt.close(fig1)

    print()
    err1 = (data8[:, 1] - data8[:, 0]) / data8[:, 0]
    err2 = (data8[:, 2] - data8[:, 0]) / data8[:, 0]
    print(np.mean(np.abs(err1)))
    print(np.mean(np.abs(err2)))
    print(np.mean(err1))
    print(np.mean(err2))

    
    print()
    print(max(err1))

    fig1, ax1 = plt.subplots(1, 1, figsize=(3.5, 2.5))
    #ax1.plot(data8[:,0], np.mean(np.abs(err1))*np.ones_like(data8[:,0]), label="Average Error Approx", 
    #         lw=1, color='black')
    ax1.plot(data8[:,0], err2+0.001, label="FPLM2 Mult", alpha=0.1,
             linestyle='', marker='o', markersize=0.2, fillstyle="full", color='tab:blue')
    ax1.plot(data8[:,0], err1, label="Approximated Mult", alpha=0.1,
             linestyle='', marker='o', markersize=0.2, fillstyle="full", color='tab:purple')
    
    ax1.grid(True)
    min_x = 0.9
    max_x = 2.1
    min_y = np.min(err2) - 0.2
    max_y = np.max(err2) + 0.2
    ax1.set_xlim(min_x, max_x)
    ax1.set_ylim(min_y, max_y)
    ax1.set_xlabel(r"a*b", fontsize=9)
    ax1.set_ylabel(r"approx(a*b)", fontsize=9)
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
    fig1.savefig("./mult_8bit_err.png", format="png", dpi=600, bbox_inches="tight")
    plt.close(fig1)


