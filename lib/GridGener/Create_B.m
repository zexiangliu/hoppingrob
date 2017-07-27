function B_list = Create_B(bnd,M_X)
% Create B_list
% Input: bnd-------boundary of target set B
%        M_X-------grid structure of state space

if(size(bnd,2)~=2)
    error('"bnd" should have 2 columns.')
end

dimX = size(M_X.gridsize,1);
lower_idx = mapping(bnd(:,1),M_X,zeros(dimX,1),'o');
upper_idx = mapping(bnd(:,2),M_X,zeros(dimX,1),'o');

lower_sub = ind2sub2(M_X.discr_bnd(:,3),lower_idx);
upper_sub = ind2sub2(M_X.discr_bnd(:,3),upper_idx);

% When boundary of B and node boundary of grid coincides, use the smallest
% set
[~,l_idx] = min(sum(lower_sub));
[~,u_idx] = max(sum(upper_sub));
lower_sub = lower_sub(:,l_idx);
upper_sub = upper_sub(:,u_idx);

size_X = M_X.discr_bnd(:,3);
size_B = upper_sub-lower_sub+1;
num_B = prod(upper_sub-lower_sub+1); % num of elem in B
% dim = size(M_X.discr_bnd,1);         % dimension of state space

B_list = zeros(num_B,1);

for i = 1:num_B
   sub_i = double(lower_sub)+ind2sub2(size_B,i)-1;
   B_list(i) = sub2ind2(size_X,num2cell(sub_i));
end

if(~isempty(M_X.ind2ind))
  B_list = full(M_X.ind2ind(B_list));
end

B_list(B_list==0)=[];
end