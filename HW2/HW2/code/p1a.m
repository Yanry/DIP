clc; clear;
figure = imread("..\figure\figure1.tif");

sobel_x = [-1 -2 -1; 0 0 0; 1 2 1];
figure_sobelx = my_conv(figure, sobel_x);
figure_sobelx = uint8(figure_sobelx);

sobel_y = [-1 0 1; -2 0 2; -1 0 1];
figure_sobely = my_conv(figure, sobel_y);
figure_sobely = uint8(figure_sobely);

figure_sobel = 0.5*figure_sobelx + 0.5*figure_sobely;

figure(1)
subplot(1,3,1)
imshow(figure_sobelx)
title('sobel on x')
subplot(1,3,2)
imshow(figure_sobely)
title('sobel on y')
subplot(1,3,3)
imshow(figure_sobel)
title('sobel combination')
%% my conv function
function [img_out] = my_conv(img, kernel)
    img = double(img);
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
