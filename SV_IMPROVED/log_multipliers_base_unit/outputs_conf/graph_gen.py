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

            a_in, b_in, lm_out, fplm2_out, mlm_out = line.split("_")
            a_in = get_mantissa(a_in[e_ind:m_ind]) * get_exponent(a_in[0:e_ind])
            b_in = get_mantissa(b_in[e_ind:m_ind]) * get_exponent(b_in[0:e_ind])
            a_out = a_in * b_in
            lm_out = get_mantissa(lm_out[e_ind:m_ind]) * get_exponent(lm_out[0:e_ind])
            fplm2_out = get_mantissa(fplm2_out[e_ind:m_ind]) * get_exponent(fplm2_out[0:e_ind])
            mlm_out = get_mantissa(mlm_out[e_ind:m_ind]) * get_exponent(mlm_out[0:e_ind])

            while a_out >= 2.0:
                a_out = a_out / 2
                lm_out = lm_out / 2
                fplm2_out = fplm2_out / 2
                mlm_out = mlm_out / 2

            data_list.append([a_out, lm_out, fplm2_out, mlm_out])

    data = np.array(data_list, dtype=np.float64)

    return data

if __name__ == "__main__":

    data4 = get_data("8bit.out", 3, 7)
    data10 = get_data("16bit.out", 5, 15)
    data7 = get_data("16bitb.out", 8, 15)
    data12 = get_data("24bit.out", 9, 23)

    data = [data4, data7, data10, data12]

    files = ["8bit", "16bitb", "16bit", "24bit"]
    bins = [16, 64, 64, 64]
    methods = ["Proposed_LM", "FPLM2", "Mitchell_LM"]

    for j in range(len(methods)):
        for i, d in enumerate(data):
            print(files[i] + " Average Error Distance and Average Net Error " + methods[j])
            err1 = (d[:, (j+1)] - d[:, 0]) / d[:, 0]
            print(np.mean(np.abs(err1)))
            print(np.mean(err1))

            #print(np.min(err1))
            #print(np.max(err1))

            err_avg = err1


            # Colormap/2D Histogram

            fig1, ax1 = plt.subplots(1, 1, figsize=(3.5, 2.5))
            ax1.hist2d(d[:, 0], d[:, (j+1)], bins=bins[i], cmap=cc.cm.blues)
            ax1.plot(d[:, 0], d[:, 0], lw=1, color='crimson')
            ax1.set_xlabel(r"a*b", fontsize=9)
            ax1.set_ylabel(r"approx(a*b)", fontsize=9)
            ax1.tick_params(labelsize=8)
            fig1.savefig("./" + methods[j] + "/" + files[i] + "_hist.png", format="png", dpi=600, bbox_inches="tight")
            plt.close(fig1)

            # Colormap/2D Histogram Error

            fig1, ax1 = plt.subplots(1, 1, figsize=(3.5, 2.5))
            ax1.hist2d(d[:, 0], err1, bins=bins[i], cmap=cc.cm.blues, range=[[1.0, 2.0], [-0.115, 0.17]])
            #ax1.plot(d[:, 0], d[:, 0], lw=1, color='crimson')
            ax1.set_xlabel(r"a*b", fontsize=9)
            ax1.set_ylabel(r"approx(a*b)", fontsize=9)
            ax1.set_ylim((-.115, .17))
            ax1.tick_params(labelsize=8)
            fig1.savefig("./" + methods[j] + "/" + files[i] + "_err_hist.png", format="png", dpi=600, bbox_inches="tight")
            plt.close(fig1)



