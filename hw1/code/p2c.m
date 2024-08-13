clc; clear;
moon = imread("..\image\moon.jpg");
[r, c] = size(moon);
% subplot(1,2,1)
% imshow(moon)
% title('original image')

k = 0.5;
moon_mean = sum(moon, "all") / (r*c);
moon_mask = moon - moon_mean;
moon_out = moon + k*moon_mask;
moon_out = uint8(rescale(moon_out, 0, 255));
%subplot(1,2,2)
imshow(moon_out)
title('unsharpen mask image')