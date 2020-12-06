function dst_vector = generateTrimodalDistribution(mu_1, sigma_1, mu_2, sigma_2, mu_3, sigma_3, num_sample)
    g1 = makedist('Normal','mu',mu_1,'sigma',sigma_1);
    g2 = makedist('Normal','mu',mu_2,'sigma',sigma_2);
    g3 = makedist('Normal','mu',mu_3,'sigma',sigma_3);
    dst_vector = zeros(1, num_sample);
    for i = 1:num_sample
        tmp_i = mod(i, 3);
        if tmp_i == 0
            dst_vector(i) = floor(random(g1));
        elseif tmp_i == 1
            dst_vector(i) = floor(random(g2));
        elseif tmp_i == 2
            dst_vector(i) = floor(random(g3));
        end
    end 
end