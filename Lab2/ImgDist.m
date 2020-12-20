%Compute power of image.
%Is assumed that Img input is RGB format.
%By construction Imgi and Imgj have the same legths.
function distortion = ImgDist (Imgi, Imgj)
    height = length(Imgi(:, 1, 1));
    width  = length(Imgi(1, :, 1));
    LabImgi = rgb2lab(Imgi);
    LabImgj = rgb2lab(Imgj);
    Li_sum = 0;
    Lj_sum = 0;
    ai_sum = 0;
    aj_sum = 0;
    bi_sum = 0;
    bj_sum = 0;
    for i = 1:height
        for j = 1:width
            Li_sum = double(Li_sum + LabImgi(i, j, 1));
            Lj_sum = double(Lj_sum + LabImgj(i, j, 1));
            ai_sum = double(ai_sum + LabImgi(i, j, 2));
            aj_sum = double(aj_sum + LabImgj(i, j, 2));
            bi_sum = double(bi_sum + LabImgi(i, j, 3));
            bj_sum = double(bj_sum + LabImgj(i, j, 3));
        end
    end 

    distortion = sqrt((Li_sum - Lj_sum)^2 + (ai_sum - aj_sum)^2 + (bi_sum - bj_sum)^2);
    max_dst = width*height*374.2325;
    distortion = (distortion/max_dst)*100;
end