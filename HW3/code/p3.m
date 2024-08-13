clc; clear;
image = imread('../figure/seahouse.jpg');
num_seeds=1000;

R = double(image(:,:,1));
G = double(image(:,:,2));
B = double(image(:,:,3));
compactness=10;

[labels, num_seeds]=SLIC(num_seeds,compactness,R,G,B);

%calculate mean of every super pixel
image_pro = zeros(size(image), 'like', image);
idx = label2idx(labels);
numRows = size(image,1);
numCols = size(image,2);

for labelVal = 1:length(idx)
    redIdx = idx{labelVal};
    greenIdx = idx{labelVal}+numRows*numCols;
    blueIdx = idx{labelVal}+2*numRows*numCols;
    image_pro(redIdx) = mean(image(redIdx));
    image_pro(greenIdx) = mean(image(greenIdx));
    image_pro(blueIdx) = mean(image(blueIdx));
end    

figure
imshow(image_pro)
%% SLIC
function [labels, num_seeds]=SLIC(num_seeds,compactness,R,G,B)
    [r, c]=size(R);
    total_pixel=r*c;
    step=floor(sqrt(total_pixel/num_seeds)+0.5);    
    [seeds,num_seeds]=GenerateSeeds(step,r,c,R,G,B);
    [~,labels]=SuperpixelSLIC(seeds,num_seeds,r,c,step,compactness,R,G,B);
    k=floor(r*c/(step*step));
    labels=EnforceLabelConnectivity(labels,r,c,k);
end
%% geberate seeds
function [seeds,num_seeds]=GenerateSeeds(step,r,c,R,G,B)
    seeds=zeros(1,5);
    %calculate error
    xstrips=floor(r/step);
    ystrips=floor(c/step);
    xerr=floor(r-step*xstrips);
    if xerr<0
        xstrips=xstrips-1;
        xerr=floor(r-step*xstrips);
    end
    yerr=floor(c-step*ystrips);
    if yerr<0
        ystrips=ystrips-1;
        yerr=floor(c-step*ystrips);
    end    
    xerrperstrip=xerr/xstrips;
    yerrperstrip=yerr/ystrips;
    xoff=floor(step/2);
    yoff=floor(step/2);

    %calculate number of seeds
    n=1;
    num_seeds=xstrips*ystrips;
    for x=0:xstrips-1
        xe=floor(x*xerrperstrip);
        for y=0:ystrips-1
            ye=floor(y*yerrperstrip);
            seedy=floor(y*step+yoff+ye);
            seedx=floor(x*step+xoff+xe);
            seeds(n,1)=R(seedx,seedy);
            seeds(n,2)=G(seedx,seedy);
            seeds(n,3)=B(seedx,seedy);
            seeds(n,4)=seedx;
            seeds(n,5)=seedy;
            n=n+1;
        end
    end
end
%% calculate super pixel
function [seeds,labels]=SuperpixelSLIC(seeds,num_seeds,r,c,step,compactness,R,G,B)
    %initiate    
    d=Inf(r,c);
    labels=-1*ones(r,c);
    offset=step;
    if step<8
        offset=step*1.5;
    end
    invwt=1/(step/compactness)^2;

    for itr=1:10
        for i=1:num_seeds
            x_min=seeds(i,4)-offset;
            if (x_min<1)
                x_min=1;
            end
            x_max=seeds(i,4)+offset;
            if (x_max>r)
                x_max=r;
            end
            y_min=seeds(i,5)-offset;
            if (y_min<1)
                y_min=1;
            end
            y_max=seeds(i,5)+offset;
            if (y_max>c)
                y_max=c;
            end   
            %calculate distance
            for x=x_min:x_max
                for y=y_min:y_max
                    d_color=(seeds(i,1)-R(x,y))^2+(seeds(i,2)-G(x,y))^2+(seeds(i,3)-B(x,y))^2;
                    d_space=(seeds(i,4)-x)^2+(seeds(i,5)-y)^2;
                    D=d_color+d_space*invwt;
                    if D<d(x,y)
                        d(x,y)=D;
                        labels(x,y)=i;
                    end
                end
            end
        end
    end
    %refresh seeds
    new_seeds=zeros(num_seeds,6);
    for x=1:r
        for y=1:c
            label=labels(x,y);
            new_seeds(label,1)=new_seeds(label,1)+R(x,y);
            new_seeds(label,2)=new_seeds(label,2)+G(x,y);
            new_seeds(label,3)=new_seeds(label,3)+B(x,y);
            new_seeds(label,4)=new_seeds(label,4)+x;    
            new_seeds(label,5)=new_seeds(label,5)+y;
            new_seeds(label,6)=new_seeds(label,6)+1;
        end
    end
    for i=1:num_seeds
        seeds(i,:)=new_seeds(i,1:5)/new_seeds(i,6);
    end
