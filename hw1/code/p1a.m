clc; clear;
grain = imread("..\image\grain.tif");
L = 256;
h = zeros(1, L);
num = 1:L;
[r, c] = size(grain);

for i = 1:r
    for j = 1:c
        tmp = grain(i, j);
        h(tmp) = h(tmp) + 1;
    end
end

subplot(2,1,1);
bar(num(1:max(max(grain))), h(1:max(max(grain)))); % 手动实现histogram图像
title("histogram created by myself");
subplot(2,1,2);
h1 = histogram(grain); % matlab自带函数对比
title("histogram created by matlab function");
