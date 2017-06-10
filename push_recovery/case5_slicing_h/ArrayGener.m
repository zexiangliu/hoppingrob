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
dhdx_max = uconstr.dhdx;

% linear system definition

ts = TransSyst(num_X+1,num_U);          % +1 for sink node

% options = optimoptions('linprog','Algorithm','dual-simplex','Display','off'); % option for linprog
%% Solving diff. eqn.
M = 4; % num of workers to use


%% for parallel computation
transition_list = cell(num_U);
pg_list = cell(num_U);
% parfor (i = 1:num_U,M)
for i = 1:num_U
    % calculate the input u0 corresponding to index i
    sub_u0 = double(M_U.ind2sub(i,:)');        
    u0 = M_U.discr_bnd(:,1)+(sub_u0-1).*mu;
        
    if(~uconstraints(uconstr,u0,[0;0],0,0,1))
        % u0 is not feasible
        disp('Find an unfeasible input.')
        continue;
    end
        
    %% Add progress group (part I)
    % Calculate equilibrium
    x_part = [g/h0;u0;0];  % particular solution
    % progress group
    PG = 1:num_X;    % group having all the states
    idx_eq = mappingr(x_part,M_X,[1e4;0;0]); % mapping the eq into nodes in grid
    if(any(idx_eq ~= num_X + 1)) % if eq is in the state space
        PG(idx_eq)=-1;      % remove the eq from progress group
    end
    
    %% Nonlinear equation solver
    % zero-input response (only for LTI sys)
    state1 = zeros(1e3,1,'uint32');
    state2 = zeros(1e3,1,'uint32');
    cnt_s = 1;
    for j = 1:num_X
        sub_x0 = double(M_X.ind2sub(j,:)');     % Initial Condition
        z0 = M_X.discr_bnd(:,1)+(sub_x0-1).*eta;
        
        idx_c = (M_X.V{1}-z0(1))<=(2*lmax*dhdx_max+eta(1)/2);
        c_list = M_X.V{1}(idx_c);
        for k = 1:length(c_list)
            c = c_list(k);
            h = g/c;
            x0 = z0(2:end);
            % check input restriction (only for 1D)
            if((norm(x0(1)-u0)+eta(2)/2)>h/h0*lmax||~uconstraints(uconstr,u0,x0,h,0,2))
                PG(j)=-1; % remove this state from progress group
                continue;
            end

            A =[0 1;c 0];
            B = [0;-c];    
            % calculate state transition matrix
            [Phi,Phi_u] = STM(A,B,tau);
        %         y0 = [x0;u0];    % States for numerical integration
        %         % ode45
        %         yt = ode45(@odefun,[0,tau],y0);
        %         xt = yt.y(1:dim_X,end);

    %         % rk4
    %         yt = rk4(tau,y0,10);
    %         xt = yt(1:2);

            % xt = zero-state + zero-input
            xt = Phi*x0+Phi_u*u0;
            zt = [c;xt];
            % calculate r1
%             r1 = norm(Phi,'inf')*max(eta(2:end))/2; % the upper bnd of ||x_0(tau)-x_1(tau)||
            r1 = Phi*eta(2:end)/2;
            %calculate r2
            r2_1 = (1+lmax*tau)*eta(1)/2*exp(max([1;c+eta(1)/2])*tau);
            r2_2 = eta(1)/2*exp((max([0.5;c+eta(1)/2])+max([0.5;lmax]))*tau);
            r2 = min([r2_1;r2_2]);
            % check input restriction (only for 1D)
            if((norm(xt(1)-u0)+r1(1)+r2)>h/h0*lmax||~uconstraints(uconstr,u0,xt,h,r1+r2,3))
                PG(j)=-1;
                continue;
            end
            % Mapping: xt--->[X]_eta
            r = [0;r1+r2];
            
            if((x0(2)-eta(3)/2)>=0&&(x0(1)-u0-eta(2)/2)>=0)
               if(j==1251)
                   keyboard();
               end
               r_l = r;
               r_r = r;
               r_l(2) = min(r_l(2),xt(1)-x0(1)+eta(2)/2);
               r_l(3) = min(r_l(3),xt(2)-x0(2)+eta(3)/2);
%                if(r_l(2)==xt(1)-x0(1)+eta(2)/2||r_l(3)==xt(2)-x0(2)+eta(3)/2)
%                    keyboard();
%                end
               r = [r_l, r_r];
            elseif((x0(2)+eta(3)/2)<=0&&(x0(1)-u0+eta(3)/2)<=0)
               r_l = r;
               r_r = r;
               r_r(2) = min(r_r(2),x0(1)-xt(1)+eta(2)/2);
               r_r(3) = min(r_r(3),x0(2)-xt(2)+eta(3)/2);
               r = [r_l, r_r];
            end
            idx = mapping_ext(zt,M_X,r);
            if(isempty(idx))
                keyboard();
            end
            num_idx = length(idx);
            state1(cnt_s:cnt_s+num_idx-1) = j*ones(num_idx,1);
            state2(cnt_s:cnt_s+num_idx-1) = idx;
            cnt_s = cnt_s + num_idx;
        end
    end
    vaild_idx = state1~=0;
    transition_list{i} = [state1(vaild_idx),state2(vaild_idx)];
    PG(PG==-1)=[];
%     ts.add_progress_group(i,PG);
    pg_list{i} = PG;
    i
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