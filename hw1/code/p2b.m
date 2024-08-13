clc; clear;
moon = imread("..\image\moon.jpg");

kernel = [0 1 0; 1 -4 1; 0 1 0];
moon_out = uint8(my_conv(double(moon), kernel));
moon_out = uint8(rescale(moon_out, 0, 255));


moon_sharpen = moon - moon_out;
moon_sharpen = uint8(rescale(moon_sharpen, 0, 255));
imshowpair(moon_out, moon_sharpen, 'montage')
title('laplacian on both direction')

%% my conv function
function [img_out] = my_conv(img, kernel)
    [r, c] = size(img);
    [r_k, c_k] = size(kernel);
    img_out = zeros(r, c);
    img_pad = padarray(img, [(r_k-1)/2, (c_k-1)/2], 'replicate', 'both');
    kernel_rot = rot90(kernel, 2);

    for i= 1:r
        for j = 1:c
            tmp_mat = img_pad(i:(i+r_k-1), j:(j+c_k-1)) .* kernel_rot;
            img_out(i, j) = sum(tmp_mat, 'all');
        end
    end
end