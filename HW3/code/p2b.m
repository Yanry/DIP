clc; clear;
nebula = imread('../figure/nebula.jpg');
image = rgb2gray(nebula);
image_pro8 = splitmerge(image, 8, @judge);
figure(1)
imshow(image_pro8)
title('four-quadrantregion size limit is 8*8')
image_pro4 = splitmerge(image, 4, @judge);
figure(2)
imshow(image_pro4)
title('four-quadrantregion size limit is 4*4')
%% split
function en=split(image,mindim,func)
    K=size(image,3);
    en(1:K)=false;
    for i=1:K
        region=image(:,:,i);
        if (size(region,1)<=mindim)
            en(i)=false;
            continue
        end
        judge=feval(func,region);
        if (judge == true)
            en(i)=true;
        end
    end
end

%% judge
function flag=judge(region)
std=std2(region);
m=mean2(region);
flag=(std>0.7)&(m>0)&(m<170);
end
%% splitmerge
function image_pro=splitmerge(image,mindim,func)
 S=2^nextpow2(max(size(image)));
 [r,c]=size(image);
 image=padarray(image,[S-r,S-c],'post');
 block=qtdecomp(image,@split,mindim,func);
 mat=full(max(block(:)));
 image_pro=zeros(size(image));
 point=zeros(size(image));
 
 for k=1:mat
     [vals,m,n]=qtgetblk(image,block,k);

     if (isempty(vals) == 0)
         for i=1:length(m)
             left = m(i);
             down = n(i);
             right = left+k-1;
             up = down+k-1;
             region=image(left:right,down:up);
             judge=feval(func,region);
             if (judge == true)
                 image_pro(left:right,down:up)=1;
                 point(left,down)=1;
             end
         end
     end
 end
 
 image_pro=bwlabel(imreconstruct(point,image_pro));
 image_pro=image_pro(1:r,1:c);
end
