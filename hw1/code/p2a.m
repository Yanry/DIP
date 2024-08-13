clc; clear;
moon = imread("..\image\moon.jpg");

kernel_x = [1 -2 1];
moon_outx = uint8(my_conv(double(moon), kernel_x));
moon_sharpenx = uint8(rescale(moon-moon_outx, 0, 255));
figure(1)
imshowpair(moon_outx, moon_sharpenx, 'montage')
title('laplacian on x direction')

kernel_y = [1; -2; 1];
moon_outy = uint8(my_conv(double(moon), kernel_y));
moon_sharpeny = uint8(rescale(moon-moon_outy, 0, 255));
figure(2)
imshowpair(moon_outy, moon_sharpeny, 'montage')
title('laplacian on y direction')

moon_out = moon_outx + moon_outy;
moon_sharpen = uint8(rescale(moon-moon_out, 0, 255));
figure(3)
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

