function segment = inwZeros1D(segment,lo,hi,J)

%output
segment{5,1}=zeros(segment{2,3});
Rn(1)=segment{1,2};
Rn(2)= segment{1,2}+ segment{1,3};
s = segment{1,3};

x = segment{4,1};

xext = x;
for k=1:J-1
  rJminkAct = (2^(J-k)-1)*(length(lo)-2);
  zerosToAdd = floor((mod(Rn(1),2^J)/2^k));
  xext{k}=[zeros(zerosToAdd+rJminkAct,1);x{k}];
end
rJ = (2^J-1)*(length(lo)-2);
tempa = xext{end};

for j=J:-1:2
tempa=upConv(tempa,lo,2, ...
                     length(xext{j-1}),'new');
        tempb=upConv(xext{j},hi,2, ...
                     length(xext{j-1}),'new');
        tempa = tempa + tempb;
end
RnMod2J = mod(Rn(1),2^J);
    tempa=upConv(tempa,lo,2, ...
                 s+rJ+RnMod2J,'new');
    tempd=upConv(xext{1},hi,2, ...
                 s+rJ+RnMod2J,'new');
    tempa = tempa + tempd;

% if(checkStringVarargin(varargin,'first'))
%     y = tempa(rJ+1:end);
% elseif(checkStringVarargin(varargin,'invOLS'))
%     y = tempa(rJ+1+RnMod2J:end);
% else
%     y = tempa(1:end);
% end
% 
% return;

segment{5,1} = tempa;







