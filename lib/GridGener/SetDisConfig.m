function X = SetDisConfig(gridsize,bnd,varargin)
% Generate DisConfig struct for parameter DisConfig of function GridGener
% input: grid size
%        bnd [[a1,a2;b1,b2;...] 
%             (bnd for dim 1 is [a1,a2] and so on)
% extra inputs must follow the format: ...,'fieldname', value,...
  X.gridsize = gridsize;
  X.bnd = bnd;
  if(~isempty(varargin))
    for i = 1:length(varargin)/2
        X=setfield(X,2*varargin{i}-1,2*varargin{i});
    end
  end
end