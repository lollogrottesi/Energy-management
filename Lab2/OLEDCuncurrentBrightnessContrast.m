%The function rescale the blue component by the percentage value.

function new_image = OLEDCuncurrentBrightnessContrast (hungryImg, gl, gu)
    %Check bounds .
    if (gu < 0)
        gu = 0;
    elseif (gu > 1)
        gu = 1;
    end

    if (gl < 0)
        gl = 0;
    elseif (gl > 1)
        gl = 1;
    end 
    %Exctract dimensions.
    height = length(hungryImg(:, 1, 1));
    width  = length(hungryImg(1, :, 1));
    
    HSV = rgb2hsv(hungryImg);
    
    %gl = gl/255;
    %gu = gu/255;
    
    c = 1/(gu - gl);
    d = (gl/(gu-gl));
    
    for i = 1:height
         for j = 1:width
            if (HSV(i, j, 3)<= gl)
                HSV(i, j, 3) = 0;
            elseif (HSV(i, j, 3) > gl && HSV (i, j, 3)<= gu) 
                HSV(i, j, 3) = c*HSV(i, j, 3) + d;
            else
                HSV(i, j, 3) = 1.0;
            end
         end
    end 
    new_image = im2uint8(hsv2rgb(HSV));
    
end