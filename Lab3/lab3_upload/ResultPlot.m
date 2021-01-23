%% BATTERY PLOT.
figure (1);
time = 1:length(battSOC);
total_time = length(time)/3600
plot(time, battSOC);
hold on
plot(time, battVoltage);
xlabel ('Time [s]');
legend('SOC', 'BatteryVoltage');
figure(2);
subplot(2, 1, 1);
plot(time(1:period), efficiencyBattery(1:period));
xlabel('Time [s]');
ylabel('Efficiency');
title('Battery DC-DC efficiency in time');
subplot(2, 1, 2);
plot(IRequest(1:period), efficiencyBattery(1:period));
xlabel('I Load [A]');
ylabel('Efficiency');
title('Battery DC-DC efficiency in current');
%% PV I-V, power, efficiency.
time = 1:length(battSOC);
%I
figure(1);
subplot(2,2,1);
plot(time, LIGHT_WL);
xlabel ('Time [s]');
ylabel ('Light');
title('PV Light');
subplot(2,2,2);
plot(time, PVcurrent);
xlabel ('Time [s]');
ylabel ('PV current [A]');
title('PV Current');
%V
subplot(2,2,3);
plot(time, PVvoltage);
xlabel ('Time [s]');
ylabel ('PV voltage [V]');
title('PV Voltage');
%P
subplot(2,2,4);
PVpower = PVcurrent.*PVvoltage;
plot(time, PVpower);
xlabel ('Time [s]');
ylabel ('PV watt [W]');
title('PV Power');
figure(2);
plot(PVvoltage, efficiencyPV);
title('PV converter efficiency');
xlabel ('PV voltage [V]');
ylabel ('Efficiency');
%% ACTIVE PV.
time = 1:length(battSOC);
plot(time, activePV);
xlabel('time');
ylabel('0 => PV not charging, 1 => PV charging');
title('PV active');
%% LOAD PLOT
subplot(2,1,1);
time = 1:(2*period);
plot (time, 3.3*airI(1:2*period));
hold on 
plot (time, 3.3*methI(1:2*period));
hold on 
plot (time, 3.3*micI(1:2*period));
hold on 
plot (time, 3.3*tempI(1:2*period));
hold on 
plot (time, 3.3*mcI(1:2*period));
hold on 
plot (time, 3.3*zbI(1:2*period));
legend('AIR', 'METH', 'MIC', 'TEMP', 'MAC', 'TRAN');
xlabel('Time [s]');
ylabel('Power [w]');
title('Load power request');
subplot(2,1,2);
plot (time, AIR_PERIOD(1:2*period));
hold on 
plot (time, METHANE_PERIOD(1:2*period));
hold on 
plot (time, MIC_PERIOD(1:2*period));
hold on 
plot (time, TEMP_PERIOD(1:2*period));
hold on 
plot (time, MAC_PERIOD(1:2*period));
hold on 
plot (time, TRANSMIT_PERIOD(1:2*period));
legend('AIR', 'METH', 'MIC', 'TEMP', 'MAC', 'TRAN');
xlabel('Time [s]');
title('Workload');
%% PLOT SCHEDULING
figure (1);
subplot(3, 1 , 1);
time = 1:length(battSOC);
total_time = length(time)/3600
plot(time, battSOC);
hold on
plot(time, battVoltage);
xlabel ('Time [s]');
legend('SOC', 'BatteryVoltage');
title('Battery state');
subplot(3,1,2);
time = 1:(2*period);
plot (time, 3.3*airI(1:2*period));
hold on 
plot (time, 3.3*methI(1:2*period));
hold on 
plot (time, 3.3*micI(1:2*period));
hold on 
plot (time, 3.3*tempI(1:2*period));
hold on 
plot (time, 3.3*mcI(1:2*period));
hold on 
plot (time, 3.3*zbI(1:2*period));
legend('AIR', 'METH', 'MIC', 'TEMP', 'MAC', 'TRAN');
xlabel('Time [s]');
ylabel('Power [w]');
title('Load power request');
subplot(3,1,3);
plot (time, AIR_PERIOD(1:2*period));
hold on 
plot (time, METHANE_PERIOD(1:2*period));
hold on 
plot (time, MIC_PERIOD(1:2*period));
hold on 
plot (time, TEMP_PERIOD(1:2*period));
hold on 
plot (time, MAC_PERIOD(1:2*period));
hold on 
plot (time, TRANSMIT_PERIOD(1:2*period));
legend('AIR', 'METH', 'MIC', 'TEMP', 'MAC', 'TRAN');
xlabel('Time [s]');
title('Workload');
%% CHARGE RATE
s_time = length(activePV);
cnt = 0;
for i = 1:s_time
    if activePV(i) == 1
       cnt = cnt + 1; 
    end
end

CHARGE_RATE = cnt/s_time*100

clearvars s_time i cnt CHARGE_RATE

%% MULTI BATTERY PLOT.
figure (1);
time = 1:length(battSOC_0);
total_time = length(time)/3600
subplot(1, 2, 1);
plot(time, battSOC_0);
hold on
plot(time, battVoltage_0);
title('Battery 0');
legend('SOC', 'BatteryVoltage');
subplot(1, 2, 2);
plot(time, battSOC_1);
hold on
plot(time, battVoltage_1);
xlabel ('Time [s]');
title('Battery 1');
legend('SOC', 'BatteryVoltage');
figure(2);
subplot(2, 1, 1);
plot(time(1:period), efficiencyBattery(1:period));
xlabel('Time [s]');
ylabel('Efficiency');
title('Battery DC-DC efficiency in time');
subplot(2, 1, 2);
plot(IRequest(1:period), efficiencyBattery(1:period));
xlabel('I Load [A]');
ylabel('Efficiency');
title('Battery DC-DC efficiency in current');