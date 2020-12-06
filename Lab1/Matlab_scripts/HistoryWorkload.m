%%
%---------------------------Constant declaration---------------------------
%Assume unit in us.
num_sample = 5000; %Number of samples in the workload.

%Train 50% test 50%.

%Generate correlated distribution.
%[active_vector, idle_vector] = generatePeriodicalDistribution(800, num_sample);

active_vector = generateUniformDistribution(0, 1, 500, num_sample);
%idle_vector = generateUniformDistribution(0, 1, 400, num_sample);
%idle_vector = generateTrimodalDistribution(50, 10, 100, 10, 150, 10, num_sample);
%idle_vector = generateGaussianDistribution(100, 20, num_sample);
idle_vector = generateExponentialDistribution(50, num_sample);

%Plot.
figure(1)
subplot(2, 1, 1);
ShowDistribution(active_vector);
title('Active period distribution');
subplot(2, 1, 2);
ShowDistribution(idle_vector);
title('Idle period distribution');

%% Train algorithm 1. 
%Regression for T_idle[i] = k0 + k1*T_idle[i-1] + k2*T_active[i] + k3*T_idle[i-1]*T_acive[i]^2 + k4*T_idle[i-1]^2*T_active[i]....
num_sample_train = num_sample/2 + 1; %One samples will be catted.
T_idle     = zeros(1, num_sample_train); 
T_idle_i_1 = idle_vector(1:num_sample_train);
T_active   = active_vector(2:num_sample_train+1);

for i=1:num_sample_train-1 %Last value remains at zero.
    T_idle(i) =  T_idle_i_1(i+1); 
end

%Cat last two values.
T_idle      = T_idle(1:num_sample_train-1)';
T_idle_i_1  = T_idle_i_1(1:num_sample_train-1)';
T_active    = T_active(1:num_sample_train-1)';

%corrcoef(T_idle, T_active)

%myFit = fittype('k0 + k1*x + k2*y + k3*x*y + k4*x*(y^2) + k5*(x^2)*y + k6*(x^2) + k7*(y^2)', 'dependent', 'z', 'independent', {'x', 'y'}, 'coefficients', {'k0', 'k1', 'k2', 'k3','k4', 'k5','k6', 'k7'});
%myFit = fittype('k0 + k1*x + k2*y + k3*x*y + k4*(y^2)', 'dependent', 'z', 'independent', {'x', 'y'}, 'coefficients', {'k0', 'k1', 'k2', 'k3','k4'});
%myFit = fittype('k0 + k1*x + k2*y + k3*(x^2)', 'dependent', 'z', 'independent', {'x', 'y'}, 'coefficients', {'k0', 'k1', 'k2', 'k3'});
myFit = fittype('k0 + k1*x + k2*y ', 'dependent', 'z', 'independent', {'x', 'y'}, 'coefficients', {'k0', 'k1', 'k2'});
pred_T_idle = fit ([T_idle_i_1, T_active], T_idle, myFit);

plot (pred_T_idle, [T_idle_i_1, T_active], T_idle);
title('Periodical 800 us reduced fit');
xlabel('T idle [i-1]');
ylabel('T active [i]');
zlabel('T idle [i]');

coefficients = coeffvalues(pred_T_idle)
%% Generate output workload
num_sample_test = num_sample - num_sample_train;
idle_vector   = idle_vector  (num_sample_train-1:num_sample_train+num_sample_test);
active_vector = active_vector(num_sample_train-1:num_sample_train+num_sample_test);

fileName = 'testUniform_1_100.txt';     %Change name of the output workload.
%Compute the workload starting from idle and active vectors using the notation and save resul into a matrix.
wl_matrix = zeros(num_sample_test, 2);
wl_matrix(1,1) = active_vector(1);
wl_matrix(1,2) = wl_matrix(1,1) + idle_vector(1);

for i = 2:num_sample_test
    wl_matrix(i,1) = wl_matrix(i-1, 2) + active_vector(i);
    wl_matrix(i,2) = wl_matrix(i,1) + idle_vector(i);
end
%----------------------Create .txt workload format-------------------------

txtID = fopen(fileName, 'a');
%Specify the writing format.
format = '  %d  %d  \n';
%Print the matrix according the format.
fprintf(txtID, format, wl_matrix'); 

fclose(txtID);
%%
%-----Read the .txt file and check the distribution correctness------------
[parsed_active_vector, parsed_idle_vector] = WorkLooadParser(fileName, format);
figure(2);
subplot(2, 1, 1);
ShowDistribution(parsed_active_vector);
title('Active period  parsed distribution');
subplot(2, 1, 2);
ShowDistribution(parsed_idle_vector);
title('Idle period  parsed distribution');
%%
clc
clearvars
%%
