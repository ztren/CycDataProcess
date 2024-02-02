Filename = input('Please input the file name:',"s");
if string(Filename(max(strlength(Filename)-3,1):strlength(Filename))) ~= ".txt"
    Filename = Filename + ".txt";
end

% PeakVoltage = 2.7 %Test voltage
PeakVoltage = input('Please input the peak (charged) voltage (±0.005V):');
TheOneCycle = input('Please input the index of cycle for analysis (0 for disabling):');

% Filename = 'RH001_Li4Ti5O12_initialtest_1C-2C-10C_2pt7V_CF7.txt' %Test File
Rawdata = readtable(Filename);
Rawdata.Properties.VariableNames = ["cycle number" , "ox/red" , "control changes" , "Ns changes" , "time/s" , "step time/s" , "Ecell/V" , "<I>/mA" , "Capacity/mA.h" , "Q discharge/mA.h" , "Q charge/mA.h" , "dq/mA.h"];

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

vt = figure;
vi = figure;
qv = figure;
qn = figure; % charge/ previous discharge
if (TheOneCycle > 0)
    sc = figure; % Single Cycle
end
QFinal = [];

Index = 1;
LastState = -1; % 1 for charge, 0 for discharge
for Cyclenum = (0: nCycle)
    while Rawdata{Index, "cycle number"} == Cyclenum
        State = Rawdata{Index, "ox/red"};
        if (State ~= LastState) || (Index == height(Rawdata));
            if Index ~= 1
                % Dataarray
                figure(vt);
                hold on
                subplot(2,1,(2-LastState)) % subplot 1 for charge, 2 for discharge
                plot(Dataarray(:,1),Dataarray(:,2),'color',blueGRADIENTflexible(Cyclenum,nCycle));
                xlabel("time (s)");ylabel("Voltage (V)");
                figure(vi);
                hold on
                subplot(2,1,(2-LastState)) % subplot 1 for charge, 2 for discharge
                plot(Dataarray(:,2),Dataarray(:,3),'color',blueGRADIENTflexible(Cyclenum,nCycle));
                xlabel("Voltage (V)");ylabel("Current (mA)");
                figure(qv);
                hold on
                subplot(2,1,(2-LastState)) % subplot 1 for charge, 2 for discharge
                plot(Dataarray(:,4),Dataarray(:,2),'color',blueGRADIENTflexible(Cyclenum,nCycle));
                xlabel("Capacity (mAh)");ylabel("Voltage (V)");
            end
            if (Cyclenum ~= 0) || (LastState == 0)
                QFinal = [QFinal; Dataarray(height(Dataarray),4)];
            end
            if (TheOneCycle == (Cyclenum + 1)) && (TheOneCycle > 0) && (LastState == 0)
                DischargeHandler = [Dataarray(:,4),Dataarray(:,2)];
            elseif (TheOneCycle == (Cyclenum)) && (TheOneCycle > 0) && (LastState == 1)
                ChargeHandler = [Dataarray(:,4),Dataarray(:,2)];
                ChargeHandler(:,1) = DischargeHandler(height(DischargeHandler),1) - ChargeHandler(:,1);
                Handler = [DischargeHandler; ChargeHandler];
                figure(sc);
                hold on
                % plot(DischargeHandler(:,1),DischargeHandler(:,2), 'color', 'blue');
                % plot(ChargeHandler(:,1),ChargeHandler(:,2), 'color', 'red');
                plot(Handler(:,1),Handler(:,2));
                xlabel("Capacity (mAh)");ylabel("Voltage (V)");
            end
            if (Index == height(Rawdata))
                break
            end
            Dataarray = []; % Time, Voltage, Current, Capacity
            t0 = Rawdata{Index,"time/s"}; %Time when charge/discharge starts
        end
        h = height(Dataarray);
        if (State ~= 1) || (h < 2) || ((abs(Dataarray(h,2)/Dataarray(h-1,2))-1) > 6E-5) || (abs(Dataarray(h,2) - PeakVoltage) > 0.005) % Trimming
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
plot(CDC);
xlabel("Number of Cycle");ylabel("QC/QDC");

exportgraphics(vt,'TimeVoltage.png','Resolution',300)
exportgraphics(vi,'VoltageCurrent.png','Resolution',300)
exportgraphics(qv,'VoltageCapacity.png','Resolution',300)
exportgraphics(qn,'IterationCharge.png','Resolution',300)
if (TheOneCycle > 0)
    exportgraphics(sc,'SingleCycle'+string(TheOneCycle)+'.png','Resolution',300)
end
close all