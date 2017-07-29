%=========Test code=========
% Test controller strategy generation and do simulation for hopping robot
%======================
clear all;clc;close all;
addpath(genpath('./'));
addpath(genpath('../../lib/abstr-ref/'));
addpath('../../lib/GridGener/');
addpath('../../lib/ArrayGener_2D/');


%% Generate abstraction transient system

disp('Start generating transient system...')
%====== Define the system ======
g = 10;
h0 = 1;
% A =[0 1;g/h0 0];
A = [0 1; g/h0 0];
B = [0;-g/h0];
save system A B; % the system dx = Ax + Bu is saved in file system.mat


%======= Test Parameter ========
tau = 0.08;     % time interval
eta = 0.18;
mu = 0.2;
lmax = 1;
dlim = 2.5;
vlim = 4;

r1 = expm(A*tau)*[eta/2;eta/2]; % the upper bnd of ||x_0(tau)-x_1(tau)||
r = r1;         % radius of norm ball when mapping xt to discr. state space
idx_x0 = 20;    % idx of initial cond. in grid (ode solver test)
idx_u0 = 7;    % idx of input in grid       (ode solver test)
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
U.bnd = [x1min-lmax,x1max+lmax];
% ================================


% 2 grid generation

% Generating Grid
M_X = GridGener(X);
M_U = GridGener(U);

%% Visualization
fig = figure;
M_X.visual_bnd(fig,[],'black',2);

hold on;
M_X.visual(fig,1:M_X.numV-1,'.b',8);
axis equal;
%% TransSyst
ts = ArrayGener_parallel(M_X,M_U,tau,r,lmax);

disp('Done.')
%% Create B_list
disp('Create target set B_list...')
bnd_B = [x1min,x1max
         -0.4,  0.4];
B_list = Create_B(bnd_B,M_X);

M_X.visual(fig,B_list,'.r',12);

M_X.visual_bnd(fig,bnd_B,'red',2);

hold on;


disp('Done.')
%% Controller
disp('Compute winning set and controller...')
ts.create_fast();
% tic
[W, C, cont]=ts.win_eventually_or_persistence([],{B_list'},1);
% toc
%%
% Visualization of winning set
M_X.visual(fig,W,'.c',12);

hold on;

title('State Space (Black), B\_list (Red), Winning (Cyan)')
%%
pause;
disp('Press any key...');
close all;
save ts

disp('Done.')
%%
disp('Now please run ''test_control.m''!')
open test_control