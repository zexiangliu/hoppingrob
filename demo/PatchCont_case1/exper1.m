% Experiment 1 for patching paper

clear all;close all;clc;

%=========Initial=========
% Set up everything for simulation: abstraction system, controller
% Ground Type 1: holes distributed in ground. The robot needs to avoid
% stepping in these holes.
%======================
%% Generate abstraction transient system
disp('Start generating transient system...')
%====== Define the system ======
g = 10;
h0 = 1;
A =[0 1;g/h0 0];
B = [0
    -g/h0];
% A = [0 0 1 0;
%      0 0 0 1;
%     g/h0 0 0 0;
%     0 g/h0 0 0];
% B = [0 0
%      0 0
%      -g/h0 0
%      0 -g/h0];
save system A B; % the system dx = Ax + Bu is saved in file system.mat


%======= Test Parameter ========
tau = 0.08;     % time interval
eta = 0.1;
mu = 0.2;
lmax = 1;
dlim = 2.5;
vlim = 4;

r1 = expm(A*tau)*[eta;eta]/2; % the upper bnd of ||x_0(tau)-x_1(tau)||
r = r1;         % radius of norm ball when mapping xt to discr. state space

% ==============================


% === Discretization Config ===
% state space grid size
X.gridsize = eta;   % eta
U.gridsize = mu;   % miu

x1min= -dlim;
x1max= dlim;

% boundaries: i^th row -->  i^th dimension
X.bnd = [           
    -dlim,dlim;
    -vlim,vlim
    ];
% U.bnd = [x1min-lmax,x1max+lmax];
U.bnd = [x1min-lmax,x1max+lmax];
% ================================

% 2 grid generation

% Generating Grid
M_X = GridGener(X);
M_U = GridGener(U);

%% without u_res
u_res = [];
% TransSyst
ts = ArrayGener_parallel(M_X,M_U,tau,r,lmax,u_res);
disp('Done.')
%% Create B_list
disp('Create target set B_list...')
bnd_B = [X.bnd(1,:);
         -2,  2];
B_list = Create_B(bnd_B,M_X);

disp('Done.')
%% Create Z

C_list = {1:2000,500:3000,1000:3200};

A_list = [1:3000];
%% Controller
disp('Compute winning set and controller...')
ts.create_fast();
% [W, C, cont]=ts.win_primal([],B_list',[],'exists','forall');
tic;
[W, ~, cont, V_Compl, K_Compl] = ts.win_primal_patch(A_list, B_list, ... 
                                    C_list, 'exists', 'forall')
t_synthesis = toc;                            
[Vinv, ~, cont_inv] = ts.win_intermediate(uint32(1:ts.n_s), A_list, [], {uint32(1:ts.n_s)}, 1);


if(isempty(W))
    error('No winning set is found!');
end

% save ts_exper

%% with u_res
u_res = [1:20];
% TransSyst
ts = ArrayGener_parallel(M_X,M_U,tau,r,lmax,u_res);
disp('Done.')
%% Controller
disp('Compute winning set and controller...')
ts.create_fast();
% [W, C, cont]=ts.win_primal([],B_list'W,[],'exists','forall');
[W, ~, cont, V_Compl, K_Compl] = ts.win_primal_patch(A_list, B_list, ... 
                                    C_list, 'exists', 'forall')


% save ts_cons
