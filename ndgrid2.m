function X = ndgrid2(SUB)
% modify the matlab built-in func 'ndgrid.m'
% Input: SUB is a nx1 cell containing n input of original ndgrid
% dimension
% Output: X is a nx1 cell containing n output of original ndgrid

%=====================================
%NDGRID Rectangular grid in N-D space
%   [X1,X2,X3,...] = NDGRID(x1gv,x2gv,x3gv,...) replicates the grid vectors 
%   x1gv,x2gv,x3gv,...  to produce the coordinates of a rectangular grid 
%   (X1,X2,X3,...).  The i-th dimension of the output array Xi are copies
%   of elements of the grid vector xigv. For example, the grid vector x1gv 
%   forms the rows of X1, the grid vector x2gv forms the columns of X2 etc. 
%
%   [X1,X2,...] = NDGRID(xgv) is equivalent to [X1,X2,...] = NDGRID(xgv,xgv,...).
%   The dimension of the output is determined by the number of output
%   arguments. X1 = NDGRID(xgv) degenerates to produce a 1-D grid represented
%   by a 1-D array.
%
%   The coordinate arrays are typically used for the evaluation of functions 
%   of several variables and for surface and volumetric plots.
%
%   NDGRID and MESHGRID are similar, though NDGRID supports 1-D to N-D while 
%   MESHGRID is restricted to 2-D and 3-D. In 2-D and 3-D the coordinates 
%   output by each function are the same, the difference is the shape of the 
%   output arrays. For grid vectors x1gv, x2gv and x3gv of length M, N and P 
%   respectively, NDGRID(x1gv, x2gv) will output arrays of size M-by-N while 
%   MESHGRID(x1gv, x2gv) outputs arrays of size N-by-M. Similarly,
%   NDGRID(x1gv, x2gv, x3gv) will output arrays of size M-by-N-by-P while 
%   MESHGRID(x1gv, x2gv, x3gv) outputs arrays of size N-by-M-by-P.
%
%   Example: Evaluate the function  x2*exp(-x1^2-x2^2-x^3) over the
%            range  -2 < x1 < 2,  -2 < x2 < 2, -2 < x3 < 2,
%
%       [x1,x2,x3] = ndgrid(-2:.2:2, -2:.25:2, -2:.16:2);
%       z = x2 .* exp(-x1.^2 - x2.^2 - x3.^2);
%       slice(x2,x1,x3,z,[-1.2 .8 2],2,[-2 -.2])
%
%
%   Class support for inputs x1gv,x2gv,x3gv,...
%      float: double, single
%      integer: uint8, int8, uint16, int16, uint32, int32, uint64, int64
%
%   See also MESHGRID, SLICE, INTERPN.

%   Copyright 1984-2013 The MathWorks, Inc. 

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
    for i=1:max(nargout,1)
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
