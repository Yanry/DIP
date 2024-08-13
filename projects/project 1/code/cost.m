clc; clear;
background = imread("../images/background.png");
bg = rgb2gray(background);
[r, c] = size(bg);
range = 180:300;
bg_range = bg(:, range, :);
bg_processed = background;

% find n min cost path
n = 20;
bg_paths = find_seams(bg_range, n) + range(1)-1;
for m = 1:n
    for i = 1:r
        bg_processed(i, bg_paths(i, m), 1) = 255;
        bg_processed(i, bg_paths(i, m), 2) = 0;
        bg_processed(i, bg_paths(i, m), 3) = 0;
    end
end

imshow(bg_processed);
imwrite(bg_processed, "../processed_images/bg_seam.png")
%% calculate cost and record path
function [cost, path] = my_cost(energy) 
    [r, c] = size(energy);
    cost = double(energy);
    path = zeros(r, c);

    for i = 1:(r-1)
        for j = 1:c
            if (j == 1)
                [min_energy, idx] = min([cost(i, j), cost(i, j+1)]);
                path(i+1, j) = idx - 1;
            elseif (j == c)
                [min_energy, idx] = min([cost(i, j-1), cost(i, j)]);
                path(i+1, j) = idx - 2;
            else
                [min_energy, idx] = min([cost(i, j-1), cost(i, j), cost(i, j+1)]);
                path(i+1, j) = idx - 2;
            end
            cost(i+1, j) = cost(i+1, j) + min_energy;
        end
    end
    cost = cost(r, :);
end

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
    n_g = 5;
    for i = 1:n_g
        bg = my_gaussian(bg);
    end
    sobel_x = [-1 -2 -1; 0 0 0; 1 2 1];
    bg_sobelx = my_conv(bg, sobel_x);
    bg_sobelx = uint8(abs(bg_sobelx));
    
    sobel_y = [-1 0 1; -2 0 2; -1 0 1];
    bg_sobely = my_conv(bg, sobel_y);
    bg_sobely = uint8(abs(bg_sobely));
    
    bg_sobel = 0.5*bg_sobelx + 0.5*bg_sobely;
    %bg_sobel = bg_sobely;
end

%% find n seams
function [paths] = find_seams(bg, n)
    [r, c] = size(bg);
    paths = zeros(r, n);
    bg_processed = bg;
    for m = 1:n
        bg_energy = my_sobel(bg_processed);
        [bg_cost, bg_path] = my_cost(bg_energy);
        [cost_min, cost_idx] = min(bg_cost);
        for i = r:-1:1
            bg_processed(i, 1:(cost_idx-1)) = bg_processed(i, 1:(cost_idx-1));
            bg_processed(i, cost_idx:(c-m)) = bg_processed(i, (cost_idx+1):(c-m+1));
            paths(i, m) = cost_idx;
            cost_idx = bg_path(i, cost_idx) + cost_idx;
        end
        bg_processed = bg_processed(:, 1:(c-m));
    end
end
%% gaussian
function [bg_processed] = my_gaussian(bg)
    H = [1,1,1;1,1,1;1,1,1];
    bg_processed = my_conv(bg, H)./9;
end


