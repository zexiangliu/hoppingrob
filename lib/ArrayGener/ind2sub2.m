function [v] = ind2sub2(siz,ndx)
% modified from built-in function 'ind2sub'
siz = double(siz);
lensiz = length(siz);
nout = lensiz;

v = zeros(lensiz,length(ndx));

if lensiz < nout
    siz = [siz ones(1,nout-lensiz)];
elseif lensiz > nout
    siz = [siz(1:nout-1) prod(siz(nout:end))];
end

if nout > 2
    k = cumprod(siz);
    for i = nout:-1:3,
        vi = rem(ndx-1, k(i-1)) + 1;
        vj = (ndx - vi)/k(i-1) + 1;
        v(i,:) = double(vj);
        ndx = vi;
    end
end

if nout >= 2
    vi = rem(ndx-1, siz(1)) + 1;
    v(2,:) = double((ndx - vi)/siz(1) + 1);
    v(1,:) = double(vi);
else 
    v(1,:) = double(ndx);
end




