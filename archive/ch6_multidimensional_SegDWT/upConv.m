function [ y ] = upConv( x,filt,sub,s,varargin )


flen = length(filt);


if(checkStringVarargin(varargin,'first') & checkStringVarargin(varargin,'last'))
   if(checkStringVarargin(varargin,'new'))
          xx = conv(upsample(x,sub,2),filt);
          y = xx(length(filt)-1:length(filt)-1+s-1);
     else
       xx = conv(upsample(x,sub,0),filt);
      y = xx(length(filt):length(filt)+s-1);
   end
      return;
end


if(checkStringVarargin(varargin,'first'))
   if(checkStringVarargin(varargin,'new'))
      xx = conv(upsample(x,sub,2),filt);
      y = xx(length(filt)-1:length(filt)-1+s-1);
     %y = xx(length(filt)-1:end);
   else
      xx = conv(upsample(x,sub,0),filt);
      y = xx(length(filt):length(filt)+s-1);
   end
      return;
else
   if(checkStringVarargin(varargin,'new'))
      xx = conv(upsample(x,sub,2),filt);
      y = xx(1:s);
   else
      xx = conv(upsample(x,sub,0),filt);
      y = xx(1:s);
   end
      return;
end









