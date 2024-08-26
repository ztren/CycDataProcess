import os
import pandas as pd
import numpy as np
import matplotlib as plt
import math

print("Welcome. Please make sure the experiment data is stored in Data/ folder. Create the folder if it doesn't exist.\n")
Filename = input('Please input the file name:')
if Filename[-4:] != ".csv":
    Filename = Filename + ".csv"

try:
    Rawdata = pd.read_csv("Data/"+Filename)
except:
    print("File not found. Did you put it in Data/Filename?")
# Rawdata.Properties.VariableNames = ["cycle number" , "ox/red" , "control changes" , "Ns changes" , "time/s" , "step time/s" , "Ecell/V" , "<I>/mA" , "Capacity/mA.h" , "Q discharge/mA.h" , "Q charge/mA.h" , "dq/mA.h"];
nCycle = Rawdata['half.cycle'].max()


QuickSetup = int(input('Enter 0 for quick setup (auto adjusts everything):'))
if QuickSetup != 0:
    # % PeakVoltage = 2.7 %Test voltage
    PeakVoltage = int(input('Please input the peak (charged) voltage for graphing (0 for auto adjustment):'))
    TheOneCycle = int(input(f'Please input the first index (to maximum {nCycle}) of half cycle for analysis\n (-1 for disabling, 0 for all cycles (default)):'))
    Mass = int(input('Please enter the specific mass (mg, <=0 for disabling):'))
    dqdvIndicator = int(input('Please enter the difference of index for dq/dv (0 for default(2), -1 for disable):'))
else:
    PeakVoltage = 0
    TheOneCycle = 0#; %Should be 0; -1 for testing.
    Mass = 0
    dqdvIndicator = 2


Path = "Figures/"+Filename[:-4]
os.mkdir(Path)

try:
    if ((TheOneCycle > nCycle) | (TheOneCycle < -1) | (math.floor(TheOneCycle) != TheOneCycle)):
        print('Cycle index not possible (either <=0 or > the maximum index). Disabling single cycle analysis')
        TheOneCycle = nCycle + 1
    elif (TheOneCycle == -1):
        print('Single cycle analysis disabled')
        TheOneCycle = nCycle + 1
except:
    print('Unknown error. Disabling single cycle analysis')
    TheOneCycle = 0

for Index in range(TheOneCycle, nCycle+1):
    xAxis = 1#what
    yAxis = 1#yea what

    plt.savefig(Path+'/VoltageCapacity.png')
    plt.close()