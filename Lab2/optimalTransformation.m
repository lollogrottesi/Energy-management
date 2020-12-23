function [optimal_img, optimal_pwr, optimal_dst] = optimalTransformation(img_RGB, vdd_target, vdd_original, mode)
    pwr_org = ImgPwr(img_RGB); 
    gl = -((1 - vdd_original/vdd_target)/2 * vdd_target/vdd_original);
    gu = (vdd_target/vdd_original) + gl;
    %Apply all 3 transformations BrightnessCompensation,
    %ContrastEnhancement, both.
    tmp_DVS_comp = LCDBrightnessCompensation (img_RGB,  (vdd_original/vdd_target - 1)/2);
    tmp_DVS_en   = LCDContrastEnhancement (img_RGB, vdd_target/vdd_original);
    tmp_DVS_cun  = LCDCuncurrentBrightnessContrast (img_RGB, gl, gu);
    %Compute Icell for the three cases.
    tmp_DVS_cell_comp = Icell(tmp_DVS_comp, vdd_target);
    tmp_DVS_cell_en   = Icell(tmp_DVS_en, vdd_target);
    tmp_DVS_cell_cun  = Icell(tmp_DVS_cun, vdd_target);
    %Compute panel power consumptions.
    tmp_DVS_pwr_comp = panelPower(tmp_DVS_cell_comp, vdd_target);
    tmp_DVS_pwr_en   = panelPower(tmp_DVS_cell_en, vdd_target);
    tmp_DVS_pwr_cun  = panelPower(tmp_DVS_cell_cun, vdd_target);
    %Compute (1 - power_saving)*100.
    comp_pwr_metric = 100 - ((pwr_org - tmp_DVS_pwr_comp)/pwr_org)*100; 
    en_pwr_metric   = 100 - ((pwr_org - tmp_DVS_pwr_en)/pwr_org)*100; 
    cun_pwr_metric  = 100 - ((pwr_org - tmp_DVS_pwr_cun)/pwr_org)*100; 
    %Compute distances.
    tmp_img_DVS_comp = uint8(displayed_image(tmp_DVS_cell_comp, vdd_target, mode));
    dst_comp = (1 - ssim(img_RGB, tmp_img_DVS_comp))*100;
    tmp_img_DVS_en = uint8(displayed_image(tmp_DVS_cell_comp, vdd_target, mode));
    dst_en = (1 - ssim(img_RGB, tmp_img_DVS_en))*100;
    tmp_img_DVS_cun = uint8(displayed_image(tmp_DVS_cell_comp, vdd_target, mode));
    dst_cun = (1 - ssim(img_RGB, tmp_img_DVS_cun))*100;
    %Compute distance between distortion and (1 - power_saving)*100 both
    %in range 0-100. 
    weight_comp = sqrt(double(comp_pwr_metric)^2 + double(dst_comp)^2);
    weight_en   = sqrt(double(en_pwr_metric)^2 + double(dst_en)^2);
    weight_cun  = sqrt(double(cun_pwr_metric)^2 + double(dst_cun)^2);
    %Take the minimum weght trasformation.
    min_weight = min([weight_comp weight_en weight_cun]);
    if min_weight == weight_comp
        optimal_img = tmp_img_DVS_comp;
        optimal_pwr = tmp_DVS_pwr_comp;
        optimal_dst = dst_comp;
    elseif min_weight == weight_en
        optimal_img = tmp_img_DVS_en;
        optimal_pwr = tmp_DVS_pwr_en;
        optimal_dst = dst_en;
    else
        optimal_img = tmp_img_DVS_cun;
        optimal_pwr = tmp_DVS_pwr_cun;
        optimal_dst = dst_cun;
    end
end