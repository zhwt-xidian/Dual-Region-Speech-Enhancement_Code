%=============================ISTFT=========================
%dt Sliding window length
%ov Overlap ratio
%tfy Time spectrogram matrix

function [vv]=recover(dt,ov,tfy,A)
h=hamming(dt)';
%h=hann(dt)';
dl=dt*(1-ov);
Y=zeros(A,dt+(A-1)*dl);
W=zeros(A,dt+(A-1)*dl);
for q=1:A
    iY=real(ifft(tfy(q,:)));
    Y(q,(q-1)*dl+1:((q-1)*dl+dt))=iY(1:dt).*h;
    W(q,(q-1)*dl+1:((q-1)*dl+dt))=h.^2;
end
sumY=zeros(1,dt+(A-1)*dl);
sumW=zeros(1,dt+(A-1)*dl);
for p=1:A
    sumY=sumY+Y(p,:);
    sumW=sumW+W(p,:);
end
vv=sumY./sumW;
end