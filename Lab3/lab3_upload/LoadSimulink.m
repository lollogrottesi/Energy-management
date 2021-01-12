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
I(1) = PV_blue(idx , 1);
V(1) = PV_blue(idx , 2);

PV_pwr = PV_red(:, 1).*PV_red(:, 2);
[~, idx] = max(PV_pwr);
I(2) = PV_red(idx , 1);
V(2) = PV_red(idx , 2);

PV_pwr = PV_green(:, 1).*PV_green(:, 2);
[~, idx] = max(PV_pwr);
I(3) = PV_green(idx , 1);
V(3) = PV_green(idx , 2);

PV_pwr = PV_purple(:, 1).*PV_purple(:, 2);
[~, idx] = max(PV_pwr);
I(4) = PV_purple(idx , 1);
V(4) = PV_purple(idx , 2);

clearvars PV_red PV_blue PV_green PV_purple idx 