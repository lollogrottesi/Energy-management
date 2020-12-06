%Riscrivere routine usando idle axis tra min R_vector e max R_vector.
function [emp_pd, idle_axis ,total_p] = ShowDistribution(R_vector)
    %--------------------------Show the distribution---------------------------
    step = 1;                                   %Minimum step resolution 1 us.
    num_sample = length(R_vector);              %Define the number of samples of the distribution.
    idle_axis = [1:step:500];                   %Create the idle axis.
    emp_pd = zeros(1, length(idle_axis));       %Vector distribution. 

    %Compute probability if each value in R_vector.
    for i = idle_axis
       cnt = 0;
       for rnd_val = R_vector
           if rnd_val == i
               cnt = cnt + 1;
           end 
           emp_pd(i) = cnt/num_sample; 
       end
    end

    %Plot result and compute total probability.
    plot(idle_axis, emp_pd);

    total_p = 0;
    for p = emp_pd
        total_p = total_p + p;
    end 

    %Total_p must be 1!
    total_p 
end