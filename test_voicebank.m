close all;
clear;

A=128;%frame number of one sample
nfft=512;%The length of one frame
dt=512;%Frequency bins
ov=0.75;%Overlap ratio
currentFolder = pwd;%Get root directory path
K=824;%Number of test audio
FS=16000;%Sampling rate
print=zeros(A,nfft/2);%Voiceprint region tag matrix
background=zeros(A,nfft/2);%Non-Voiceprint region tag matrix

%proposed_large
  load([currentFolder,'\proposed_large\','result128_256_bankln_VS.mat']);
  load([currentFolder,'\proposed_large\','result128_256_bankln_printSE.mat']);
  load([currentFolder,'\proposed_large\','result128_256_bankln_backgroundSE.mat']);
  load([currentFolder,'\proposed_large\','result128_256_bankln_printSE_1.mat']);
  load([currentFolder,'\proposed_large\','result128_256_bankln_backgroundSE_1.mat']);
%proposed_base
%   load([currentFolder,'\proposed_base\','result128_256_bankln_VSweak.mat']);
%   load([currentFolder,'\proposed_base\','result128_256_bankln_weakprint.mat']);
%   load([currentFolder,'\proposed_base\','result128_256_bankln_weakbackground.mat']);
%   load([currentFolder,'\proposed_base\','result128_256_bankln_weakprint_all.mat']);
%   load([currentFolder,'\proposed_base\','result128_256_bankln_weakbackground_all.mat']);
%%
label=0;
sump=0;
sumSNR=0;
sumsig=0;
sumbak=0;
sumovl=0;
%%
for k=1:K
[mic,fs]=audioread([currentFolder,'\noisy_testset_wav\',num2str(0+k),'.wav']);
x1=downsample(mic,fs/FS).';%Downsampling to 16000Hz
[mic,~]=audioread([currentFolder,'\clean_testset_wav\',num2str(0+k),'.wav']);
s1=downsample(mic,fs/FS).';%Downsampling to 16000Hz
[fxn]=STFTN(dt,ov,nfft,x1);
[fsn]=STFTN(dt,ov,nfft,s1);
ang=angle(fxn(:,1:nfft));
M=fix(2*size(fxn,1)/A)-1;
Output1=zeros((M+1)*A/2,nfft,M);
Output2=zeros((M+1)*A/2,nfft,M);
Output3=zeros((M+1)*A/2,nfft,M);

for m=1:M
fx1=abs(fxn(1+A*(m-1)/2:(m+1)*A/2,1:nfft));    
fx=log(fx1+ones(A,nfft));   
out=mat2gray(fx(:,1:nfft/2));
imwrite(out(:,1:nfft/2), [currentFolder,'\ffragmentnoise\',num2str(1),'.tif']);
fraimds = imageDatastore([currentFolder,'\ffragmentnoise'], ...
    'IncludeSubfolders',true,'FileExtensions','.tif', ....
    'LabelSource','foldernames');
ypred1 = predict(trainedNetwork_1,fraimds);
tagmetrix=ypred1(:,:,:,1);
        for i=1:A
            for j=1:nfft/2
                if tagmetrix(i,j)>=40
                   print(i,j)=1;
                   background(i,j)=0;
                else
                   print(i,j)=0;
                   background(i,j)=1;
                end
            end
        end     
[~,xmax,xmin] = ImageNormalize(fx(:,1:nfft/2));
out=mat2gray(fx(:,1:nfft/2));
imwrite(out(:,1:nfft/2).*print, [currentFolder,'\ffragmentnoise\',num2str(1),'.tif']);
fraimds = imageDatastore([currentFolder,'\ffragmentnoise'], ...
    'IncludeSubfolders',true,'FileExtensions','.tif', ....
    'LabelSource','foldernames');
ypred2 = predict(trainedNetwork_2,fraimds);
Output2= ImageDeNormalize(ypred2,xmax,xmin);
imwrite(out(:,1:nfft/2).*background, [currentFolder,'\ffragmentnoise\',num2str(1),'.tif']);
fraimds = imageDatastore([currentFolder,'\ffragmentnoise'], ...
    'IncludeSubfolders',true,'FileExtensions','.tif', ....
    'LabelSource','foldernames');
ypred3 = predict(trainedNetwork_3,fraimds);
Output3= ImageDeNormalize(ypred3,xmax,xmin);
Output6=Output2.*print+Output3.*background;
imwrite(out(:,1:nfft/2), [currentFolder,'\ffragmentnoise\',num2str(1),'.tif']);
fraimds = imageDatastore([currentFolder,'\ffragmentnoise'], ...
    'IncludeSubfolders',true,'FileExtensions','.tif', ....
    'LabelSource','foldernames');
ypred4 = predict(trainedNetwork_4,fraimds);
Output4= ImageDeNormalize(ypred4,xmax,xmin);
imwrite(out(:,1:nfft/2), [currentFolder,'\ffragmentnoise\',num2str(1),'.tif']);
fraimds = imageDatastore([currentFolder,'\ffragmentnoise'], ...
    'IncludeSubfolders',true,'FileExtensions','.tif', ....
    'LabelSource','foldernames');
ypred5 = predict(trainedNetwork_5,fraimds);
Output5= ImageDeNormalize(ypred5,xmax,xmin);
Output7=Output4.*print+Output5.*background;
Output8=0.5*Output6+0.5*Output7;
ypred=[Output8 Output8];
ypred(:,nfft/2+2:nfft)=fliplr(Output8(:,2:nfft/2));
ypred(:,nfft/2+1)=fx(:,nfft/2+1);
for i=1:size(ypred,1)
    for j=1:size(ypred,2)
        if ypred(i,j)<0
            ypred(i,j)=0;
        end
    end
end
Output1(1+A*(m-1)/2:(m+1)*A/2,:,m) = ypred;
end
out=zeros((M+1)*A/2,nfft);
for n=1:M
    out=out+Output1(:,:,n);
end
    out(1+A/2:M*A/2,:)=0.5*out(1+A/2:M*A/2,:);
y_ang=ang(1:(M+1)*A/2,:);
%%
Output=exp(out)-ones((M+1)*A/2,nfft);
    for i=1:size(Output,1)
    for j=1:size(Output,2)
        if Output(i,j)<0
            Output(i,j)=0;
        end
    end
    end
tfy=Output.*cos(y_ang)+1i*Output.*sin(y_ang);
[y]=recover(dt,ov,tfy,size(tfy,1));
audiowrite([currentFolder,'\MOS_PESQ\swav\',num2str(0+k),'.wav'],s1(1:size(y,2)),FS);
audiowrite([currentFolder,'\MOS_PESQ\ywav\',num2str(0+k),'.wav'],y,FS);
%Performance metrics calculation
[segSNR,Csig,Cbak,Covl,p1]= composite([currentFolder,'\MOS_PESQ\swav\',num2str(0+k),'.wav'], [currentFolder,'\MOS_PESQ\ywav\',num2str(0+k),'.wav'],k);
if Csig<100
sump=sump+p1;
sumSNR=sumSNR+segSNR;
sumsig=sumsig+Csig;
sumbak=sumbak+Cbak;
sumovl=sumovl+Covl;
label=label+1;
end
end
avpesq=sump/label;
avSNR=sumSNR/label;
avCsig=sumsig/label;
avCbak=sumbak/label;
avCovl=sumovl/label;
fprintf('\n avpesq=%f   avCsig=%f   avCbak=%f   avCovl=%f\n',avpesq,avCsig,avCbak,avCovl);