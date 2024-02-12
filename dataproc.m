fprintf("Welcome. Please make sure the experiment data is stored in Data/ folder. Create the folder if it doesn't exist.\n")
Filename = input('Please input the file name:',"s");
if string(Filename(max(strlength(Filename)-3,1):strlength(Filename))) ~= ".txt"
    Filename = Filename + ".txt";
end

QuickSetup = input('Enter 0 for quick setup (auto adjusts everything):',"s");
if (QuickSetup ~= "0")
    % PeakVoltage = 2.7 %Test voltage
    PeakVoltage = input('Please input the peak (charged) voltage for graphing (0 for auto adjustment):'); % Trimming is now disabled. PeakVoltage is now used for setting the axis of single cycle diagram. If 
    TheOneCycle = input('Please input the first index (to the final) of cycle for analysis\n (0 for disabling, 1 for all cycles):');
    Mass = input('Please enter the specific mass (mg, <=0 for disabling):');
    dqdvIndicator = input('Please enter the difference of index for dq/dv (0 for default(2), -1 for disable):');
else
    PeakVoltage = 0;
    TheOneCycle = 1; %Should be 1; 0 for testing
    Mass = 0;
    dqdvIndicator = 2;
end
if (dqdvIndicator == 0)
    dqdvIndicator = 2;
end

try
    Rawdata = readtable("Data/"+Filename);
catch
    error("File not found. Did you put it in Data/Filename?")
end
Rawdata.Properties.VariableNames = ["cycle number" , "ox/red" , "control changes" , "Ns changes" , "time/s" , "step time/s" , "Ecell/V" , "<I>/mA" , "Capacity/mA.h" , "Q discharge/mA.h" , "Q charge/mA.h" , "dq/mA.h"];

Path = "Figures/"+erase(Filename,".txt");
mkdir(Path);
nCycle = max(Rawdata{:,'cycle number'});
try
    if ((TheOneCycle > nCycle) || (TheOneCycle < 0) || (floor(TheOneCycle) ~= TheOneCycle))
        warning('Cycle index not possible (either <=0 or > the maximum index). Disabling single cycle analysis');
        TheOneCycle = 0;
    elseif (TheOneCycle == 0)
        warning('Single cycle analysis disabled');
    end
catch
    warning('Unknown error. Disabling single cycle analysis');
    TheOneCycle = 0;
end

lightBLUE = [0.356862745098039,0.811764705882353,0.956862745098039];
darkBLUE = [0.0196078431372549,0.0745098039215686,0.670588235294118];
blueGRADIENTflexible = @(i,N) lightBLUE + (darkBLUE-lightBLUE)*((i)/(N));

% vt = figure;
% vi = figure;
qv = figure; % Q/V
if (Mass > 0)
    qm = figure; % Qm^-1/V
end
qn = figure; % charge/ previous discharge
if (TheOneCycle > 0)
    sc = figure; % Single Cycle
    tc = figure; % Conbined Cycles
    mkdir(Path+"/SingleCycleData");
end
if (dqdvIndicator >= 0)
    if (dqdvIndicator == 0)
        dqdvIndicator = 2;
    end
    dqdv = figure; % Qm^-1/V
end
QFinal = [];

