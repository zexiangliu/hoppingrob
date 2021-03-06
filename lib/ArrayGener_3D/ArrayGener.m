function ts = ArrayGener(M_X,M_U,tau,lmax,uconstr,system)
% modified based on ArrayGener_ts
% add input constraints
% version for input constraints
% for push-recovery case 4

% input 'uconstr' is a structure having all information used for function 
% uconstraints()
%% initialization
g = system.g;
h0 = system.h0;

% isFull = 1; % equal to 1 if A is full rank

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


num_X = M_X.numV;   % # nodes in state space
num_U = M_U.numV;   % # nodes in input space
dim_X = size(M_X.bnd,1);              % dim of state space
dim_U = size(M_U.bnd,1);              % dim of input space
eta = M_X.gridsize;
mu = M_U.gridsize;
uconstr.eta = eta;

% dimN=0;
% x_hom=[];
% x_part=[];
% ones_eta=[];

% direction = uconstr.direction;
gnd = uconstr.gnd;
coord_bias = uconstr.coord_bias;
ucons_fun = uconstr.ucons_fun; % constraint function of input
ROT = uconstr.ROT;

num_s = zeros(num_U-1,1,'uint32'); % num of transitions in ts structure

options = optimoptions('linprog','Algorithm','dual-simplex','Display','off'); % option for linprog
%% Solving diff. eqn.
% M = 4; % num of workers to use

%% for parallel computation
transition_list = cell(num_U-1);
pg_list = cell(num_U-1);

parfor i = 1:num_U-1
% for i = 1:num_U-1
    % calculate the input u0 corresponding to index i
    u0 = get_coord(M_U,i);
    
    if(~feval(ucons_fun,uconstr,u0,[0;0],0,0,1))
        % u0 is not feasible
        disp('Find an unfeasible input.')
        continue;
    end
%     
    % calculate system parameter
%     tmp_u = ROT*u0 + coord_bias;
    h = h0 ;%- gnd.get_height(tmp_u(1),tmp_u(2));
    A = [0 0 1 0;
         0 0 0 1;
        g/h 0 0 0;
        0 g/h 0 0];
    B = [0 0
        0 0
         -g/h 0
         0 -g/h];
    
    % calculate state transition matrix
    Phi = expm(A*tau);
    Phi_u = -inv(A)*(eye(dim_X)-Phi)*B;
    
    % calculate r
    r1 = Phi*eta/2; % the upper bnd of ||x_0(tau)-x_1(tau)||
    r = r1;    %%%     % radius of norm ball when mapping xt to discr. state space

    %% Add progress group (part I)
    % Calculate equilibrium
%     isEq = 1;   % flag that eq exists
    x_part = -pinv(A)*(B*u0);  % particular solution
    
    % progress group
    PG = 1:num_X;    % group having all the states
    idx_eq = mapping_ext(x_part,M_X,eta/2*0); % mapping the eq into nodes in grid
    if(idx_eq ~= num_X + 1) % if eq is in the state space
        PG(idx_eq)=-1;      % remove the eq from progress group
    end
    
    %% Nonlinear equation solver
    % zero-input response (only for LTI sys)
    state1 = zeros(prod(floor(2*r./eta)+1)*(num_X-1),1,'uint32');
    state2 = state1;
    counter_state = 1;
    for j = 1:num_X-1
        x0 = get_coord(M_X,j);
        % check input restriction
        if(any(abs(x0(1:2)-u0)+abs(eta(1:2)/2)>h/h0*lmax*100/sqrt(2))||~feval(ucons_fun,uconstr,u0,x0,h,r,2))
            PG(j)=-1; % remove this state from progress group
            continue;
        end
    %         y0 = [x0;u0];    % States for numerical integration
    %         % ode45
    %         yt = ode45(@odefun,[0,tau],y0);
    %         xt = yt.y(1:dim_X,end);
        
%         % rk4
%         yt = rk4(tau,y0,10);
%         xt = yt(1:2);
        
        % xt = zero-state + zero-input
        xt = Phi*x0+Phi_u*u0;
        
        % check input restriction
%         min(h/h0*lmax/sqrt(2)-abs(r(1:2)/2))
        if(any(abs(xt(1:2)-u0)+abs(r(1:2)/2)>h/h0*lmax/sqrt(2))||~feval(ucons_fun,uconstr,u0,xt,h,r,3))
            PG(j)=-1;
            continue;
        end
        % Mapping: xt--->[X]_eta
        
         idx = mapping_ext(xt,M_X,r);
         len_idx = length(idx);
         state1(counter_state:counter_state+len_idx-1) = j*ones(len_idx,1);
         state2(counter_state:counter_state+len_idx-1) = idx;
         counter_state = counter_state + len_idx;
%          for k = idx'
% %              ts.add_transition(j,k,i);
%                state1 = [state1;j];
%                state2 = [state2;k];
%          end
    end
    valid_idx = state1~=0;
    num_s(i) = sum(valid_idx);
    transition_list{i} = [state1(valid_idx),state2(valid_idx)];
    PG(PG==-1)=[];
%     ts.add_progress_group(i,PG);
    pg_list{i} = PG;
    i
end

ts = TransSyst(num_X,num_U,sum(num_s));          % +1 for sink node
for i = 1:num_U-1
   if(~isempty(pg_list{i}))
       ts.add_progress_group(i,pg_list{i});
   end
   if(~isempty(transition_list{i}))
       ts.add_transition(transition_list{i}(:,1)',transition_list{i}(:,2)',i*ones(size(transition_list{i},1),1,'uint32')');
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