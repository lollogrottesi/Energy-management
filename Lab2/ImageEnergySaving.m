%% Algorithm part 1.
dstThreshold = 10; % 1%, 5%, 10%.
rootFolder = pwd;

dataFolder = rootFolder + "\dataset";
cd (dataFolder);
tmpLst = ls;

imgLst = tmpLst;
imgLst(1, :) = []; %cut '. '
imgLst(1, :) = []; %cut '.. '
i=1;

%pattern = '.+(tiff|jpg|JPG|PNG|png)\s*$';
while i < length(imgLst)
    if contains(imgLst(i,:), 'Thumbs.db')
        imgLst(i,:) = [];          %Drop string.
    end 
    %if  regexp(imgLst(i,:), pattern)
    %    imgLst(i,:) = imgLst(i,:); %Match pattern.
    %else
    %    imgLst(i,:) = [];          %Drop string.
    %end
    i=i+1;
end

cd (rootFolder);
energy_saving = zeros(length(imgLst), 1);
dst_img = zeros(length(imgLst), 1);
    for i = 1:length(imgLst)
        cd (dataFolder);
        X = imread(imgLst(i,:));
        cd (rootFolder);
        %Start energy reduction algorithm.
        
        %Gray images are not considered.
            
        %Start transformation algorithm for RGB.
        Y = X;
        pwrY_init = ImgPwr (Y);
       

        %Histogram equalization.
        Y_tmp = histeq(Y);
        dist = (1 - ssim(X, Y_tmp))*100;
        pwrTmp = ImgPwr (Y_tmp);
        if dist <= dstThreshold && pwrTmp < pwrY_init %If possible keep transformation.
            Y = Y_tmp;
            pwrY_init = pwrTmp;
        end
        
        %Hungry blue optimization.
        %Exctract color features.
        [avgR, avgG, avgB] = colorAvg(Y);
        max_R_G = max(avgR, avgG); 
        %Reduce blue, if possible.
        if avgB > max_R_G %Check if Blue average is greater than both Red and Green.
            k_blue = (double(avgB - max_R_G)/double(avgB))*100;%Percentage distance.
            Y_tmp = hungryBlue(Y, k_blue);                     %Reduce k% of blue.
            dist = (1 - ssim(X, Y_tmp))*100;
            pwrTmp = ImgPwr (Y_tmp);
            if dist <= dstThreshold && pwrTmp < pwrY_init %If possible keep transformation.
                Y = Y_tmp;
                pwrY_init = pwrTmp;
            end
        end
        
       %Brightness optimization.
        scaling_percentage = 1;
        Y_tmp = BrightnessScaling(Y, scaling_percentage);%Reduce dstThreshold% of brightness.
        dist = (1 - ssim(X, Y_tmp))*100;
        pwrTmp = ImgPwr (Y_tmp);

        while dist <= dstThreshold && pwrTmp < pwrY_init  %If possible keep transformation.
            Y = Y_tmp;
            pwrY_init = pwrTmp;

            scaling_percentage = scaling_percentage + 1; %Try to scale 1% more.
            Y_tmp = BrightnessScaling(Y, scaling_percentage);%Reduce dstThreshold% of brightness.
            dist = (1 - ssim(X, Y_tmp))*100;
            pwrTmp = ImgPwr (Y_tmp);
        end
        
        %Power / Distance exctraction.
        pwrX = ImgPwr (X);
        pwrY = ImgPwr (Y);
        dst_img(i) = (1 - ssim(X, Y))*100;
        energy_saving(i) = ((pwrX - pwrY)/pwrX)*100;

    end
mean(energy_saving)
cd (rootFolder);
%Average for dstMax 1%  is 6.9954%   saving, max distance 0.99%.
%Average for dstMax 5%  is 16.6276%  saving, max distance 4.99%.
%Average for dstMax 10% is 23.5410%  saving, max distance 9.99%.
%% Reset environment.
clc
clear
%%