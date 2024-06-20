function OutImg = ImageDeNormalize(InImg,xmax,xmin)
ymax=255*ones(size(InImg,1),size(InImg,2));
ymin=zeros(size(InImg,1),size(InImg,2));
OutImg = (InImg-ymin)./ymax.*(xmax*ones(size(InImg,1),size(InImg,2))-xmin*ones(size(InImg,1),size(InImg,2)))+xmin*ones(size(InImg,1),size(InImg,2));
end