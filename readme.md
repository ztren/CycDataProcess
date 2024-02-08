# Recycler Data Tracker and Plotter for Griffith Lab
## Installing (macOS)
Firstrun: Install MATLAB. Change Directory to the folder. Execute the following line of code in bash

`chmod 755 run.sh`

Then you could execute `./run.sh` in the folder. Make sure you include the script, `dataproc.m`, and your data under `Data/` in the same folder 

## Usage
The program will ask for four prompts, the file name, the peak voltage, the cycle number, and specific mass (Is that the correct name?). 

### Filename
File name can be with or without `.txt` (but the actual file should be a txt file)

### Peak Voltage
This is the fully charged voltage, ~~used for trimming when the voltage doesn't actually change at the charged state.~~ (no longer does that. HOWEVER, There is evidence that we might still need them) Instead, It works as a reference for the graphing

### Cycle number
Input a number no more than the maximum cycle index to analyze the `Q/V` relationship from that cycle to the end of experiment.

### Mass
Used for certain calculations. Enter 0 to disable related figures to generate.

## Note
if one want to do research on the figure rather than get an impression of everything it might be better to use the actual MATLAB app where one can scale in and drag the plots. To do this simply open the `dataproc.m` on MATLAB, and comment out the last line, i.e. making it

`% close all` 

(I already did that)

## Future plans
add limitations (like plotting for certain cycles)? √(in some ways - plotting everything)
user enter AM mass in mg √
change CE to scatter plot √
fixed scale for single cycle graphs √
dQ/dV
<!-- Lithiation -->