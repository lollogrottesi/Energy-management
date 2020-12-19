function [totalPwr, pwr_RGB] = panelPower (Icell, vdd)
   pwr_RGB = zeros(1, 3);
   height = length(Icell(:, 1, 1));
   width  = length(Icell(1, :, 1));
   for i = 1:height
         for j = 1:width
            pwr_RGB(1) = pwr_RGB(1) + Icell(i, j, 1);
            pwr_RGB(2) = pwr_RGB(2) + Icell(i, j, 2);
            pwr_RGB(3) = pwr_RGB(3) + Icell(i, j, 3);
         end
   end 
   pwr_RGB = vdd*pwr_RGB;
   totalPwr = pwr_RGB(1) + pwr_RGB(2) + pwr_RGB(3);
end