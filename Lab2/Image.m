%% Find elemts in a given folder
currentFolder = pwd;
folderLst = [ "misc", "BSP" ];

myFolder = currentFolder + "\misc";
cd (myFolder);
imgLst = ls;
%%
%[X, cmap] = imread(imgLst(3,:));
X = imread(imgLst(3,:), 1);
%figure
imshow(X(:,:, 3));
%RGB = ind2rgb(X, map);
%% Exctract RGB channels (marginal).
X = imread('test.jpg');
R = X;
R(:,:,2:3) = 0;
G = X;
G(:,:,[1 3]) = 0;
B = X;
B(:,:,1:2) = 0;

imshow(R);
%%
X = imread('test.jpg');
pwrX = ImgPwr (X)
Y = hungryBlue(X, 10); %reduce 50% of blue.
pwrY = ImgPwr (Y)
dst = ImgDist(X, Y)
figure(1)
imshow(X);
figure(2)
imshow(Y);
%%
clc
clear 
%%