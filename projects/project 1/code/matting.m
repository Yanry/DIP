clc; clear;
fg_maskbg = imread("../processed_images/fg_maskbg_nod.png");
[object_ind, cmap] = imread("../images/object.png");
object = ind2rgb(object_ind, cmap);
object = object(:, 750:1500, :);
[r, c] = size(object(:,:,1));

for i = 1:r
    for j = 1:c
        if (fg_maskbg(i, j) ~= 1)
            object(i, j, :) = object(i, j, :);
        else
            object(i, j, :) = 0;
        end
    end
end
imwrite(object, "../processed_images/object_nod.png")

n = 3;
for i = 1:n
    fg_maskbg = my_delitation(fg_maskbg);
end

for i = 1:r
    for j = 1:c
        if (fg_maskbg(i, j) ~= 1)
            object(i, j, :) = object(i, j, :);
        else
            object(i, j, :) = 0;
        end
    end
end

imshow(object)
imwrite(object, "../processed_images/object.png")
imwrite(fg_maskbg, "../processed_images/fg_maskbg.png")

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
    %bg_sobelx = uint8(bg_sobelx);
    
    sobel_y = [-1 0 1; -2 0 2; -1 0 1];
    bg_sobely = my_conv(bg, sobel_y);
    %bg_sobely = uint8(bg_sobely);
    
    bg_sobel = 0.5*bg_sobelx + 0.5*bg_sobely;
    %bg_sobel = bg_sobely;
end
%% delitation
function [img_out] = my_delitation(img)
    conn = [0 1 0; 1 1 1; 0 1 0];  
    img_out = img;
    img_conv = my_conv(img, conn);
    [r, c] = size(img);
    for i = 1:r
        for j =1:c
            if (img_conv(i, j) > 0)
                img_out(i, j) = 1;
            else
                img_out(i, j) = 0;
            end
        end
    end
end

%% imfill
function [img_out, n, img_out_fill] = my_imfillbg(img)
    %img = imbinarize(img);
    img_out = ~img;
    img_out_fill = zeros(size(img));
    [r, c] = size(img);
    img_out_fill(1, 1) = 1;
    img_out_fill(1, c) = 1;
    img_out_fill(r, 1) = 1;
    img_out_fill(r, c) = 1;
    img_out_fill = imbinarize(img_out_fill);
    n = 0;
    while (any(any(img_out_fill ~= img_out)))
        n = n + 1;
        img_out = img_out_fill;
        img_out_fill = my_delitation(img_out) & ~img;
        % if (n > 100) 
        %     break;
        % end
    end
end

