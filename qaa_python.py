import pandas as pd
import numpy as np

df = pd.read_csv(r"E:\pCO2\NorthPacific\result\NorthPacific_rrs_sst_ws_slp.csv")

g0 = 0.08945
g1 = 0.1247

# pre-test Rrs670
first_row = df.iloc[3]
idx410 = 0
idx440 = 1
idx490 = 3
idx555 = 6
idx670 = 8
wavel = [412, 443, 469, 488, 531, 547, 555, 645, 667, 678]
selected_columns = ["Rrs_412", "Rrs_443", "Rrs_469", "Rrs_488", "Rrs_531", "Rrs_547", "Rrs_555", "Rrs_645", "Rrs_667",
                    "Rrs_678"]
aw = [3.11e-03, 4.88e-03, 8.69e-03, 1.26e-02, 4.23e-02, 5.29e-02, 5.96e-02, 3.25e-01, 4.33e-01, 4.57e-01]
bbw = [2.83e-03, 2.06e-03, 1.61e-03, 1.36e-03, 9.43e-04, 8.31e-04, 7.80e-04, 4.07e-04, 3.53e-04, 3.29e-04]
acoefs = [-1.145902928, -1.365828264, -0.469266028]
S = 0.015


# input param
# row:  a row of the DataFrame with columns
def qaa(row):
    selected_columns = ["Rrs_412", "Rrs_443", "Rrs_469", "Rrs_488", "Rrs_531", "Rrs_547", "Rrs_555", "Rrs_645",
                        "Rrs_667", "Rrs_678"]
    Rrs = row[selected_columns].to_numpy()
    aph_check = False

    # step 0
    rrs = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    for i in range(len(Rrs)):
        rrs[i] = Rrs[i] / (0.52 + 1.7 * Rrs[i])

    # step 1
    u = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    for i in range(len(Rrs)):
        u[i] = (np.sqrt(g0 * g0 + 4.0 * g1 * rrs[i]) - g0) / (2.0 * g1)

    # step 2
    if (Rrs[idx670] >= 0.0015):
        aref = aw[idx670] + 0.39 * np.power((Rrs[idx670] / (Rrs[idx440] + Rrs[idx490])), 1.14)
        idxref = idx670
    else:
        numer = rrs[idx440] + rrs[idx490]
        denom = rrs[idx555] + 5 * rrs[idx670] * (rrs[idx670] / rrs[idx490])
        if (numer / denom <= 0):
            rho = np.nan
        else:
            rho = np.log10(numer / denom)
        rho = acoefs[0] + acoefs[1] * rho + acoefs[2] * rho * rho
        aref = aw[idx555] + np.power(10.0, rho)
        idxref = idx555

    # step 3
    bbpref = ((u[idxref] * aref) / (1.0 - u[idxref])) - bbw[idxref]

    # step 4
    rat = rrs[idx440] / rrs[idx555]
    Y = 2.0 * (1.0 - 1.2 * np.exp(-0.9 * rat))

    # step 5
    bb = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    bbp = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    for i in range(len(Rrs)):
        try:
            bb[i] = bbpref * np.power((wavel[idxref] / wavel[i]), Y) + bbw[i]
        except OverflowError:
            bb[i] = np.nan

    # step 6
    a = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    for i in range(len(Rrs)):
        if u[i] == 0:
            a[i] = np.nan
        else:
            a[i] = ((1.0 - u[i]) * bb[i]) / u[i]

    # step 7
    rat = rrs[idx440] / rrs[idx555]
    symbol = 0.74 + (0.2 / (0.8 + rat))
    # step 8
    Sr = S + 0.002 / (0.6 + rat)
    # zeta = np.exp(Sr * (wavel[idx440] - wavel[idx410]))
    zeta = np.exp(Sr * (442.5 - 415.5))

    # step 9
    denom = zeta - symbol
    dif1 = a[idx410] - symbol * a[idx440]
    dif2 = aw[idx410] - symbol * aw[idx440]
    ag440 = (dif1 - dif2) / denom

    adg = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    aph = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    for i in range(len(Rrs)):
        adg[i] = ag440 * np.exp(Sr * (wavel[idx440] - wavel[i]))
        aph[i] = a[i] - adg[i] - aw[i]

    if (aph_check):
        x1 = aph[idx440] / a[idx440]
        if (x1 < 0.15 or x1 > 0.6):
            x2 = -0.8 + 1.4 * (a[idx440] - aw[idx440]) / (a[idx410] - aw[idx410])
            if (x2 < 0.15):
                x2 = 0.15
            if (x2 > 0.6):
                x2 = 0.6;
            aph[idx440] = a[idx440] * x2
            ag440 = a[idx440] - aph[idx440] - aw[idx440];
            for i in range(len(Rrs)):
                adg[i] = ag440 * np.exp(Sr * (wavel[idx440] - wavel[i]))
                aph[i] = a[i] - adg[i] - aw[i]

    adg = np.asarray(adg)
    aph = np.asarray(aph)
    aph[(aph <= 0)] = np.nan
    adg_aph = np.concatenate((adg, aph))
    return adg_aph


# aph_array, adg_array = df.apply(qaa, axis=1)
aph_array = np.array(df.apply(qaa, axis=1).tolist())
# aph_df = pd.DataFrame(aph_array, columns=["aph_" + str(i) for i in range(1, 11)])
# df = pd.concat([df, aph_df], axis=1)
# df
