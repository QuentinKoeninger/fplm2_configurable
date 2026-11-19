import numpy as np
import matplotlib.pyplot as plt
import colorcet as cc

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

            a_in, b_in, p_out = line.split("_")
            #a_in, b_in, p_out, f_out = line.split("_")
            a_in = get_mantissa(a_in[e_ind:m_ind]) * get_exponent(a_in[0:e_ind])
            b_in = get_mantissa(b_in[e_ind:m_ind]) * get_exponent(b_in[0:e_ind])
            a_out = a_in * b_in
            p_out = get_mantissa(p_out[e_ind:m_ind]) * get_exponent(p_out[0:e_ind])
            #f_out = get_mantissa(f_out[e_ind:m_ind]) * get_exponent(f_out[0:e_ind])

            while a_out >= 2.0:
                a_out = a_out / 2
                p_out = p_out / 2
                #f_out = f_out / 2

            #data_list.append([a_out, p_out, f_out])
            data_list.append([a_out, p_out])

    data = np.array(data_list, dtype=np.float64)

    return data

if __name__ == "__main__":

    data4 = get_data("8bit.out", 3, 7)
    data10 = get_data("16bit.out", 5, 15)
    data7 = get_data("16bitb.out", 8, 15)
    data12 = get_data("24bit.out", 9, 21)

    data = [data4, data7, data10, data12]

    files = ["8bit", "16bitb", "16bit", "24bit"]
    bins = [16, 30, 50, 60]

    for i, d in enumerate(data):
        #fig1, ax1 = plt.subplots(1, 1, figsize=(3.5, 2.5))
        #ax1.plot(d[:,0], d[:,0], label="Actual Mult", 
        #         lw=1, color='black')
        ##ax1.plot(d[:,0], d[:, 2]+0.01, label="FPLM2 Mult", alpha=0.2,
        ##         linestyle='', marker='o', markersize=1, fillstyle="full", color='tab:blue')
        #ax1.plot(d[:,0], d[:, 1], label="Approximated Mult", alpha=0.2,
        #         linestyle='', marker='o', markersize=1, fillstyle="full", color='tab:purple')
#
        #ax1.grid(True)
        #min_x = 0.9
        #max_x = 2.1
        #min_y = 0.9
        #max_y = 2.2
        #ax1.set_xlim(min_x, max_x)
        #ax1.set_ylim(min_y, max_y)
        #ax1.set_xlabel(r"a*b", fontsize=9)
        #ax1.set_ylabel(r"approx(a*b)", fontsize=9)
        #ax1.legend(
        #    fontsize=7,            # 7-8 pt font size
        #    frameon=True,          # Keep frame enabled
        #    framealpha=0.8,        # Slight transparency to avoid obscuring data behind it
        #    edgecolor='gray',      # Subtle border line
        #    handlelength=1.5,      # Keep line sample length compact (default is 2.0)
        #    labelspacing=0.3,      # Compact vertical spacing between labels
        #    loc='lower right'             # Automatically select best low-density area
        #)
        #ax1.tick_params(labelsize=8)
        #fig1.savefig("./" + files[i] + ".png", format="png", dpi=600, bbox_inches="tight")
        #plt.close(fig1)

        print(files[i] + " Average Error Distance and Average Net Error")
        err1 = (d[:, 1] - d[:, 0]) / d[:, 0]
        print(np.mean(np.abs(err1)))
        print(np.mean(err1))


        #fig1, ax1 = plt.subplots(1, 1, figsize=(3.5, 2.5))
        ##ax1.plot(d[:,0], np.mean(np.abs(err1))*np.ones_like(d[:,0]), label="Average Error Approx", 
        ##         lw=1, color='black')
        #ax1.plot(d[:,0], err1, label="Approximated Mult", alpha=0.2,
        #         linestyle='', marker='o', markersize=1, fillstyle="full", color='tab:purple')
#
        #ax1.grid(True)
        #min_x = 0.9
        #max_x = 2.1
        #min_y =  (np.min(err1) if (np.min(err1) < np.min(err1)) else np.min(err1)) - 0.2
        #max_y = (np.max(err1) if (np.max(err1) > np.max(err1)) else np.max(err1)) + 0.2
        #ax1.set_xlim(min_x, max_x)
        #ax1.set_ylim(min_y, max_y)
        #ax1.set_xlabel(r"a*b", fontsize=9)
        #ax1.set_ylabel(r"approx(a*b)", fontsize=9)
        #ax1.legend(
        #    fontsize=7,            # 7-8 pt font size
        #    frameon=True,          # Keep frame enabled
        #    framealpha=0.8,        # Slight transparency to avoid obscuring data behind it
        #    edgecolor='gray',      # Subtle border line
        #    handlelength=1.5,      # Keep line sample length compact (default is 2.0)
        #    labelspacing=0.3,      # Compact vertical spacing between labels
        #    loc='lower right'             # Automatically select best low-density area
        #)
        #ax1.tick_params(labelsize=8)
        #fig1.savefig("./"+ files[i] + "_err.png", format="png", dpi=600, bbox_inches="tight")
        #plt.close(fig1)

        # Colormap/2D Histogram

        fig1, ax1 = plt.subplots(1, 1, figsize=(3.5, 2.5))
        #ax1.plot(d[:,0], np.mean(np.abs(err1))*np.ones_like(d[:,0]), label="Average Error Approx", 
        #         lw=1, color='black')
        ax1.hist2d(d[:, 0], d[:, 1], bins=bins[i], cmap=cc.cm.blues)
        ax1.plot(d[:, 0], d[:, 0], lw=1, color='crimson')
        ax1.set_xlabel(r"a*b", fontsize=9)
        ax1.set_ylabel(r"approx(a*b)", fontsize=9)
        ax1.tick_params(labelsize=8)
        fig1.savefig("./"+ files[i] + "_hist.png", format="png", dpi=600, bbox_inches="tight")
        plt.close(fig1)

        # Colormap/2D Histogram Error

        fig1, ax1 = plt.subplots(1, 1, figsize=(3.5, 2.5))
        #ax1.plot(d[:,0], np.mean(np.abs(err1))*np.ones_like(d[:,0]), label="Average Error Approx", 
        #         lw=1, color='black')
        ax1.hist2d(d[:, 0], err1, bins=bins[i], cmap=cc.cm.blues)
        ax1.set_xlabel(r"a*b", fontsize=9)
        ax1.set_ylabel(r"approx(a*b)", fontsize=9)
        ax1.tick_params(labelsize=8)
        fig1.savefig("./"+ files[i] + "_err_hist.png", format="png", dpi=600, bbox_inches="tight")
        plt.close(fig1)



