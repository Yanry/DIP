clc; clear;
g = imread("..\figure\blurred.tif");
[r, c] = size(g);

K = 0.001;
N = 640;
d = 15;
theta = -55;
L = N/d;
PSF = fspecial('motion', L, theta);
H = psf2otf(PSF, [N, N]);

G = fft2(g);
F = zeros(r, c);
for i = 1:r
    for j = 1:c
        F(i,j) = 1/H(i,j) * (H(i,j)^2)/((H(i,j))^2 + K) * G(i,j);
    end
end

f = ifft2(F);
f = uint8(f);
imshowpair(g, f, 'montage');

