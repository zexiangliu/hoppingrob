function array = ArrayGener
clc;clear all;
%% initialization
tau = 0.01;     % time span
r = 0.08;       % radius of infinity norm ball when mapping xt--->[X]_eta
%% grid generation
% Set discretization parameters
% state space
X.gridsize = 0.1;   % eta
% boundaries, i^th row -->  i^th dimension
X.bnd = [           
    -5,5;
    -5,5
    ];
M_X = GridGener(X);

U.gridsize = 0.1;   % miu
U.bnd = [-pi/3,pi/3];
M_U = GridGener(U);

num_X = prod(M_X.discr_bnd(:,3));   % # nodes in state space
num_U = prod(M_U.discr_bnd(:,3));   % # nodes in input space
dim_X = size(X.bnd,1);              % dim of state space
dim_U = size(U.bnd,1);              % dim of input space
%% Initialize output array
array = cell(num_U,1);
for i = 1:num_U
    array{i}=sparse(num_X+1,num_X+1); % the (num_X+1)^th node represents the sink node
    array{i}(num_X+1,num_X+1)=1;
end

%% Solving diff. eqn.
for i = 1:num_U
    sub_u0 = ind2sub_vec(M_U.discr_bnd(:,3),i,dim_U);         % Input
    u0 = M_U.discr_bnd(:,1)+(sub_u0-1)*M_U.gridsize;
    for j = 1:num_X
        %% nonlinear equation solver
        sub_x0 = ind2sub_vec(M_X.discr_bnd(:,3),j,dim_X);     % Initial Condition
        x0 = M_X.discr_bnd(:,1)+(sub_x0-1)*M_U.gridsize;
        y0 = [x0;u0];    % States for numerical integration
%         yt = ode45(@odefun,[0,tau],y0);
        yt = rk4(tau,y0,100);
%         xt = yt.y(1:2,end);
        xt = yt(1:2);
        %% mapping: xt--->[X]_eta
        idx = mapping(xt,M_X,r);
        array{i}(j,idx)=1;
    end
end

end

function sub = ind2sub_vec(size,idx,dim)
global strN strX dim_old
if(isempty(strN)||dim_old~=dim)
    strN = num2str(1:dim);
    strN(strN==' ')='';
    strX = '';
    strX (1:(3*dim-1))=' ';
    strX(1:3:(3*dim-2))='X';
    strX(2:3:(3*dim-1))=strN;
    strX(3:3:(3*dim-3))=',';
    dim_old = dim;
end
sub = zeros(dim,1);
eval(['[',strX,']=ind2sub(size,idx);']);
eval(['sub=[',strX,']'';']);
end

function yt = rk4(tau,y0,N)
dt = tau/N; %time step
time = 0;
yt = y0;
for i = 1:N
    f0 = odefun(time,yt);
    f1 = odefun(time+dt/2,yt+dt*f0/2);
    f2 = odefun(time+dt/2,yt+dt*f1/2);
    f3 = odefun(time+dt,yt+dt*f2);
    yt = yt + dt*(f0+2*f1+2*f2+f3)/6;
end
end