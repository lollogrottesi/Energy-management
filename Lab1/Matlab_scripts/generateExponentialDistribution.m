function dst_vector = generateExponentialDistribution(mu, num_sample)
    pd = makedist('Exponential','mu',mu);
    dst_vector = zeros(1, num_sample);
    for i = 1:num_sample
    dst_vector(i) = floor(random(pd));
    end
end 