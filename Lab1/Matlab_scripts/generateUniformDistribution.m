%Function generates num_sample values uniform distributed between min and
%max. If stable = 0 the uniformity is leaved to Matlab function otherwise a
%smoother distribution is created.

function dst_vector = generateUniformDistribution(stable, min, max, num_sample)
    if stable == 0
        pd = makedist('Uniform','Lower',min,'Upper',max); %Uniform distribution:[min, max].
        dst_vector = zeros(1, num_sample);
        for i = 1:num_sample
            dst_vector(i) = floor(random(pd));
        end
    else
        sort_vector   = zeros(1, num_sample);
        dst_vector = zeros(1, num_sample);

        for i = min:num_sample
            sort_vector(i) = mod(i, max); 
        end

        i=1;
        %Shuffle the ordered vector to abtain the active one.
        for idx = randperm(num_sample)
            dst_vector(idx) = sort_vector(i);
            i=i+1;
        end
    end
end 