function segment = fwdInput(segment,lo,hi,J,varargin);

corner = segment{1,2};
dim = length(segment{2,2});
dimensions = segment{2,3};
segment{3,3} = cell(J+1,1);
segment{4,3} = cell(J+1,1);
segment{3,2} = cell(J+1,1);
segment{4,2} = cell(J+1,1);

% calculating numbers of coefficients in each subband in each dimension
m = length(lo);
Sn = segment{1,2};
Snplus1 = segment{1,3} + Sn;
Snj=zeros(1,dim);
Snplus1j=zeros(1,dim);

    for j=1:J
        segment{4,3}{j}=zeros(1,dim);
        segment{4,2}{j}=zeros(1,dim);
        for d=1:dim
            Snj(d) = floor(Sn(d)./2^j);
            if(checkStringVarargin({segment{end}{d,:}},'last'))
                Snplus1j(d) = floor(2^(-j).*Snplus1(d)+(1-2^(-j))*(m-1));
            else
                Snplus1j(d) = floor(Snplus1(d)./2^j);
            end
           segment{4,3}{j}(d) = Snplus1j(d) - Snj(d);
           segment{4,2}{j}(d) = Snj(d);
        end
    end
   segment{4,3}{J+1} = segment{4,3}{J};
   segment{4,2}{J+1} = segment{4,2}{J};



tempDisc = zeros(1,dim);



for j=1:J-1
        segment{3,3}{j}=zeros(1,dim);
        segment{3,2}{j}=zeros(1,dim);
   
     for d=1:dim   
         if(checkStringVarargin({segment{end}{d,:}},'first'))
               segment{3,3}{j}(d)= segment{4,3}{j}(d);
               segment{3,2}{j}(d)= segment{4,2}{j}(d);
            else 
                tempDisc(d) = (2^(J-j)-1)*(m-2) + floor(mod(Sn(d),2^J)/2^j);
                segment{3,3}{j}(d) = segment{4,3}{j}(d) + tempDisc(d);
                segment{3,2}{j}(d) = segment{4,2}{j}(d) - tempDisc(d);
         end
     end
end
    segment{3,3}{J+1}=segment{4,3}{J+1};
    segment{3,3}{J}=segment{4,3}{J};
    segment{3,2}{J+1}=segment{4,2}{J+1};
    segment{3,2}{J}=segment{4,2}{J};
%%%%%%

   






for i=1:dim
    if segment{1,3}(i)<2^J
        error('Segment size in dim %d must be >=2^J=%d.',i,2^J);
    end
end

switch(dim)
    case 1
        segment{3,1} = fwd1d(segment{2,1},lo,hi,J,segment{end}{1,:});
        segment = crop1D(segment,J);
    case 2
        segment = fwd2d(segment,lo,hi,J);
        segment = crop2D(segment,J);
    case 3
        segment = fwd3d(segment,lo,hi,J);
        segment = crop3D(segment,J);
    case 4
    case 5
end
        