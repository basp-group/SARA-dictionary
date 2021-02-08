function segment = inwZeros3D(segment,lo,hi,J)

%output
segment{5,1}=zeros(segment{2,3});


% copying ad zero padding of coefficient matrixes to coefTemp
coefTemp=cell(size(segment{4,1}));

dim = 3;
noSubb = 2^dim-1;
Sn=segment{1,2};
rJ=zeros(J,dim);

for j=1:J-1
    for d=1:dim
     rJ(j,d)=(2^(J-j)-1)*(length(lo)-2) + floor(mod(Sn(d),2^J)/2^j);
    end
    for i=1:noSubb
      coefTemp{j,i}=zeros(rJ(j,:)+segment{4,3}{j});
      coefTemp{j,i}(end-segment{4,3}{j}(1)+1:end,...
                    end-segment{4,3}{j}(2)+1:end,...
                    end-segment{4,3}{j}(3)+1:end)=segment{4,1}{j,i};
    end
end

for i=1:noSubb
 coefTemp{J,i}=segment{4,1}{J,i};
end
 coefTemp{J+1,1}=segment{4,1}{J+1,1};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 

in = coefTemp{J+1,1};
for j=J:-1:2
rows = segment{4,3}{j}(1)+rJ(j,1);
cols = segment{4,3}{j-1}(2)+rJ(j-1,2); 
slides = segment{4,3}{j}(3)+rJ(j,3);
% ouptut of the current iteration
tempRows = zeros([rows, cols, slides]);
tempRows2 = zeros([rows, cols, slides]);
tempRows3 = zeros([rows, cols, slides]);
tempRows4 = zeros([rows, cols, slides]);

for slid=1:slides
    for row=1:rows
        tempRows(row,1:cols,slid)=upConv(in(row,:,slid),lo,2, cols,'new');
        tempRows(row,1:cols,slid)=tempRows(row,1:cols,slid)+...
                                  upConv(coefTemp{j,2}(row,:,slid),hi,2, cols,'new')';

        tempRows2(row,1:cols,slid)=upConv(coefTemp{j,1}(row,:,slid),lo,2, cols,'new');
        tempRows2(row,1:cols,slid)= tempRows2(row,1:cols,slid)+...
                                   upConv(coefTemp{j,3}(row,:,slid),hi,2, cols,'new')';
       
        tempRows3(row,1:cols,slid)=upConv(coefTemp{j,4}(row,:,slid),lo,2, cols,'new');
        tempRows3(row,1:cols,slid)= tempRows3(row,1:cols,slid)+...
                                   upConv(coefTemp{j,6}(row,:,slid),hi,2, cols,'new')';
                               
        tempRows4(row,1:cols,slid)=upConv(coefTemp{j,5}(row,:,slid),lo,2, cols,'new');
        tempRows4(row,1:cols,slid)= tempRows4(row,1:cols,slid)+...
                                   upConv(coefTemp{j,7}(row,:,slid),hi,2, cols,'new')';

    end
end

rows = segment{4,3}{j-1}(1)+rJ(j-1,1);
tempa = zeros([rows, cols, slides]);
tempd = zeros([rows, cols, slides]);

for slid = 1:slides
    for col = 1:cols
        tempa(1:rows,col,slid) = upConv(tempRows(:,col,slid),lo,2, rows,'new');
        tempa(1:rows,col,slid) = tempa(1:rows,col,slid) +...
                                upConv(tempRows2(:,col,slid),hi,2, rows,'new');
        
        tempd(1:rows,col,slid) = upConv(tempRows3(:,col,slid),lo,2, rows,'new');
        tempd(1:rows,col,slid) = tempd(1:rows,col,slid) +...
                                upConv(tempRows4(:,col,slid),hi,2, rows,'new');
    end
end

slides = segment{4,3}{j-1}(3)+rJ(j-1,3);
in = zeros([rows, cols,slides]);
for row = 1:rows
    for col = 1:cols
        in(row,col,1:slides) = upConv(tempa(row,col,:),lo,2, slides,'new');
        in(row,col,1:slides) = squeeze(in(row,col,1:slides)) +...
                              upConv(tempd(row,col,:),hi,2, slides,'new');
    end
end

end

rows =   segment{4,3}{1}(1)+rJ(1,1);
slides = segment{4,3}{1}(3)+rJ(1,3);
rJ=(2^J-1)*(length(lo)-2)+mod(Sn(2),2^J);
cols = segment{1,3}(2)+rJ;
tempRows = zeros([rows, cols, slides]);
tempRows2 = zeros([rows, cols, slides]);
tempRows3 = zeros([rows, cols, slides]);
tempRows4 = zeros([rows, cols, slides]);

for slid=1:slides
    for row=1:rows
        tempRows(row,1:cols,slid)=upConv(in(row,:,slid),lo,2, cols,'new');
        tempRows(row,1:cols,slid)=tempRows(row,1:cols,slid)+...
                                  upConv(coefTemp{1,2}(row,:,slid),hi,2, cols,'new')';

        tempRows2(row,1:cols,slid)=upConv(coefTemp{1,1}(row,:,slid),lo,2, cols,'new');
        tempRows2(row,1:cols,slid)= tempRows2(row,1:cols,slid)+...
                                   upConv(coefTemp{1,3}(row,:,slid),hi,2, cols,'new')';
       
        tempRows3(row,1:cols,slid)=upConv(coefTemp{1,4}(row,:,slid),lo,2, cols,'new');
        tempRows3(row,1:cols,slid)= tempRows3(row,1:cols,slid)+...
                                   upConv(coefTemp{1,6}(row,:,slid),hi,2, cols,'new')';
                               
        tempRows4(row,1:cols,slid)=upConv(coefTemp{1,5}(row,:,slid),lo,2, cols,'new');
        tempRows4(row,1:cols,slid)= tempRows4(row,1:cols,slid)+...
                                   upConv(coefTemp{1,7}(row,:,slid),hi,2, cols,'new')';

    end
end

rJ=(2^J-1)*(length(lo)-2)+mod(Sn(1),2^J);
rows = segment{1,3}(1)+rJ;
tempa = zeros([rows, cols, slides]);
tempd = zeros([rows, cols, slides]);

for slid = 1:slides
    for col = 1:cols
        tempa(1:rows,col,slid) = upConv(tempRows(:,col,slid),lo,2, rows,'new');
        tempa(1:rows,col,slid) = tempa(1:rows,col,slid) +...
                                upConv(tempRows2(:,col,slid),hi,2, rows,'new');
        
        tempd(1:rows,col,slid) = upConv(tempRows3(:,col,slid),lo,2, rows,'new');
        tempd(1:rows,col,slid) = tempd(1:rows,col,slid) +...
                                upConv(tempRows4(:,col,slid),hi,2, rows,'new');
    end
end

rJ=(2^J-1)*(length(lo)-2)+mod(Sn(3),2^J);
slides = segment{1,3}(3)+rJ;
in = zeros([rows, cols,slides]);
for row = 1:rows
    for col = 1:cols
        in(row,col,1:slides) = upConv(tempa(row,col,:),lo,2, slides,'new');
        in(row,col,1:slides) =  squeeze(in(row,col,1:slides))+...
                              upConv(tempd(row,col,:),hi,2, slides,'new');
        segment{5,1}(row,col,1:slides) =   in(row,col,1:slides);                
    end
end







