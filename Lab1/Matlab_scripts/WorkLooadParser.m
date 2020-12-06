function [active_vector, idle_vector] = WorkLooadParser(fileName, format)
    fileID = fopen(fileName, 'r');
    if fileID == -1
        error('Cannot open %s in reading mode', fileName);
        active_vector = -1;
        idle_vector   = -1;
        return;
    end 
    %format = '  %d  %d  \n';
    wl = fscanf (fileID, format, [2 Inf])';
    num_sample = length(wl);
    %Create idle vector and active vector re-shuffling R_vector.
    idle_vector   = zeros(1, num_sample);
    active_vector = zeros(1, num_sample);
    
    active_vector(1) = wl(1,1);
    idle_vector(1)   = wl(1, 2) - wl (1, 1);
    for i = 2:num_sample
        idle_vector(i)   = wl(i, 2) - wl (i, 1);
        active_vector(i) = wl(i, 1) - wl (i-1, 2);
    end
    fclose(fileID);
end