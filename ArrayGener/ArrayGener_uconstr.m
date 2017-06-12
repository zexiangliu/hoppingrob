function ts = ArrayGener_uconstr(M_X,M_U,tau,r,lmax,uconstr)
% modified based on ArrayGener_ts
% add input constraints
% version for input constraints

% input 'uconstr' is a structure having all information used for function 
% uconstraints()
%% initialization
var = load('system.mat');
A=var.A;
B=var.B;

isFull = 0; % equal to 1 if A is full rank
if(rank(A) == length(A))
    isFull = 1;     
end

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

ts = TransSyst(num_X+1,num_U);          % +1 for sink node

options = optimoptions('linprog','Algorithm','dual-simplex','Display','off'); % option for linprog
%% Solving diff. eqn.
M = 4; % num of workers to use
% parfor (i = 1:num_U,M)

% State Transition Matrix (for LTI)
Phi = expm(A*tau);
Phi_u = zeros(dim_X,dim_U);
if(isFull==1)
    Phi_u = -inv(A)*(eye(dim_X)-Phi)*B;
else
    for i = 1:dim_U
        u0=zeros(dim_U,1);
        u0(i)=1;
        y0 = [zeros(dim_X,1);u0];    % States for numerical integration
        yt = ode45(@odefun,[0,tau],y0);
        Phi_u(:,i) = yt.y(1:dim_X,end);
    end
end

%% for parallel computation
transition_list = cell(num_U);
pg_list = cell(num_U);

parfor (i = 1:num_U,M)
% for i = 1:num_U
    % calculate the input u0 corresponding to index i
    sub_u0 = M_U.ind2sub(i,:)';        
    u0 = M_U.discr_bnd(:,1)+(sub_u0-1)*M_U.gridsize;
    
    if(~uconstraints(uconstr,u0))
        % u0 is not feasible
        disp('Find an unfeasible input.')
        continue;
    end
    %% Add progress group (part I)
    % Calculate equilibrium
    isEq = 1;   % flag that eq exists
    x_part = -pinv(A)*(B*u0);  % particular solution
    if(isFull ~= 1)  % if A isn't full rank, the eq may not exists or be unqiue
        x_hom = null(A); % homogenuous solution of Ax + Bu = 0
        
        if(rank(A)~=rank([A B*u0])) % if solution doesn't exist
            isEq = 0; % eq is not exist
%             keyboard();
        end
    end
    % progress group
    PG = 1:num_X;    % group having all the states
    if(isFull == 1) % if A is full rank
        idx_eq = mapping(x_part,M_X,M_X.gridsize/2); % mapping the eq into nodes in grid
        if(idx_eq ~= num_X + 1) % if eq is in the state space
            PG(idx_eq)=-1;      % remove the eq from progress group
        end
    else                % if A is not full rank, then eq may not exist
        % if isEq == 0 (means no eq exists), PG are all states
        if(isEq == 1)   % eq exists
            dimN = size(x_hom,2);    % dim of null space of A
            ones_eta = M_X.gridsize/2*ones(dimN,1);%   ||||| 
            % loop over all nodes in the next section  vvvvv
        end
    end
    
    %% Nonlinear equation solver
    % zero-input response (only for LTI sys)
    state1 = [];
    state2 = [];
    for j = 1:num_X
        sub_x0 = M_X.ind2sub(j,:)';     % Initial Condition
        x0 = M_X.discr_bnd(:,1)+(sub_x0-1)*M_X.gridsize;
        % check input restriction (only for 1D)
        if(norm(x0(1)-u0)>(lmax-M_X.gridsize/2))
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
        
        % check input restriction (only for 1D)
        if(norm(xt(1)-u0)>(lmax-r(1)))
            PG(j)=-1;
            continue;
        end
        % Mapping: xt--->[X]_eta
        
         idx = mapping_ext(xt,M_X,r);
         for k = idx'
%              ts.add_transition(j,k,i);
               state1 = [state1;j];
               state2 = [state2;k];
         end
         % add progress group (part II)
         if((~isFull)&&isEq)
             f_lp = ones(dimN,1);
             A_lp = [x_hom;-x_hom];
             b_lp = [ones_eta+x0-x_part;ones_eta+x_part-x0];
             % remove invalid constraints in A_lp*x <= b_lp, that's zero
             % rows in A
             invalid_row = (sum(A_lp==0,2)==dimN); % 
             if(all(b_lp(invalid_row)>=0)) % the rows of b corresponding to zero rows of A have to be >= 0
                 A_lp(invalid_row,:)=[];
                 b_lp(invalid_row,:)=[];
                 % check if eq in the region of node j using linear programming
                 [~,~,EXITFLAG] = linprog(f_lp,A_lp,b_lp,[],[],[],[],[],options);    
                if(EXITFLAG == 1) % EXITFLAG = 1 means that the region mapped into x0 has eq
                     PG(j) = -1; % remove this eq from progress group
                end
             end
         end
    end
    transition_list{i} = [state1,state2];
    PG(PG==-1)=[];
%     ts.add_progress_group(i,PG);
    pg_list{i} = PG;
end

for i = 1:num_U
   if(~isempty(pg_list{i}))
       ts.add_progress_group(i,pg_list{i});
   end
   ts_state =transition_list{i};
   if(~isempty(ts_state))
       ts.add_transition(ts_state(:,1)',ts_state(:,2)',i*ones(size(ts_state,1),1)');
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