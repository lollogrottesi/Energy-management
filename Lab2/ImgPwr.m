%Compute power of image.
%Is assumed that Img input is RGB format.
function [pwr, pwrR, pwrG, pwrB] = ImgPwr (Img)

     height = length(Img(:, 1, 1));
     width  = length(Img(1, :, 1));
     wR = 2.13636845*10-7;
     wG = 1.77746705*10-7;
     wB = 2.14348309*10-7;
     w0 = 1.48169521*10-6;
     coef = 0.7755;
     pwrR = 0;
     pwrG = 0;
     pwrB = 0;
     
     for i = 1:height
         for j = 1:width
            %pwr(i) = wR * R^coef + wG * G^coef + wB * B^coef
            pwrR = pwrR + wR*(double(Img(i, j, 1)))^coef;
            pwrG = pwrG + wG*(double(Img(i, j, 2)))^coef;
            pwrB = pwrB + wB*(double(Img(i, j, 3)))^coef;
            %pwr = pwr + wR*(double(Img(i, j, 1)))^coef + wG*(double(Img(i, j, 2)))^coef + wB*(double(Img(i, j, 3)))^coef;
         end
     end 
     pwr = w0 + pwrR + pwrG + pwrB;
end