Index = 1;
LastState = -1; % 1 for charge, 0 for discharge
for Cyclenum = (0: nCycle)
    while Rawdata{Index, "cycle number"} == Cyclenum
        State = Rawdata{Index, "ox/red"}; % get Charge/Discharge state, if not equal to the last state generate plot and clear Dataarray
        if (State ~= LastState) || (Index == height(Rawdata));
            if Index ~= 1
                %%
                % Dataarray
                % figure(vt);
                % hold on
                % subplot(2,1,(2-LastState)) % subplot 1 for charge, 2 for discharge
                % plot(Dataarray(:,1),Dataarray(:,2),'color',blueGRADIENTflexible(Cyclenum,nCycle));
                % xlabel("time (s)");ylabel("Voltage (V)");
                % figure(vi);
                % hold on
                % subplot(2,1,(2-LastState)) % subplot 1 for charge, 2 for discharge
                % plot(Dataarray(:,2),Dataarray(:,3),'color',blueGRADIENTflexible(Cyclenum,nCycle));
                % xlabel("Voltage (V)");ylabel("Current (mA)");
                %% 
                figure(qv); %mAh/V
                hold on
                subplot(2,1,(2-LastState)) % subplot 1 for charge, 2 for discharge
                plot(Dataarray(:,4),Dataarray(:,2),'color',blueGRADIENTflexible(Cyclenum,nCycle));
                xlabel("Capacity (mAh)");ylabel("Voltage (V)");
                if (Mass > 0)
                    figure(qm); %mAh*mg-1/V
                    hold on
                    subplot(2,1,(2-LastState)) % subplot 1 for charge, 2 for discharge
                    plot(Dataarray(:,4) / Mass,Dataarray(:,2),'color',blueGRADIENTflexible(Cyclenum,nCycle));
                    xlabel("mAh/mg");ylabel("Voltage (V)");
                end

                if (Cyclenum ~= 0) || (LastState == 0) %Record final Q for C/DC diagram
                    QFinal = [QFinal; Dataarray(height(Dataarray),4)];
                end
    
                if (TheOneCycle == (Cyclenum + 1)) && (TheOneCycle > 0) && (LastState == 0) %record single cycle data
                    DischargeHandler = [Dataarray(:,4),Dataarray(:,2)];
                elseif (TheOneCycle == (Cyclenum)) && (TheOneCycle > 0) && (LastState == 1)
                    ChargeHandler = [Dataarray(:,4),Dataarray(:,2)];
                    ChargeHandler(:,1) = DischargeHandler(height(DischargeHandler),1) - ChargeHandler(:,1);
                    Handler = [DischargeHandler; ChargeHandler];
                    figure(sc);
                    % plot(DischargeHandler(:,1),DischargeHandler(:,2), 'color', 'blue');
                    % plot(ChargeHandler(:,1),ChargeHandler(:,2), 'color', 'red');
                    plot(Handler(:,1),Handler(:,2),'color',blueGRADIENTflexible(TheOneCycle,nCycle));
                    xlim([0,ceil(max(Handler(:,1)) * 10) / 10]);
                    if PeakVoltage == 0
                        PeakVoltage = ceil(max(Handler(:,2)));
                    end
                    ylim([0,PeakVoltage]);
                    xlabel("Capacity (mAh)");ylabel("Voltage (V)");
                    exportgraphics(sc,Path+"/SingleCycleData/Cycle"+string(TheOneCycle)+".png",'Resolution',300)
                    figure(tc);
                    hold on
                    plot(Handler(:,1),Handler(:,2),'color',blueGRADIENTflexible(TheOneCycle,nCycle));
                    xlabel("Capacity (mAh)");ylabel("Voltage (V)");
                    TheOneCycle = TheOneCycle + 1;
                end
                
                try
                    if (isempty(1+dqdvIndicator: height(Dataarray)-dqdvIndicator)) || (dqdvIndicator <= 0)
                        throw(ME);
                    end
                    DQ = Dataarray(1+dqdvIndicator : height(Dataarray),4) - Dataarray(1 : height(Dataarray)-dqdvIndicator,4);
                    DV = Dataarray(1+dqdvIndicator : height(Dataarray),2) - Dataarray(1 : height(Dataarray)-dqdvIndicator,2); %V
                    DV = DV * 1000; %mV
                    dqdvArray = [Dataarray(1+dqdvIndicator : height(Dataarray),2),DQ./DV];
                    figure(dqdv);
                    hold on
                    subplot(2,1,(2-LastState)) % subplot 1 for charge, 2 for discharge
                    plot(dqdvArray(:,1),dqdvArray(:,2),'color',blueGRADIENTflexible(Cyclenum,nCycle));
                    xlabel("Voltage (V)");ylabel("dQ/dV");
                    ylim([-0.01,0.01]);
                catch ME
                    if 1
                        warning("Difference of index for dq/dv is too large or manually disabled dq/dv. Disabling dq/dv generation");
                    end
                end
            end
            if (Index == height(Rawdata))
                break
            end
            Dataarray = []; % Time, Voltage, Current, Capacity
            t0 = Rawdata{Index,"time/s"}; %Time when charge/discharge starts
        end
        h = height(Dataarray);
        if (State ~= 1) || (h < 2) || ((abs(Dataarray(h,2)/Dataarray(h-1,2))-1) > 6E-5) %|| (abs(Dataarray(h,2) - PeakVoltage) > 0.005) % Trimming, Now disabled because we're not currently using them
            Time = Rawdata{Index,"time/s"} - t0;
            Voltage = Rawdata{Index,"Ecell/V"};
            Current = Rawdata{Index, "<I>/mA"};
            Capacity = Rawdata{Index, "Capacity/mA.h"};
            Dataarray = [Dataarray; Time, Voltage, Current, Capacity];
        end
        
        LastState = State;
        Index = Index + 1;
    end
end
hold off

CDC = [];
for i = (1:floor(height(QFinal)/2))
    CDC = [CDC; QFinal(i*2)/QFinal(i*2-1)]; %Charge/previous discharge
end
figure(qn)
scatter(linspace(1,i,i),CDC,"filled");
xlabel("Number of Cycle");ylabel("QC/QDC");

% exportgraphics(vt,Path+'/TimeVoltage.png','Resolution',300)
% exportgraphics(vi,Path+'/VoltageCurrent.png','Resolution',300)
exportgraphics(qv,Path+'/VoltageCapacity.png','Resolution',300)
exportgraphics(qn,Path+'/IterationCharge.png','Resolution',300)
if (Mass > 0)
    exportgraphics(qm,Path+'/VoltageCapacityMass.png','Resolution',300)
end
if (TheOneCycle > 0)
    exportgraphics(tc,Path+'/CombinedCycle.png','Resolution',300)
end
if (dqdvIndicator > 0)
    exportgraphics(dqdv,Path+'/dQdV.png','Resolution',300)
end
close all