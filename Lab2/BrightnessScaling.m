%The function rescale the blue component by the percentage value.
%If percentage = 100% complete darkness.
%If percentage = 0% brightness is untouhced.
function new_image = BrightnessScaling (hungryImg, scalingPercentage)

    if scalingPercentage < 0 || scalingPercentage > 100
        error("Error percentage between 0 and 100"); 
    end
    
    %Exctract dimensions.
    height = length(hungryImg(:, 1, 1));
    width  = length(hungryImg(1, :, 1));
    
    HSV = rgb2hsv(hungryImg);
    
    scalingPercentage = 100 - scalingPercentage;
    K = scalingPercentage/100; 
    
    for i = 1:height
         for j = 1:width
            HSV(i, j, 3) = HSV(i, j, 3) * K;
            HSV(i, j, 2) = HSV(i, j, 2) / K;
         end
    end 
    new_image = hsv2rgb(HSV);
    
end