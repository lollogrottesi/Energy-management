%%Test IMGDist

W = 256;
H = 256;
l_max = 100;
A_B_max = 128;
l_min = 0;
A_B_min = -127;

T_i = zeros(W, H, 3);
T_j = zeros(W, H, 3);

T_i (:, :, 1) = l_max;
T_i (:, :, 2) = A_B_max;
T_i (:, :, 3) = A_B_max;

T_j (:, :, 1) = l_min;
T_j (:, :, 2) = A_B_min;
T_j (:, :, 3) = A_B_min;

T_i = lab2rgb(T_i);
T_j = lab2rgb(T_j);
%figure(1);
%image(T_i);
%figure(2);
%image(T_j);
height = length(T_i(:, 1, 1));
width  = length(T_j(1, :, 1));
LabImgi = rgb2lab(T_i);
LabImgj = rgb2lab(T_j);
Li_sum = 0;
Lj_sum = 0;
ai_sum = 0;
aj_sum = 0;
bi_sum = 0;
bj_sum = 0;
%distortion1 = 0;
for i = 1:height
     for j = 1:width
         Li_sum = double(Li_sum + LabImgi(i, j, 1));
         Lj_sum = double(Lj_sum + LabImgj(i, j, 1));
         ai_sum = double(ai_sum + LabImgi(i, j, 2));
         aj_sum = double(aj_sum + LabImgj(i, j, 2));
         bi_sum = double(bi_sum + LabImgi(i, j, 3));
         bj_sum = double(bj_sum + LabImgj(i, j, 3));
         %distortion1 =  distortion1 + (double(LabImgi(i, j, 1) - LabImgj(i, j, 1)))^2 + (double(LabImgi(i, j, 2) - LabImgj(i, j, 2) + 127 ))^2 + (double(LabImgi(i, j, 3) - LabImgj(i, j, 3) + 127 ))^2;
     end
end 
distortionSQRT = sqrt((Li_sum - Lj_sum)^2 + (ai_sum - aj_sum)^2 + (bi_sum - bj_sum)^2);
%distortionsqrt = sqrt(double(distortion1));
max_dst = width*height*374.2325;
distortion = (distortionSQRT/max_dst)*100;
%distortionOut = (distortionsqrt/max_dst)*100; %Compute distortion percentage.
%%
clc
clear