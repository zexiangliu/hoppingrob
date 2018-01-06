function X = ndgrid2(SUB)
% modify the matlab built-in func 'ndgrid.m'
% Input: SUB is a nx1 cell containing n input of original ndgrid
% dimension
% Output: X is a nx1 cell containing n output of original ndgrid

if (nargin==0)
   error(message('MATLAB:ndgrid:NotEnoughInputs'));    
end
nout = length(SUB);
j = 1:nout;
siz = cellfun(@numel,SUB);

X = cell(nout,1);
if nout == 2 % Optimized Case for 2 dimensions
    x = full(SUB{j(1)}(:));
    y = full(SUB{j(2)}(:)).';
    X{1} = repmat(x,size(y));
    X{2} = repmat(y,size(x));
    X{1} = X{1}(:);
    X{2} = X{2}(:);
else
    for i=1:max(nout,1)
        x = full(SUB{j(i)});
        s = ones(1,nout); 
        s(i) = numel(x);
        x = reshape(x,s);
        s = siz; 
        s(i) = 1;
        X{i} = repmat(x,s);
        X{i} = X{i}(:);
    end
end
