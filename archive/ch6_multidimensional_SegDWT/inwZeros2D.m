function segment = inwZeros2D(segment,lo,hi,J)

%output
segment{5,1}=zeros(segment{2,3});


% copying ad zero padding of coefficient matrixes to coefTemp
coefTemp=cell(size(segment{4,1}));

dim = 2;
noSubb = dim^2-1;
Sn=segment{1,2};
rJ=zeros(J,dim);

for j=1:J-1
    for d=1:dim
     rJ(j,d)=(2^(J-j)-1)*(length(lo)-2) + floor(mod(Sn(d),2^J)/2^j);
    end
    for i=1:noSubb
      coefTemp{j,i}=zeros(rJ(j,:)+segment{4,3}{j});
      coefTemp{j,i}(end-segment{4,3}{j}(1)+1:end,end-segment{4,3}{j}(2)+1:end)=segment{4,1}{j,i};
    end
end

for i=1:noSubb
 coefTemp{J,i}=segment{4,1}{J,i};
end
 coefTemp{J+1,1}=segment{4,1}{J+1,1};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 

in = coefTemp{J+1,1};
for j=J:-1:2
rows = segment{4,3}{j-1}(1)+rJ(j-1,1);
cols = segment{4,3}{j}(2)+rJ(j,2);    
% ouptut of the current iteration
tempRows = zeros([rows, cols]);
tempRows2 = zeros([rows, cols]);

for col=1:cols
    tempRows(1:rows,col)=upConv(in(:,col),lo,2, rows,'new');
    tempRows(1:rows,col)=tempRows(1:rows,col)+...
                         upConv(coefTemp{j,1}(:,col),hi,2, rows,'new');
    tempRows2(1:rows,col)=upConv(coefTemp{j,2}(:,col),lo,2, rows,'new');
    tempRows2(1:rows,col)=tempRows2(1:rows,col)+...
                         upConv(coefTemp{j,3}(:,col),hi,2, rows,'new');
              
end

cols = segment{4,3}{j-1}(2)+rJ(j-1,2); 
in = zeros([rows, cols]);

    for row=1:rows
        in(row,1:cols) = upConv(tempRows(row,:),lo,2, cols,'new');
        in(row,1:cols) = in(row,1:cols) + upConv(tempRows2(row,:),hi,2, cols,'new')';
    end
end

cols = segment{4,3}{1}(2)+rJ(1,2); 
rJ=(2^J-1)*(length(lo)-2)+mod(Sn(1),2^J);
rows = segment{1,3}(1)+rJ;
tempRows = zeros([rows, cols]);
tempRows2 = zeros([rows, cols]);

for col=1:cols
    tempRows(1:rows,col)=upConv(in(:,col),lo,2, rows,'new');
    tempRows(1:rows,col)=tempRows(1:rows,col)+...
                         upConv(coefTemp{1,1}(:,col),hi,2, rows,'new');
    tempRows2(1:rows,col)=upConv(coefTemp{1,2}(:,col),lo,2, rows,'new');
    tempRows2(1:rows,col)=tempRows2(1:rows,col)+...
                         upConv(coefTemp{1,3}(:,col),hi,2, rows,'new');
              
end
rJ=(2^J-1)*(length(lo)-2)+mod(Sn(2),2^J);
cols = segment{1,3}(2)+rJ;
    %in = zeros([rows, cols]);
rJ = (2^J-1)*(length(lo)-2);
for row=1:rows
    temp = upConv(tempRows(row,:),lo,2, cols,'new');
    temp = temp + upConv(tempRows2(row,:),hi,2, cols,'new');
    segment{5,1}(row,1:cols) = temp';
end









