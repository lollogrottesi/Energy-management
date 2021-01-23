% File for simulink.
addpath('./digitizer');
load('gmonths.mat');

G = [250; 500; 750; 1000];
I = [];
V = [];
PV_red    = importPV('PV_red.txt'   , 2, 31);
PV_blue   = importPV('PV_blue.txt'  , 2, 70);
PV_green  = importPV('PV_green.txt' , 2, 70);
PV_purple = importPV('PV_purple.txt', 2, 70);

PV_pwr = PV_blue(:, 1).*PV_blue(:, 2);
[~, idx] = max(PV_pwr);
V(1) = PV_blue(idx , 1);
I(1) = PV_blue(idx , 2);

PV_pwr = PV_red(:, 1).*PV_red(:, 2);
[~, idx] = max(PV_pwr);
V(2) = PV_red(idx , 1);
I(2) = PV_red(idx , 2);

PV_pwr = PV_green(:, 1).*PV_green(:, 2);
[~, idx] = max(PV_pwr);
V(3) = PV_green(idx , 1);
I(3) = PV_green(idx , 2);

PV_pwr = PV_purple(:, 1).*PV_purple(:, 2);
[~, idx] = max(PV_pwr);
V(4) = PV_purple(idx , 1);
I(4) = PV_purple(idx , 2);

I = I/1000;

clearvars PV_red PV_blue PV_green PV_purple idx PV_pwr

PV_DCDC = importPV('PV_DCDC.txt', 2, 70);
PV_DCDC(:, 2) = PV_DCDC(:, 2)/100;


BAT_DCDC = importPV('BAT_DCDC.txt', 2, 70);
BAT_DCDC(:, 1) = 10.^(BAT_DCDC(:, 1));
BAT_DCDC(:, 2) = BAT_DCDC(:, 2)/100;
%semilogx(BAT_DCDC(:, 1), BAT_DCDC(:, 2));

BATT_C1 = importPV("BATT_C1.txt");
BATT_C2 = importPV("BATT_C2.txt");
SOC = (0:0.1:1);
C = 3.2; %3200 mAh.
I1 = C*1;
I2 = C*2;
BATT_C1_INT = interp1(BATT_C1(:, 1), BATT_C1(:, 2), SOC);
BATT_C2_INT = interp1(BATT_C2(:, 1), BATT_C2(:, 2), SOC);
BATT_C1_INT = BATT_C1_INT(2:10);
BATT_C2_INT = BATT_C2_INT(2:10);
SOC = SOC(2:10);
%plot(SOC(2:10), BATT_C1_INT, '*');
%hold on
%plot(SOC(2:10), BATT_C2_INT, '*');

R = (BATT_C1_INT - BATT_C2_INT)/(I2 - I1);
VOC =  BATT_C2_INT + R*I2 ;
%R (SOC) => f(x) = p1*x^4 + p2*x^3 + p3*x^2 + p4*x + p5 
% p1 = -1.78
% p2 = 4.222
% p3 = -3.401
% p4 = 1.025
% p5 = 0.06208

%Voc(SOC) => f(x) = p1*x^4 + p2*x^3 + p3*x^2 + p4*x + p5
% p1 = -15.6
% p2 = 36.33
% p3 = -29.04
% p4 = 11.22
% p5 = 0.5787
clearvars BATT_C1 BATT_C2 C I1 I2 BATT_C1_INT BATT_C2_INT

