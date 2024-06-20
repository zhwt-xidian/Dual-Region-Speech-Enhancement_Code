currentFolder=pwd;
K=824;
label=0;
sump=0;
sumSNR=0;
sumsig=0;
sumbak=0;
sumovl=0;
for k=1:K
[segSNR,Csig,Cbak,Covl,p1]= composite([currentFolder,'\swav\',num2str(0+k),'.wav'], [currentFolder,'\ywav\',num2str(0+k),'.wav'],k);
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

