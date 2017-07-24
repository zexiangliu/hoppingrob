function X = SetDisConfig(gridsize,bnd)
% Generate DisConfig struct for parameter DisConfig of function GridGener
% input: grid size
%        bnd [[a1,a2;b1,b2;...] 
%             (bnd for dim 1 is [a1,a2] and so on)
  X.gridsize = gridsize;
  X.bnd = bnd;
end