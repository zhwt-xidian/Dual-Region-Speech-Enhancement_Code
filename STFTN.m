%=============================STFT=========================
%dt Sliding window length
%ov Overlap ratio
%nfft Frequency bin length
%mic Time domain signal
function [x]=STFTN(dt,ov,nfft,mic)
dl=dt*(1-ov);%Sliding length=frame length - overlap length
len=size(mic,2);
x=zeros(fix((len+dl-dt)/dl),nfft);
if ov==0
    h=ones(1,dt);
else
    h=hamming(dt)';
end

for z=0:fix((len+dl-dt)/dl)-1
    if z==0
       x(1,:)=(fft(mic(1,dl*z+1:dl*z+dt).*h,nfft));
    else
       x(z+1,:)=(fft(mic(1,dl*z+1:dl*z+dt).*h,nfft));
    end
end