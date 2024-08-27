# import os
import sys
import subprocess
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from matplotlib import cm
import time
# import math

def ztest(points, thresh=3):
    if len(points.shape) == 1:
        points = points[:,None]
    median = np.median(points, axis=0)
    diff = np.sum((points - median)**2, axis=-1)
    diff = np.sqrt(diff)
    med_abs_deviation = np.median(diff)

    modified_z_score = 0.6745 * diff / med_abs_deviation

    return modified_z_score > thresh

if len(sys.argv) == 1:
    print("Welcome. Please make sure the experiment data is stored in Data/ folder. Create the folder if it doesn't exist.")
    Filename = input('Please input the file name:')
    if Filename[-4:] != ".mpr":
        Filename = Filename + ".mpr"
else:
    Filename = sys.argv[1]
    try:
        subprocess.call("Rscript mprRead.R " +Filename, shell=True)
        Filename = Filename[:-4] + ".csv"
        Rawdata = pd.read_csv("Data/"+Filename)
    except FileNotFoundError:
        print(Filename+" not found. The CSV Converter might be failed.")
        log = open('Checker.log', 'a')
        log.write(Filename+" is new/updated but mprReader couldn't read it. Please Check Manually\n")
        log.close()
    except:
        print(Filename+" read failed. Did you put it in Data/Filename?")
nCycle = Rawdata['half.cycle'].max()

# 


# QuickSetup = int(input('Enter 0 for quick setup (auto adjusts everything):'))
# if QuickSetup != 0:
#     # % PeakVoltage = 2.7 %Test voltage
#     # PeakVoltage = int(input('Please input the peak (charged) voltage for graphing (0 for auto adjustment):')) # Introduced Z score trimming. Don't think I need this anymore.
#     TheOneCycle = int(input(f'Please input the first index (to maximum {nCycle}) of half cycle for analysis\n (-1 for disabling, 0 for all cycles (default)):'))
#     Mass = int(input('Please enter the specific mass (mg, <=0 for disabling):'))
#     dqdvIndicator = int(input('Please enter the difference of index for dq/dv (0 for default(2), -1 for disable):'))
# else:
#     PeakVoltage = 0
#     TheOneCycle = 0#; %Should be 0; -1 for testing.
#     Mass = 0
#     dqdvIndicator = 2
TheOneCycle = 0 # for compatability


# os.mkdir(Path)

# try:
#     if ((TheOneCycle > nCycle) | (TheOneCycle < -1) | (math.floor(TheOneCycle) != TheOneCycle)):
#         print('Cycle index not possible (either <=0 or > the maximum index). Disabling single cycle analysis')
#         TheOneCycle = nCycle + 1
#     elif (TheOneCycle == -1):
#         print('Single cycle analysis disabled')
#         TheOneCycle = nCycle + 1
# except:
#     print('Unknown error. Disabling single cycle analysis')
#     TheOneCycle = 0

colors = [ cm.cool(x) for x in np.linspace(0, 1, max(nCycle,1)) ]

QFinal = []
QDCFinal = []
Efficiency = []

plt.figure(figsize=(15,5))
plt.suptitle(Filename[9:-4],fontsize=18)

plt.subplot(121)
for Index in range(TheOneCycle, nCycle+1):
    Rawdata[Rawdata['half.cycle'] == Index]
    Xaxis = abs(Rawdata[Rawdata['half.cycle'] == Index]['Q.charge.discharge.mA.h'])
    if (Index % 2 == 0): 
        QFinal.append(Rawdata[Rawdata['half.cycle'] == Index]['Q.charge.discharge.mA.h'].iloc[-1])
        # Xaxis = -Xaxis
    if (Index % 2 == 1): 
        QDCFinal.append(Rawdata[Rawdata['half.cycle'] == Index]['Q.charge.discharge.mA.h'].iloc[-1])
        # Xaxis = QFinal[Index // 2 - 1]+Xaxis
    Yaxis = Rawdata[Rawdata['half.cycle'] == Index]['Ewe.V']
    plt.plot(Xaxis, Yaxis, color=colors[Index-1])
    plt.xlabel("Capacity (mAh)")
    plt.ylabel("Voltage(V)")
VoltageData = Rawdata['Ewe.V'].to_numpy()
Xlim = -np.array(QFinal)[~ztest(np.array(QFinal))]
Ylim = VoltageData[~ztest(VoltageData,3.5)]
# plt.xlim(-0.01,np.max(Xlim)+0.05)
# plt.ylim(np.min(Ylim)-0.05,np.max(Ylim)+0.05)

plt.subplot(122)
for I in Rawdata['X.I..mA']:
    if I > 0: 
        I = 1
        break
    elif I < 0: 
        I = -1
        break
for Index in range(min(len(QFinal),len(QDCFinal))):
    Efficiency.append(-QFinal[Index]**(-I) * QDCFinal[Index]**(I))
plt.scatter(range(1,len(Efficiency)+1), Efficiency , c=range(len(Efficiency)),cmap="cool")
try:
    plt.ylim(min(Efficiency)-0.05, max(Efficiency)+0.05) if ~ztest(np.array(Efficiency),4)[-1] else plt.ylim(min(Efficiency)-0.05, max(Efficiency[:-1])+0.05)
except:
    pass
plt.xlabel("# of Cycle")
plt.ylabel("Efficiency")
# plt.show()

Path = "GarbageChecker/"+time.strftime("%Y-%m-%d", time.localtime())+Filename[8:-4]
plt.savefig(Path+".png")
