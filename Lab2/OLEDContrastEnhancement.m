%The function rescale the blue component by the percentage value.

function new_image = OLEDContrastEnhancement (hungryImg, b)
    
    %Exctract dimensions.
    height = length(hungryImg(:, 1, 1));
    width  = length(hungryImg(1, :, 1));
    
    HSV = rgb2hsv(hungryImg);
    
    for i = 1:height
         for j = 1:width
            HSV(i, j, 3) = HSV(i, j, 3) / b;
         end
    end 
    new_image = im2uint8(hsv2rgb(HSV));
    
end