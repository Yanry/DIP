clc; clear;
flower = imread('../figure/flower.tif');
dT = 5;
T = 0.1;
image = rgb2gray(flower);
[image_pro, T_pro] = basic_threshold(image, T, dT);
imshow(image_pro)
%% function threshold
function [image_pro, T_pro] = basic_threshold(image, T, dT)
    [r, c] = size(image);
    G1 = [];
    G2 = [];
    T_pro = dT + T + 50;
    while (abs(T_pro-T) > dT)
        for i=1:r
            for j=1:c
                if (image(i, j) > T)
                    G1 = [G1, image(i,j)];
                else
                    G2 = [G2, image(i,j)];
                end
            end
        end
        if (isempty(G1) == 0)
            m1 = mean(G1);
        else
            m1 = 0;
        end
        if (isempty(G2) == 0)
            m2 = mean(G2);
        else
            m2 = 0;
        end
        T_pro = T;
        T = 1/2*(m1 + m2);
    end
    image_pro = zeros(r, c);
    T_pro = T;
    for i=1:r
        for j=1:c
            if (image(i, j) > T_pro)
                image_pro(i, j) = 1;
            else
                image_pro(i, j) = 0;
            end
        end
    end
end
