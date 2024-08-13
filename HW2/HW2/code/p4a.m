clc; clear;
f = imread("..\figure\blurred.tif");
[r, c] = size(f);

f_p = zeros(r, c);
for i = 1:r
    for j = 1:c
        f_p(i,j) = double(f(i,j)) * power(-1, i+j);
    end
end

F = fft2(f_p);
F = log(abs(F));
imagesc(F);