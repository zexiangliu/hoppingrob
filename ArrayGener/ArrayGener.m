function array = ArrayGener(M_X,M_U,tau,r)
%% initialization

if(nargin==0) % if no external input
    tau = 0.5;     % time span
    r = 1;       % radius of infinity norm ball when mapping xt--->[X]_eta
    % grid generation
    % ========= Configuration ===========
    % state space grid size
    X.gridsize = 1;   % eta
    U.gridsize = 1;

    % boundaries: i^th row -->  i^th dimension
    X.bnd = [           
        -5,5;
        -5,5
        ];

    U.bnd = [-1,1];
    % =====================================
    M_X = GridGener(X);
    M_U = GridGener(U);
elseif(nargin<4)
    error('Not enough input arguments.')
end


num_X = prod(M_X.discr_bnd(:,3));   % # nodes in state space
num_U = prod(M_U.discr_bnd(:,3));   % # nodes in input space
dim_X = size(M_X.bnd,1);              % dim of state space
dim_U = size(M_U.bnd,1);              % dim of input space

%% Initialize output array

array = cell(num_U,1);
for i = 1:num_U
    array{i}=sparse(num_X+1,num_X+1); % the (num_X+1)^th node represents the sink node
    array{i}(num_X+1,num_X+1)=1;
end

%% Solving diff. eqn.

for i = 1:num_U
    sub_u0 = M_U.ind2sub(i,:)';         % Input
    u0 = M_U.discr_bnd(:,1)+(sub_u0-1)*M_U.gridsize;
    for j = 1:num_X
        % Nonlinear equation solver
        sub_x0 = M_X.ind2sub(j,:)';     % Initial Condition
        x0 = M_X.discr_bnd(:,1)+(sub_x0-1)*M_U.gridsize;
        y0 = [x0;u0];    % States for numerical integration
        % ode45
        yt = ode45(@odefun,[0,tau],y0);
        xt = yt.y(1:2,end);
%         % rk4
%         yt = rk4(tau,y0,10);
%         xt = yt(1:2);

        % Mapping: xt--->[X]_eta
        idx = mapping(xt,M_X,r);
        array{i}(j,idx)=1;
    end
end

end

% Runge-Kutta 4 (alternative of ode45)
% function yt = rk4(tau,y0,N)
% dt = tau/N; %time step
% time = 0;
% yt = y0;
% for i = 1:N
%     f0 = odefun(time,yt);
%     f1 = odefun(time+dt/2,yt+dt*f0/2);
%     f2 = odefun(time+dt/2,yt+dt*f1/2);
%     f3 = odefun(time+dt,yt+dt*f2);
%     yt = yt + dt*(f0+2*f1+2*f2+f3)/6;
% end
% end