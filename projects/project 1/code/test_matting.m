clc; clear;
r = 50;
c = 50;
ob_outline = zeros([r, c]);
for i = 1:r
    for j = 1:c
        if (i>20 && i<40 && j>20 &&j<40)
            ob_outline(i, j) = 1;
        end
        if (i>25 && i<35 && j>25 &&j<35)
            ob_outline(i, j) = 0;
        end
    end
end
ob_outline = imbinarize(ob_outline);
[ob_outline_1, n, outline_1] = my_imfillbg(ob_outline);
ob_outline = ob_outline_1 - ob_outline;
% 
% for i = 1:r
%     for j = 1:c
%         if (ob_outline(i, j) ~= 1)
%             object(i, j, :) = object(i, j, :);
%         else
%             object(i, j, :) = 0;
%         end
%     end
% end
imshowpair(ob_outline_1, outline_1, "montage")
%imshow(ob_outline)
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
    img_out_fill(1, 1) = 1;
    img_out_fill = imbinarize(img_out_fill);
    n = 0;
    while (any(any(img_out_fill ~= img_out)))
        n = n + 1;
        img_out = img_out_fill;
        img_out_fill = my_delitation(img_out) & ~img;
        % if (n > 1) 
        %     break;
        % end
    end
end

