function y = convSub(x,filt,sub,varargin)

ytemp= conv(x(:),filt);
if(checkStringVarargin(varargin,'first') & checkStringVarargin(varargin,'last'))
      y = downsample(ytemp,sub,0);
      return;
end


if(checkStringVarargin(varargin,'last'))
     if( checkStringVarargin(varargin,'new'))
          y = downsample(ytemp(length(filt):end),sub,1);
     else
          y = downsample(ytemp(length(filt):end),sub,0);
     end 
     return;

end


if(checkStringVarargin(varargin,'first'))
  y = downsample(ytemp(1:end-(length(filt)-1)),sub,0);
  return;
end



if( checkStringVarargin(varargin,'new'))
         y = downsample(ytemp(length(filt):end-(length(filt)-1)),sub,1);
     else
         y = downsample(ytemp(length(filt):end-(length(filt)-1)),sub,0);
end 
return;

%%
% neni celá konvoluce (posledních m-1 se nespoèítá) -- použije se u prvního
% a všech vnitøních segmentù
% 



cycl = zeros(1,2^nextpow2(length(filt)));  
len = length(cycl);
len2 = length(filt);
cyclIdx = 0;  
startIdx = 0; 
if( checkStringVarargin(varargin,'first'))
    y = zeros(floor(length(x)/sub),1);
else  
    if( checkStringVarargin(varargin,'new'))
        for s = 1:len2-2
            cycl(cyclIdx+1) = x(s+1);
            cyclIdx = cyclIdx + 1;
            cyclIdx = mod(cyclIdx,len);
        end
         startIdx = len2-1;        
    else
        for s = 1:len2-1
            cycl(cyclIdx+1) = x(s+1);
            cyclIdx = cyclIdx + 1;
            cyclIdx = mod(cyclIdx,len);
        end
        startIdx = len2;
    end
    
    
    y = zeros(floor((length(x)-(len2-1))/sub),1);
end


 
 
for n = startIdx:length(y)-1

    for s = 0:sub-1
        cycl(cyclIdx+1) = x(sub*n+s+1);
        cyclIdx = cyclIdx + 1;
        cyclIdx = mod(cyclIdx,len);
    end
    
    
    tempy = 0;
    for i=0:len2-1
        idx = mod((cyclIdx - i - 1),len);
        tempy = tempy + filt(i+1)*cycl(idx+1);
    end
    
    y(n+1)=tempy;
    
end









