%Compute power of image.
%Is assumed that Img input is RGB format.
%By construction Imgi and Imgj have the same legths.
function distortion = ImgDist (Imgi, Imgj)
     height = length(Imgi(:, 1, 1));
     width  = length(Imgi(1, :, 1));
     LabImgi = rgb2lab(Imgi);
     LabImgj = rgb2lab(Imgj);
     distortion = 0;
     for i = 1:height
         for j = 1:width
             distortion =  distortion + (LabImgi(i, j, 1) - LabImgj(i, j, 1))^2 + (double(LabImgi(i, j, 2)) - double(LabImgj(i, j, 2)))^2 + (double(LabImgi(i, j, 3)) - double(LabImgj(i, j, 3)))^2;
         end
     end 
     distortion = sqrt(double(distortion));
     max_dst = width*height*374.2325;
     distortion = (distortion/max_dst)*100; %Compute distortion percentage.
end