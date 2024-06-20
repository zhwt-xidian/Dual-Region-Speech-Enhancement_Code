function [OutImg,xmax,xmin] = ImageNormalize(InImg)
ymax=255*ones(size(InImg,1),size(InImg,2));
ymin=zeros(size(InImg,1),size(InImg,2));
xmax = max(max(InImg)); %Calculate the maximum value in InImg
xmin = min(min(InImg)); %Calculate the minimum value in InImg
OutImg = ((ymax-ymin).*(InImg-xmin*ones(size(InImg,1),size(InImg,2)))./(xmax*ones(size(InImg,1),size(InImg,2))-xmin*ones(size(InImg,1),size(InImg,2))) + ymin); %normalization
end