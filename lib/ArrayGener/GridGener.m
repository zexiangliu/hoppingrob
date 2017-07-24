% Generate uniform grid of set A given the boundaries and grid size [A]_u 
function Mesh = GridGener(DiscrConfig,ConsConfig)
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
num_node = ceil(range./u-1); % num of discretized points in each dimension
num_node(num_node<0)=0;
bnd_layer = (range-num_node.*u)/2;

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
Mesh.ind2sub=zeros(num_V,n,'uint32');
% for i = 1:num_V
%     Mesh.ind2sub(i,:)=ind2sub2(Mesh.discr_bnd(:,3),i)';
% end

%% Check the real boundary of the region and build up the hash mapping index of rectangle 
% region to the region of interest
count = 1;
cons_fun = ConsConfig.cons_fun;
Mesh.ind2ind = sparse(num_V+1,1);
for i = 1:num_V
    coord = get_coord(i,Mesh);
    if(feval(cons_fun,coord,ConsConfig)==1)
        Mesh.ind2ind(i)=count;
        Mesh.ind2sub(count,:) = ind2sub2(Mesh.discr_bnd(:,3),i)';
        count = count+1;
    end
end
Mesh.numV = count;
% Mesh.ind2ind(num_V+1,1)=count;
% Mesh.ind2ind(Mesh.ind2ind==0)=count;
if(count ~= num_V+1)
    Mesh.ind2sub(count:end,:)=[];
end
end

function coord = get_coord(X,Mesh)
    sub = ind2sub2(Mesh.discr_bnd(:,3),X);
    coord = Mesh.discr_bnd(:,1) + (sub-1).*Mesh.gridsize;
end
