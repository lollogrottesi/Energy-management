function showColorDistribution(imgRGB)

    %Exctract RGB channels.
    %R = imgRGB;
    %R(:,:,2:3) = 0;
    %G = imgRGB;
    %G(:,:,[1 3]) = 0;
    %B = imgRGB;
    %B(:,:,1:2) = 0;
    R = imgRGB(:, :, 1);
    G = imgRGB(:, :, 2);
    B = imgRGB(:, :, 3);
    
    histogram(R, 'FaceColor', 'r');
    hold on;
    histogram(G, 'FaceColor', 'g');
    hold on;
    histogram(B, 'FaceColor', 'b');
    legend('Red', 'Green', 'Blue');
end