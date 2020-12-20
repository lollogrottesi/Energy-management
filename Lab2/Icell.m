function I_matrix = Icell (RGBimage, vdd)

    p1 = 4.251e-05;
    p2 = -3.029e-4;
    p3 = 3.024e-5;
    
    %Exctract dimensions.
    height = length(RGBimage(:, 1, 1));
    width  = length(RGBimage(1, :, 1));
    
    I_matrix = zeros (height, width, 3);
    
    for i = 1:height
         for j = 1:width
            tmp_1 = ((p1*vdd*double(RGBimage(i, j, 1)))/255) + ((p2*double(RGBimage(i, j, 1)))/255) + p3;
            tmp_2 = ((p1*vdd*double(RGBimage(i, j, 2)))/255) + ((p2*double(RGBimage(i, j, 2)))/255) + p3;
            tmp_3 = ((p1*vdd*double(RGBimage(i, j, 3)))/255) + ((p2*double(RGBimage(i, j, 3)))/255) + p3;
            
            if tmp_1 >= 0
                I_matrix(i, j, 1) = tmp_1;
            else
                I_matrix(i, j, 1) = 0;
            end
            
            if tmp_2 >= 0
                I_matrix(i, j, 2) = tmp_2;
            else
                I_matrix(i, j, 2) = 0;
            end
            
            if tmp_3 >= 0
                I_matrix(i, j, 3) = tmp_3;
            else
                I_matrix(i, j, 3) = 0;
            end
            %I_matrix(i, j, 1) = ((p1*vdd*double(RGBimage(i, j, 1)))/255) + ((p2*double(RGBimage(i, j, 1)))/255) + p3;
            %I_matrix(i, j, 2) = ((p1*vdd*double(RGBimage(i, j, 2)))/255) + ((p2*double(RGBimage(i, j, 2)))/255) + p3;
            %I_matrix(i, j, 3) = ((p1*vdd*double(RGBimage(i, j, 3)))/255) + ((p2*double(RGBimage(i, j, 3)))/255) + p3;
         end
     end 
end