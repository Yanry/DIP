clc; clear;
bg = imread("../images/background.png");
bg = rgb2gray(bg);

% sobel
bg_sobel = my_sobel(bg);

imshow(bg_sobel)
imwrite(bg_sobel, "../processed_images/bg_sobel.png")

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

%% sobel
function [bg_sobel] = my_sobel(bg)
    %bg = my_gaussian(bg);    
    sobel_x = [-1 -2 -1; 0 0 0; 1 2 1];
    bg_sobelx = my_conv(bg, sobel_x);
    bg_sobelx = uint8(abs(bg_sobelx));
    
    sobel_y = [-1 0 1; -2 0 2; -1 0 1];
    bg_sobely = my_conv(bg, sobel_y);
    bg_sobely = uint8(abs(bg_sobely));
    
    bg_sobel = 0.5*bg_sobelx + 0.5*bg_sobely;
    %bg_sobel = bg_sobely;
end
%% laplacian
function [bg_lap] = my_lap(bg)
    bg = my_gaussian(bg);    
    lap = [0 1 0; 1 -4 1; 0 1 0];
    bg_lap = my_conv(bg, lap);
end

%% gaussian
function [bg_processed] = my_gaussian(bg)
    H = [1,1,1;1,1,1;1,1,1];
    bg_processed = my_conv(bg, H)./9;
end


