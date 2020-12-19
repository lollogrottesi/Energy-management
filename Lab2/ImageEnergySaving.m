%% Algorithm part 1.
dstThreshold = 1; % 1%, 5%, 10%.
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
    %i=i+1;
end

cd (rootFolder);
energy_saving = zeros(length(imgLst), 1);
dst_img = zeros(length(imgLst), 1);
%%
    for i = 1:length(imgLst)
        cd (dataFolder);
        X = imread(imgLst(i,:));
        cd (rootFolder);
        %Start energy reduction algorithm.
        if length(size(X)) == 2 %Gray images algorithm.
            X = cat(3, X, X, X);%Concatenate gray image for 3 times (R, G, B).
            Y = X; 
            pwrY_init = ImgPwr (Y);
            %Brightness optimization.
            Y_tmp = BrightnessScaling(Y, dstThreshold);%Reduce dstThreshold% of brightness.
            dist = (1 - ssim(Y, Y_tmp))*100;
            pwrTmp = ImgPwr (Y_tmp);
            if dist <= dstThreshold && pwrTmp < pwrY_init  %If possible keep transformation.
                Y = Y_tmp;
            end  
            
            %Histogram equalization.
            Y_tmp = histeq(Y);
            dist = (1 - ssim(Y, Y_tmp))*100;
            pwrTmp = ImgPwr (Y_tmp);
            if dist <= dstThreshold && pwrTmp < pwrY_init %If possible keep transformation.
                Y = Y_tmp;
            end

            %Power / Distance exctraction.
            pwrX = ImgPwr (X);
            pwrY = ImgPwr (Y);
            dst_img(i) = (1 - ssim(X, Y))*100;
            energy_saving(i) = ((pwrX - pwrY)/pwrX)*100;
            
        else %RGB images algorithm.
            
            %Start transformation algorithm for RGB.
            Y = X;
            pwrY_init = ImgPwr (Y);
            %Exctract color features.
            [avgR, avgG, avgB] = colorAvg(Y);
            max_R_G = max(avgR, avgG); 

            %Brightness optimization.
            Y_tmp = BrightnessScaling(Y, dstThreshold);%Reduce dstThreshold% of brightness.
            dist = (1 - ssim(Y, Y_tmp))*100;
            pwrTmp = ImgPwr (Y_tmp);
            if dist <= dstThreshold && pwrTmp < pwrY_init  %If possible keep transformation.
                Y = Y_tmp;
            end

            %Hungry blue optimization.
            if avgB > max_R_G %Check if Blue average is greater than both Red and Green.
                k_blue = (double(avgB - max_R_G)/double(avgB))*100;%Percentage distance.
                Y_tmp = hungryBlue(Y, k_blue);                     %Reduce k% of blue.
                dist = (1 - ssim(Y, Y_tmp))*100;
                pwrTmp = ImgPwr (Y_tmp);
                if dist <= dstThreshold && pwrTmp < pwrY_init %If possible keep transformation.
                    Y = Y_tmp;
                end
            end

            %Histogram equalization.
            Y_tmp = histeq(Y);
            dist = (1 - ssim(Y, Y_tmp))*100;
            pwrTmp = ImgPwr (Y_tmp);
            if dist <= dstThreshold && pwrTmp < pwrY_init %If possible keep transformation.
                Y = Y_tmp;
            end

            %Power / Distance exctraction.
            pwrX = ImgPwr (X);
            pwrY = ImgPwr (Y);
            dst_img(i) = (1 - ssim(X, Y))*100;
            energy_saving(i) = ((pwrX - pwrY)/pwrX)*100;
        end 
    end
mean(energy_saving)
cd (rootFolder);
%%
clc
clear
cd (rootFolder);
%%