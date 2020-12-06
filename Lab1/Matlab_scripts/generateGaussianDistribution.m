function dst_vector = generateGaussianDistribution(mu, sigma, num_sample)
    pd = makedist('Normal','mu',mu,'sigma',sigma);
    dst_vector = zeros(1, num_sample);
    for i = 1:num_sample
        dst_vector(i) = floor(random(pd));
    end
end 