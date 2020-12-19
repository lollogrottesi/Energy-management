function [avgR, avgG, avgB] = colorAvg(imgRGB)
    %Exctract dimensions.
    height = length(imgRGB(:, 1, 1));
    width  = length(imgRGB(1, :, 1));
    
    avgR = 0;
    avgG = 0;
    avgB = 0;
    for i=1:height
        for j=1:width
            avgR = uint32(avgR) + uint32(imgRGB(i, j, 1));
            avgG = uint32(avgG) + uint32(imgRGB(i, j, 2));
            avgB = uint32(avgB) + uint32(imgRGB(i, j, 3));
        end
    end
    avgR = avgR / (height*width);
    avgG = avgG / (height*width);
    avgB = avgB / (height*width);
end