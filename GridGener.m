% Generate uniform grid of set A given the boundaries and grid size [A]_u 
function Mesh = GridGener(DiscrConfig)
% Input: a structure containing discretization configuration
% ~.bnd : nx2 matrix, i^th row [left_bound, right_bound] for i^th elem in
%        R^n
% ~.gridsize 
% Output: Input + discr_bnd
% ~.discr_bnd: nx2 matrix, i^th row [ln,rn,num] means left node
% position ln, right node pos rn and # nodes in total in this dimension

Mesh = DiscrConfig;
bnd = DiscrConfig.bnd;            % boundary values for set A
u = DiscrConfig.gridsize;       % size of grid

if(size(bnd,2)~=2)
    error('DiscrConfig.bnd should have 2 columns.');
end

range = abs(bnd(:,2)-bnd(:,1));  % range of each dimension
num_node = floor(range/u); % num of discretized points in each dimension
bnd_layer = (range-num_node*u)/2;

% Mesh.discr_bnd = [ceil(bnd(:,1)/u), floor(bnd(:,2)/u)]; % discretize the boundaries
% discretize the boundaries
Mesh.discr_bnd = [bnd(:,1)+bnd_layer, bnd(:,2)-bnd_layer, num_node+1]; 
end