end
%% connect label
function [labels,numlabels]=EnforceLabelConnectivity(labels,r,c,k)
    nlabels=-1*ones(r,c);
    sz=r*c;
    supsz=floor(sz/k);
    label=1;
    adjlabel=1;
    for x=1:r
        for y=1:c
            if nlabels(x,y)<0
                nlabels(x,y)=label;
                %adjacy
                if x-1>=1 && nlabels(x-1,y)>=1
                    adjlabel=nlabels(x-1,y);
                elseif x+1<=r && nlabels(x+1,y)>=1
                    adjlabel=nlabels(x+1,y);
                elseif y-1>=1 && nlabels(x,y-1)>=1
                    adjlabel=nlabels(x,y-1);
                elseif y+1<=c && nlabels(x,y+1)>=1
                    adjlabel=nlabels(x,y+1);
                end
                count=1;
                points=[x,y];
                ps_back=[x,y];
                while ~isempty(points)
                    p=points(1,:);
                    %up
                    if (p(1)-1>=1)
                        if nlabels(p(1)-1,p(2))<0 && labels(p(1)-1,p(2))==labels(x,y)
                            points=cat(1,points,[p(1)-1,p(2)]);
                            ps_back=cat(1,ps_back,[p(1)-1,p(2)]);
                            nlabels(p(1)-1,p(2))=label;
                            count=count+1;
                        end
                    end
                    %down
                    if (p(1)+1<=r)
                        if nlabels(p(1)+1,p(2))<0 && labels(p(1)+1,p(2))==labels(x,y)
                            points=cat(1,points,[p(1)+1,p(2)]);
                            ps_back=cat(1,ps_back,[p(1)+1,p(2)]);
                            nlabels(p(1)+1,p(2))=label;
                            count=count+1;
                        end
                    end                    
                    %left
                    if (p(2)-1>=1)
                        if nlabels(p(1),p(2)-1)<0 && labels(p(1),p(2)-1)==labels(x,y)
                            points=cat(1,points,[p(1),p(2)-1]);
                            ps_back=cat(1,ps_back,[p(1),p(2)-1]);
                            nlabels(p(1),p(2)-1)=label;
                            count=count+1;
                        end
                    end
                    %right
                    if (p(2)+1<=c)
                        if nlabels(p(1),p(2)+1)<0 && labels(p(1),p(2)+1)==labels(x,y)
                            points=cat(1,points,[p(1),p(2)+1]);
                            ps_back=cat(1,ps_back,[p(1),p(2)+1]);
                            nlabels(p(1),p(2)+1)=label;
                            count=count+1;
                        end
                    end  
                    points(1,:)=[];
                end
                %merge
                if (count<=supsz/4)
                    while ~isempty(ps_back)
                        p=ps_back(1,:);
                        nlabels(p(1),p(2))=adjlabel;
                        ps_back(1,:)=[];
                    end
                    label=label-1;
                end
                label=label+1;
            end
        end
    end
    numlabels=label;
    labels=nlabels;
end
 
 
