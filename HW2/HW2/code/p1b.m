clc; clear;
f = imread("..\figure\figure1.tif");

% zeropadding
[r, c] = size(f);
f_p = padarray(f, [r, c], "replicate", "post");

%fft
F = fft2(f_p);
F = fftshift(F);
%generate H
D = zeros(2*r, 2*c);
D2 = zeros(2*r, 2*c);
H = zeros(2*r, 2*c);
D0 = 100;
for u = 1:(2*r)
    for v = 1:(2*c)
        D2(u, v) = ((u-r)^2 + (v-c)^2);
        H(u, v) = 1 - exp(-D2(u, v)/(2*(D0^2)));
    end
end

G = H .* F;
G = ifftshift(G);
g_p = real(ifft2(G));
g = g_p((1:r), (1:c));
g = uint8(rescale(uint8(g), 0, 255));
figure(1)
imshow(H)
title('transfer function H')
figure(2)
imshow(g)
title('result')
