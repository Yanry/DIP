clc; clear;
tire = imread("..\image\tire.tif");
L = 256;
img_out = uint8(CLAHE(tire, 41, 3, 0.02));
img_he = histeq(tire);
img_mat = adapthisteq(tire,'clipLimit', 0.02);

%% plot image
figure(1)
subplot(2,2,1)
imshow(tire)
title('original image')
subplot(2,2,2)
imshow(img_he)
title('hist equalization img')
subplot(2,2,3)
imshow(img_mat)
title('CLAHE by matlab')
subplot(2,2,4)
imshow(img_out)
title('CLAHE by myself')

%% plot histogram
figure(2)
subplot(2,1,1)
histogram(tire, 256);
title('histogram of original img')
subplot(2,1,2)
bar((1:L), hi(img_out))
title('histogram of CLAHE by myself')

%% histogram function
function [h] = hi(I)
    L = 256;
    h = zeros(1, L);
    [r, c] = size(I);
    
    for i = 1:r
        for j = 1:c
            tmp = I(i, j);
            h(tmp+1) = h(tmp+1) + 1;
        end
    end
end
%% calculate s_k function
function [s] = calculate_s(patch,limit)
    L = 256;
    [r, c] = size(patch);
    threshold = limit * r * c;
    h_patch = hi(patch);
    cut = 0;
    for n = 1:L
        if (h_patch(n) > threshold)
            cut = cut + h_patch(n) - threshold;
            h_patch(n) = threshold;
        end
    end
    add = cut / L;
    h_patch = h_patch + add;
    p_patch = h_patch / (r*c);
    s = zeros(1, L);
    s(1) = p_patch(1);
    for n = 2:L
        s(n) = s(n-1) + p_patch(n);
    end
end
%% CLAHE
function [img_out] = CLAHE(I, patch, centre, limit)
    L = 256;
    [r, c] = size(I);
    img_out = zeros(r, c);
    p2 = (patch-1) / 2;
    c2 = (centre-1) / 2;
    for i = 1:r
        x = max(1,i-p2): min(r,i+p2);
        for j = 1:c
            y = max(1,j-p2): min(c,j+p2);
            J = I(x, y);
            s = calculate_s(J, limit);
            for x_c = max(1,i-c2): min(r,i+c2)
                for y_c = max(1,j-c2): min(c,j+c2)
                    img_out(x_c, y_c) = (L-1)*s(I(x_c, y_c)+1)/s(L);
                end
            end
        end
    end
end

