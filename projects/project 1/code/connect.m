clc; clear;
fg_maskbg = imread("../processed_images/fg_maskbg.png");
object = imread("../processed_images/object.png");
bg = imread("../processed_images/bg_expanded.png");
[r_b, c_b] = size(bg(:,:,1));

object = imresize(object, 0.39);
fg_maskbg = imresize(fg_maskbg, 0.39);
[r_f, c_f] = size(object(:,:,1));
object = object((r_f+1-415):r_f, :, :);
fg_maskbg = fg_maskbg((r_f+1-415):r_f, :, :);
[r_f, c_f] = size(object(:,:,1));

img_out = bg;

start = 160;
for i = 1:r_f
    for j = 1:c_f
        if (fg_maskbg(i, j) ~= 1)
            img_out(i, start+j, :) = object(i, j, :);
        else
            img_out(i, start+j, :) = img_out(i, start+j, :);
        end
    end
end

imshow(img_out)
imwrite(img_out, "../processed_images/result.png")
