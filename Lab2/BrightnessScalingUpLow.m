%gl lower bound of greyscale, from 0 to 255.
%gu upperbound of greyscale, from 0 to 255.
function new_image = BrightnessScalingUpLow (hungryImg, gl, gu)
    
    %Exctract dimensions.
    height = length(hungryImg(:, 1, 1));
    width  = length(hungryImg(1, :, 1));
    
    HSV = rgb2hsv(hungryImg);
    
    gl = gl/255;
    gu = gu/255;
    
    c = 1/(gu - gl);
    K = 1/c;
    d = -(gl/(gu-gl));
    for i = 1:height
         for j = 1:width
            HSV(i, j, 3) = HSV(i, j, 3) * K;
            if (HSV(i, j, 2)<= gl)
                HSV(i, j, 2) = 0;
            elseif (HSV(i, j, 2) > gl && HSV (i, j, 2)<= gu) 
                HSV(i, j, 2) = c*HSV(i, j, 2) + d;
            else
                HSV(i, j, 2) = 1;
            end
         end
    end 
    new_image = hsv2rgb(HSV);
    
end