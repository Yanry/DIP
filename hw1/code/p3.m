clc; clear;
lena = imread("..\image\lena_noisy .tif");
lena_medfil3 = median_filter(lena, 3);
lena_medfil5 = median_filter(lena, 5);
figure(1)
imshowpair(lena_medfil3, lena_medfil5, 'montage')
title('image with median filter kernel size=3(left) kernel size=5(right)')

figure(2)
lena_gaufil3 = gaussian_filter(lena, 3);
lena_gaufil7 = gaussian_filter(lena, 7);
imshowpair(lena_gaufil3, lena_gaufil7, 'montage')
title('image with gaussian filter kernel size=3(left) kernel size=7(right)')

%% median filter
function [img_out] = median_filter(img, kernel_size)
    [r, c] = size(img);
    img_out = zeros(r, c);
    img_pad = padarray(img, [(kernel_size-1)/2, (kernel_size-1)/2], 'replicate', 'both');

    for i= 1:r
        for j = 1:c
            img_out(i, j) = median(median(img_pad(i:(i+kernel_size-1), j:(j+kernel_size-1))));
        end
    end
    img_out = uint8(img_out);
end
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
%% gaussian filter
function [img_out] = gaussian_filter(img, kernel_size)
    g = zeros(kernel_size, kernel_size);
    bias = (kernel_size+1)/2;
    for i = 1:kernel_size
        for j = 1:kernel_size
            g(i, j) = exp(-((i-bias)^2+(j-bias)^2)/2);
        end
    end
    sumg = sum(g, 'all');
    g = g / sumg;
    img_out = uint8(my_conv(double(img), g));
end

