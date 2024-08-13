clc; clear;
f = imread("..\figure\PeppersRGB.jpg");
f = normalize(f, 'range');

[r, c, ch] = size(f);
%% rgb to hsi
H = zeros(r, c);
S = zeros(r, c);
I = zeros(r, c);
for i = 1:r
    for j = 1:c
        fr = f(i,j,1);
        fg = f(i,j,2);
        fb = f(i,j,3);
        %calculate H
        t_t = 0.5*((fr-fg) + (fr-fb));
        t_b = sqrt((fr-fg)^2 + (fr-fb)*(fg-fb));
        theta = acos(t_t/(t_b+eps));
        if (fb <= fg)
            H(i, j) = theta;
        else
            H(i, j) = 2*pi - theta;
        end
        H(i, j) = H(i, j) / (2*pi);

        %calculate S
        minrgb = min(min(fr, fg), fb);
        S(i, j) = 1 - 3/(fr+fg+fb+eps)*minrgb;

        %calculate I
        I(i, j) = (fr+fg+fb)/3;
    end
end
HSI = zeros(r, c, ch);
HSI(:,:,1) = H;
HSI(:,:,2) = S;
HSI(:,:,3) = I;
figure(1)
imshow(HSI)
%% hsi to rgb
H1 = H * 2*pi;

R = zeros(r, c);
G = zeros(r, c);
B = zeros(r, c);

for x = 1:r
    for y = 1:c
        if (H1(x,y)>=0 && H1(x,y)<(2/3*pi))
            temp1 = I(x,y) * (1-S(x,y));
            temp2 = I(x,y) * (1+S(x,y)*cos(H1(x,y))/(cos(pi/3-H1(x,y))+eps));
            B(x,y) = temp1;
            R(x,y) = temp2;
            G(x,y) = 3*I(x,y) - R(x,y) - B(x,y);
        elseif (H1(x,y)>=(2/3*pi) && H1(x,y)<(4/3*pi))
            H1(x,y) = H1(x,y) - 2/3*pi;
            temp1 = I(x,y) * (1-S(x,y));
            temp2 = I(x,y) * (1+S(x,y)*cos(H1(x,y))/(cos(pi/3-H1(x,y))+eps));
            R(x,y) = temp1;
            G(x,y) = temp2;
            B(x,y) = 3*I(x,y) - R(x,y) - G(x,y);
        else
            H1(x,y) = H1(x,y) - 4/3*pi;
            temp1 = I(x,y) * (1-S(x,y));
            temp2 = I(x,y) * (1+S(x,y)*cos(H1(x,y))/(cos(pi/3-H1(x,y))+eps));
            G(x,y) = temp1;
            B(x,y) = temp2;
            R(x,y) = 3*I(x,y) - G(x,y) - B(x,y);
        end
    end
end

RGB = zeros(r, c, ch);
RGB(:,:,1) = R;
RGB(:,:,2) = G;
RGB(:,:,3) = B;
RGB = RGB * 255;
RGB = uint8(RGB);
figure(2)
imshow(RGB)
