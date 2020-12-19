%The function rescale the blue component by the percentage value.
%If percentage = 100% all blue components are cleared.
%If percentage = 0% all the blue components reamin untouched.

function new_image = hungryBlue (hungryImg, percentage)
   
    if percentage < 0 || percentage > 100
        error("Error percentage between 0 and 100"); 
    end
    
    height = length(hungryImg(:, 1, 1));
    width  = length(hungryImg(1, :, 1));
    
    new_image = hungryImg;
    
    for i = 1:height
         for j = 1:width
            new_image(i, j, 3) = floor(double(hungryImg(i, j, 3)) - double(hungryImg(i, j, 3))*(double(percentage)/100));
         end
     end 
end