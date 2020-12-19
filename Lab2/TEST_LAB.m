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

dst = ImgDist(T_i, T_j)
%%