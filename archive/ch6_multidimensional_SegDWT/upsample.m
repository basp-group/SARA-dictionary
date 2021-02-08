function [y] = upsample(x,varargin)

if(length(varargin)>0)
    L = varargin{1};
else
    L=2;
end

if(length(varargin)>1)
    sudLich = varargin{2};
else
   sudLich = 0;
end


sudy = sudLich;

xrow =  x(:)';
if(sudy==0)
   Lmat=[zeros(L-1,length(x)); xrow];
    y = [Lmat(:); zeros(L-1,1)];
elseif(sudy == 1)
   Lmat=[ xrow; zeros(L-1,length(x));];
   ytemp = Lmat(:);
   y = ytemp(1:end-(L-1));
elseif(sudy==2)
    Lmat=[ xrow; zeros(L-1,length(x));];
   y = Lmat(:);
else
         
            
end