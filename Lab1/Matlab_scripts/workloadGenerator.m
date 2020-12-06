%% 
%---------------------------Constant declaration---------------------------
%Assume unit in us.

%Active periodi uniform distribution.
min_active = 1;
max_active = 500;
%Idle perdiod uniform distrubution.
max_idle = 400;
min_idle = 1;

num_sample = 5000; %Number of samples in the workload.

%%
%----------------------Generate the distributions--------------------------
%Decomment the selected distribution and set the input values.

%Generate active distribution.
%active_vector = generateUniformDistribution(0, 1, 500, num_sample);
%Generate idle vector.
%idle_vector = generateUniformDistribution(0, 1, 100, num_sample);
%idle_vector = generateUniformDistribution(0, 1, 400, num_sample);
%idle_vector = generateGaussianDistribution(100, 20, num_sample);
%idle_vector = generateExponentialDistribution(50, num_sample);
%idle_vector = generateTrimodalDistribution(50, 10, 100, 10, 150, 10, num_sample);
[active_vector, idle_vector] = generateCorrelatedDistribution(800, num_sample);
%Plot the two distributions.
figure(1)
subplot(2, 1, 1);
ShowDistribution(active_vector);
title('Active period distribution');
subplot(2, 1, 2);
ShowDistribution(idle_vector);
title('Idle period distribution');

%%
%----------------------Compute workload------------------------------------
%idle_vector = idle_vector;        %Select one idle distribution.
fileName = 'periodWorkload.txt';   %Change name of the output workload.
%Compute the workload starting from idle and active vectors using the notation and save resul into a matrix.
wl_matrix = zeros(num_sample, 2);
wl_matrix(1,1) = active_vector(1);
wl_matrix(1,2) = wl_matrix(1,1) + idle_vector(1);

for i = 2:num_sample
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




