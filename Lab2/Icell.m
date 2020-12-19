function I_matrix = Icell (RGBimage, vdd)

    p1 = 4.251e-05;
    p2 = -3.029e-4;
    p3 = 3.024e-5;
    
    %Exctract dimensions.
    height = length(RGBimage(:, 1, 1));
    width  = length(RGBimage(1, :, 1));
    
    I_matrix = zeros (width, height, 3);
    
    for i = 1:height
         for j = 1:width
            I_matrix(i, j, 1) = ((p1*vdd*double(RGBimage(i, j, 1)))/255) + ((p2*double(RGBimage(i, j, 1)))/255) + p3;
            I_matrix(i, j, 2) = ((p1*vdd*double(RGBimage(i, j, 2)))/255) + ((p2*double(RGBimage(i, j, 2)))/255) + p3;
            I_matrix(i, j, 3) = ((p1*vdd*double(RGBimage(i, j, 3)))/255) + ((p2*double(RGBimage(i, j, 3)))/255) + p3;
         end
     end 
end