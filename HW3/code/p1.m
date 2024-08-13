clc; clear;
load('../sinogram.mat');
[width, angle] = size(sinogram);
% fft
sin_fft = fft(sinogram, width);
% Hamming
c = 0.54;
filtered = zeros(width, angle);
h = zeros(width, 1);
for w = 1:width
    h(w) = c+ (c-1)*cos(2*pi*(w-1)/width+pi/2);
end
filter = [0:(width/2-1), width/2:-1:0]'/width;
hamfilter = h .*filter;
for i = 1:angle
    filtered(:, i) = sin_fft(:, i) .* hamfilter;
end
%ifft
sin_ifft = real(ifft(filtered));
%project
image = zeros(width);
for i = 1:angle
    rad = deg2rad(i) + pi/2;
    for x = 1:width
        for y = 1:width
            t = round((x-width/2)*cos(rad) - (y-width/2)*sin(rad));
            if t>-width/2 && t<width/2
                image(x,y)=image(x,y)+sin_ifft(round(t+width/2),i);
            end
            t_temp = (x-width/2) * cos(rad) - (y-width/2) * sin(rad) + width/2  ;
            t = round(t_temp) ;
            if t>0 && t<=width
                image(x,y)=image(x,y)+sin_ifft(t,i);
            end
        end
    end
end
image = (image*pi)/180;
% image = iradon(sinogram, 1:(angle), width, 'nearest', 'Hamming');
imshow(image)