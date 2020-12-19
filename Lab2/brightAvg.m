function avgB = brightAvg(imgRGB)
    height = length(imgRGB(:, 1, 1));
    width  = length(imgRGB(1, :, 1));
    HSV = rgb2hsv(imgRGB);
    avgB = 0; 
    for i = 1:height
        for j=1:width
           avgB = avgB + HSV (i, j, 3); 
        end
    end
    avgB = avgB/(height*width);
end