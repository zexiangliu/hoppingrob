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
num_node = ceil(range/u-1); % num of discretized points in each dimension
bnd_layer = (range-num_node*u)/2;

% discretize the boundaries
Mesh.discr_bnd = [bnd(:,1)+bnd_layer, bnd(:,2)-bnd_layer, num_node+1]; 
% 
% num = floor((bnd(:,2)-bnd(:,1))/u);
% Mesh.discr_bnd = [bnd(:,1),bnd(:,1)+num*u,num+1]; % discretize the boundaries

%% pre-calculation
% % Generate the data needed by mapping
n =  size(Mesh.discr_bnd,1);
Mesh.V = cell(n,1);          % vertex in the grid, catagorized according to dimension
for i = 1:n
    Mesh.V{i}=linspace(Mesh.discr_bnd(i,1),Mesh.discr_bnd(i,2),Mesh.discr_bnd(i,3));
end

% n =  size(Mesh.bnd,1);
num_V = prod(Mesh.discr_bnd(:,3));
Mesh.ind2sub=zeros(num_V,n);

for i = 1:num_V
    Mesh.ind2sub(i,:)=ind2sub2(Mesh.discr_bnd(:,3),i)'; 
end

Mesh.numV = num_V+1;
end
% 
% 
% function sub = ind2sub_vec(size,idx,dim)
% persistent strN strX dim_old
% if(isempty(strN)||dim_old~=dim)
%     strN = num2str(1:dim);
%     strN(strN==' ')='';
%     strX = '';
%     strX (1:(3*dim-1))=' ';
%     strX(1:3:(3*dim-2))='X';
%     strX(2:3:(3*dim-1))=strN;
%     strX(3:3:(3*dim-3))=',';
%     dim_old = dim;
% end
% sub = zeros(dim,1);
% eval(['[',strX,']=ind2sub(size,idx);']);
% eval(['sub=[',strX,']'';']);
% end