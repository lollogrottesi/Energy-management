%Generate two vector active and idle considering a periodic workload
%characterized by long idle periods and short active periods when current
%time < T and once in a period (c_time > T) there is a long active followed
%by a short idle. The function cycles this workload distributions
%until num_sample samples are generated. 

%Distribution features are not passed as parameter but fixed by the
%function:
%Active distribution long  => Uniform [300, 500]
%Active distribution short => Uniform [1, 200]
%Idle distribution long    => Gassian mean: 400, var:20
%Idle distribution high    => Gassian mean: 100, var:20

function [active_vector, idle_vector] = generatePeriodicalDistribution(T, num_sample)
    %Declare distributions.
    pd_idle_high   = makedist('Normal','mu',400,'sigma',20);
    pd_idle_low    = makedist('Normal','mu',100,'sigma',20);
    pd_active_high = makedist('Uniform','Lower',300,'Upper',500); 
    pd_active_low  = makedist('Uniform','Lower',1,'Upper',200);
    %Init output vectors.
    active_vector = zeros(1, num_sample);
    idle_vector = zeros(1, num_sample);
    
    time_cnt  = 1;%This variable will accumulate the time counting.
    %smple_cnt = 1;
    for i = 1:num_sample
        if time_cnt >= T
            active_vector(i)  = floor(random(pd_active_high)); 
            idle_vector(i)    = floor(random(pd_idle_low)); 
            while idle_vector(i) < 0 
                %Drop negative samples.
                idle_vector  (i) = floor(random(pd_idle_low));
            end
            time_cnt = 1;
        else
            active_vector(i)  = floor(random(pd_active_low)); 
            idle_vector(i)    = floor(random(pd_idle_high));
            while idle_vector(i) < 0 
                %Drop negative samples.
                idle_vector(i) = floor(random(pd_idle_high));
            end
            time_cnt = time_cnt + active_vector(i) + idle_vector(i);
        end
    end
end 