% Given the state of CTS sys x(t) in Q, map x(t) to [Q]_n
function idx = mapping_ext(xt,Qn,r,type)
% extended version of mapping, consider some properties of system dynamics
% for a more accurate mapping (consider unsymmetrical r region (r_l and r_r))
%
% Input:
%   xt: nx1 vector, state to be mapped
%   Qn: the mesh of discretized state space
% Output:
%   idx: the index of nodes contained by the Br(x(t)) in Qn
%   type: 'n' normal mode, 'o' original idx, used only for grid with constraints 
if(size(xt,2)~=1)
    error('xt must be a column vector.');
end
if(nargin==3)
    type = 'n';
end
% if(nargin<2)
%     var = load('ts');
%     Qn = var.M_X;
%     r = var.eta/2;
% end

% eta = Qn.gridsize;      % grid size of discretized state space
bnd = Qn.bnd;           
n = size(bnd,1);        % # dim
discr_bnd = Qn.discr_bnd;
V = Qn.V; 
eta = Qn.gridsize;

% check if xt is out of interested state space
% lbnd = (bnd(:,1)<=xt);  % lower bnd
% ubnd = (xt<=bnd(:,2));  % upper bnd
if(size(r,2)==1)
    r_l = r;
    r_r = r;
else
    r_l = r(:,1);
    r_r = r(:,2);
end

lbnd = xt-r_l<discr_bnd(:,1)-eta/2;
ubnd = xt+r_r>discr_bnd(:,2)+eta/2;
if (any(lbnd)||any(ubnd))    
    idx=Qn.numV; % if out of bnd, assign it to sink node
    if(type == 'o')
        idx = Qn.numVfull;
    end
    return;
end

%% find the nodes in Br(xt)
SUB = cell(1,n);       % subscripts of selected discretized nodes
% strN(1:n)=' ';  % param for eval func
for i = 1:n
    pos_node = V{i};%linspace(discr_bnd(i,1),discr_bnd(i,2),discr_bnd(i,3)); % maybe pre-calculation is better
    sub_idx1 = pos_node<= (xt(i)+r_r(i)+eta(i)/2); % filter the nodes in the ball
                                                % 1e-15 is due to round error in
    sub_idx2 = pos_node>= (xt(i)-r_l(i)-eta(i)/2);
    sub_idx = sub_idx1&sub_idx2;
    SUB{i} = find(sub_idx==1);             % find idx           
%     strN(i)=num2str(i);
end

%% map sub to index

X = ndgrid2(SUB);
idx = sub2ind2(discr_bnd(:,3),X);
if(type ~= 'o' && Qn.withCons)
    idx = Qn.ind2ind(idx);
    idx(idx==0) = []; % Qn.numV;
end
% lbnd = xt-r<bnd(:,1);
% ubnd = xt+r>bnd(:,2);
% 
% if(any(lbnd(2:end))||any(ubnd(2:end)))
%     idx =[idx;Qn.numV];
% end
idx = uint32(full(idx));



