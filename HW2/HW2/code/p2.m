clc; clear;
f = imread("..\figure\PET-scan.tif");

% zeropadding
[r, c] = size(f);
flog = log(double(f) + 1);
f_p = padarray(flog, [r, c], "replicate", "post");

%fft
F = fft2(f_p);
F = fftshift(F);
%generate H
D = zeros(2*r, 2*c);
D2 = zeros(2*r, 2*c);
H = zeros(2*r, 2*c);

D0 = 30;
gl = 0.8;
gh = 3;
c0 = 4;
for u = 1:(2*r)
    for v = 1:(2*c)
        D2(u, v) = ((u-r)^2 + (v-c)^2);
        H(u, v) = (gh-gl) * (1 - exp(-c0*D2(u, v)/(D0^2))) + gl;
    end
end

G = H .* F;
G = ifftshift(G);
g_p = real(ifft2(G));
g_p = exp(g_p);
g = g_p((1:r), (1:c));
g = uint8(g);
figure(1)
imshow(H)
title('transfer function H')
figure(2)
imshowpair(f, g, 'montage')
title('original(left)  result(right)')

%% calculate varience in the assigned area
box = g((500:1100), (90:180));
box_norm = normalize(double(box), 'range');
var(box_norm, 0, "all")