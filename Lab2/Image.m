%% Find elemts in a given folder
currentFolder = pwd;
folderLst = [ "misc", "BSP" ];

myFolder = currentFolder + "\dataset";
cd (myFolder);
imgLst = ls;
%%
%[X, cmap] = imread(imgLst(3,:));
%X = imread(imgLst(3,:), 1);
X = imread('test_1_blue.jpg');
%figure
imshow(X);
%RGB = ind2rgb(X, map);
%% Exctract RGB channels (marginal).
%Test on functions.
X = imread('test.jpg');

R = X;
R(:,:,2:3) = 0;
G = X;
G(:,:,[1 3]) = 0;
B = X;
B(:,:,1:2) = 0;

%imshow(R);

figure(1);
imhist(R);
hold on;
imhist(G);
hold on;
imhist(B);
J = histeq(X);
figure(2);
imhist(J);
figure(3);
image(X);
figure(4);
image(J);
dst = (1 - ssim(X, J))*100
%figure(1);
%imshow(X);
%imhist(X);
%figure(2);
%imshow(J);
%imhist(J);
%% GRAY IMAGE.
X_init = imread('pp.tiff');

if length(size(X_init)) == 2
    X = cat(3, X_init, X_init, X_init);
end

Y = BrightnessScaling(X, 50);
pwrX = ImgPwr (X);
pwrY = ImgPwr (Y);

powerSaving = ((pwrX - pwrY)/pwrX)*100;
dst = (1 - ssim(X, Y))*100;

figure(1)
imshow(X_init);
figure(2)
imshow(Y(:, :, 1));
%% Test hungry blue.
X = imread('pp.tiff');
pwrX = ImgPwr (X);
Y = hungryBlue(X, 50); %reduce 50% of blue.
pwrY = ImgPwr (Y);
dst = ImgDist(X, Y)
powerSaving = ((pwrX - pwrY)/pwrX)*100
figure(1)
imshow(X);
figure(2)
imshow(Y);
%% Test Brightness scaling
X = imread('test.jpg');
pwrX = ImgPwr (X)
Y = BrightnessScaling(X, 20); 
pwrY = ImgPwr (Y)
dst = ImgDist(X, Y)
figure(1)
imshow(X);
figure(2)
imshow(Y);
%% Test Brightness scaling gl - gu.
X = imread('test.jpg');
pwrX = ImgPwr (X)
Y = BrightnessScalingUpLow(X, 20, 250); 
pwrY = ImgPwr (Y)
dst = ImgDist(X, Y)
figure(1)
imshow(X);
figure(2)
imshow(Y);
%% Test algorithm
X = imread('test.tiff');
[avgR, avgG, avgB] = colorAvg(X);
bright_Avg = brightAvg(X);
max_R_G = max(avgR, avgG);

if avgB > max_R_G
    k_blue = (double(avgB - max_R_G)/double(avgB))*100;
    Y = hungryBlue(X, k_blue); %Reduce k% of blue
end

threshold = 0.01; % 1%.

if bright_Avg  > 0.5
    k_bright = (bright_Avg - bright_Avg*(1-threshold))*100;
    Z = BrightnessScaling(X, 1);%Reduce k% of brightness.
end 

%K = histeq(Z);

pwrX = ImgPwr (X);
%pwrY = ImgPwr (Y);
pwrZ = ImgPwr (Z);

powerSaving = ((pwrX - pwrZ)/pwrX)*100;
dst = (1 - ssim(X, Z))*100

figure(1)
imshow(X);
figure(2)
imshow(Z);
%%
%cd (currentFolder)
clc
clear 
%%