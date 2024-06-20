[Return,strout]=system(['PESQ ','+16000',' ','original.wav',' ','output.wav']);
lastFiveChars = strout(end-5:end-1);
num = str2double(lastFiveChars);