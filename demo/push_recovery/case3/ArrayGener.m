function ts = ArrayGener(M_X,M_U,tau,lmax,uconstr)
% modified based on ArrayGener_ts
% add input constraints
% version for input constraints
% for push-recovery case 4

% input 'uconstr' is a structure having all information used for function 
% uconstraints()
%% initialization
var = load('system.mat');
g = var.g;
h0 = var.h0;

isFull = 1; % equal to 1 if A is full rank

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
eta = M_X.gridsize;
mu = M_U.gridsize;
uconstr.eta = eta;

% uncomment when holes exist.
% direction = uconstr.direction;
% gnd = uconstr.gnd;
% coord_bias = uconstr.coord_bias;
hlim = uconstr.hlim;

% linear system definition
h = h0 + hlim;
A =[0 1;g/h0 0];
B = [0;-g/h0];    
A_ex =[0 1;g/h 0]; % system matrice in extreme case
B_ex = [0;-g/h];   

ts = TransSyst(num_X+1,num_U);          % +1 for sink node

options = optimoptions('linprog','Algorithm','dual-simplex','Display','off'); % option for linprog
%% Solving diff. eqn.
M = 4; % num of workers to use

% calculate state transition matrix
[Phi,Phi_u] = STM(A,B,tau);
[Phi_ex,Phi_u_ex] = STM(A,B,tau);
%% for parallel computation
transition_list = cell(num_U);
pg_list = cell(num_U);

% parfor (i = 1:num_U,M)
for i = 1:num_U
    % calculate the input u0 corresponding to index i
    sub_u0 = double(M_U.ind2sub(i,:)');        
    u0 = M_U.discr_bnd(:,1)+(sub_u0-1)*mu;
    
    if(~uconstraints(uconstr,u0,[0;0],0,0,1))
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
        idx_eq = mapping(x_part,M_X,M_X.gridsize*0); % mapping the eq into nodes in grid
        if(idx_eq ~= num_X + 1) % if eq is in the state space
            PG(idx_eq)=-1;      % remove the eq from progress group
        end
    else                % if A is not full rank, then eq may not exist
        % if isEq == 0 (means no eq exists), PG are all states
        if(isEq == 1)   % eq exists
            dimN = size(x_hom,2);    % dim of null space of A
            ones_eta = eta/2*ones(dimN,1);%   ||||| 
            % loop over all nodes in the next section  vvvvv
        end
    end
    
    %% Nonlinear equation solver
    % zero-input response (only for LTI sys)
    state1 = [];
    state2 = [];
    for j = 1:num_X
        sub_x0 = double(M_X.ind2sub(j,:)');     % Initial Condition
        x0 = M_X.discr_bnd(:,1)+(sub_x0-1).*eta;
        % check input restriction (only for 1D)
        if((norm(x0(1)-u0)+eta(1)/2)>h/h0*lmax||~uconstraints(uconstr,u0,x0,h,0,2))
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
        
        % calculate r1
        r1 = Phi*eta/2; % the upper bnd of ||x_0(tau)-x_1(tau)||
        %calculate candidate 1 of r2
%         x_ex = Phi_ex*x0 + Phi_u_ex*u0;
%         if((x_ex(1)-u0)*(x0(1)-u0)>=0)
%             x1_max = max(abs(xt(1)-u0)+r1(1),abs(x0(1)-u0)+eta/2);
%         else
%             % use binary search to find the t* where x(t*)=u0
%             t1 = 0;
%             t2 = tau;
%             x0_direct = sign(x0(1)-u0);
%             tmp_x = xt;
%             while(abs(tmp_x(1)-u0)>1e-10)
%                 tmp_t = (t1+t2)/2;
%                 [tmp_Phi,tmp_Phi_u] = STM(A_ex,B_ex,tmp_t);
%                 tmp_x = tmp_Phi*x0 + tmp_Phi_u*u0;
%                 if((tmp_x(1)-u0)*x0_direct>=0)
%                     t1 = tmp_t;
%                 else
%                     t2 = tmp_t;
%                 end
%             end
%             [tmp_Phi,tmp_Phi_u] = STM(A,B,(t1+t2)/2);
%             tmp_x = tmp_Phi*tmp_x + tmp_Phi_u*u0;
%             x1_max = max(abs(tmp_x(1)-u0)+r1(1),abs(x0(1)-u0)+eta/2);
%         end
%         
%         counter = 1;
%         while(1) % iterative algorithm to find the smallest r
%             du_max = x1_max*hlim/h;
%             r2_1 = norm(Phi_u*du_max,'inf');
%             % r
% %             r = r1+r2;         % radius of norm ball when mapping xt to discr. state space
%             if(max(abs(xt(1)-u0)+r1(1)+r2_1(1),abs(x0(1)-u0)+eta/2) < x1_max)
% %                 warning('special_case of r2');
%                 x1_max = max(abs(xt(1)-u0)+r1(1)+r2_1(1),abs(x0(1)-u0)+eta/2);
%                 counter = counter +1;
%             else
%                 break;
%             end
%         end
%         
        %calculate candidate 2 of r2
        cr2_1 = (1+lmax*tau)*hlim*exp(max([1;g/h0])*tau);
        cr2_2 = hlim*exp((max([0.5;g/h0])+max([0.5;lmax]))*tau);
        r2_2 = min([cr2_1;cr2_2]);
        x1_max = max(abs(xt(1)-u0)+r1(1)+r2_2(1),abs(x0(1)-u0)+eta(1)/2);
        
        counter = 1;
        while(1) % iterative algorithm to find the smallest r
            du_max = x1_max*hlim/h;
            r2_2 = abs(Phi_u*du_max);
            % r
%             r = r1+r2;         % radius of norm ball when mapping xt to discr. state space
            if(max(abs(xt(1)-u0)+r1(1)+r2_2(1),abs(x0(1)-u0)+eta(1)/2) < x1_max)
%                 warning('special_case of r2');
                x1_max = max(abs(xt(1)-u0)+r1(1)+r2_2(1),abs(x0(1)-u0)+eta(1)/2);
                counter = counter +1;
            else
                break;
            end
        end
        
%         r2 = min(r2_1,r2_2]);
        r2 = r2_2;
        r = r1 + r2;
        
        % check input restriction (only for 1D)
        if((norm(xt(1)-u0)+r1(1)+r2(1))>h/h0*lmax||~uconstraints(uconstr,u0,xt,h,r1(1)+r2(1),3))
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