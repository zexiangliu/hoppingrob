%=========Initial=========
% Set up everything for simulation: abstraction system, controller
% Ground Type 2: uneven ground + Ground Type 1: holes
% No change of robot model. Map the real input to the input used in
% model
% Make sure that the input constraints satifies by shrinking lmax
% decouple the lmax and the maximum length of leg, that is, the maximum
% length of leg only decides the upper bound of lmax
%======================

%% Generate abstraction transient system
clear all;clc;close all;
addpath('../');
addpath(genpath('../ground_gen'));
addpath(genpath('../../abstr-ref/'));
addpath('../../ArrayGener/');
addpath('../../Simu_2D');
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
save system g h0 A B; % the system dx = Ax + Bu is saved in file system.mat


%======= Test Parameter ========
tau = 0.08;     % time interval
eta = 0.1;
mu = 0.1;
lmax = 1;
dlim = 2.5;
vlim = 5;
max_leg = sqrt(h0^2+lmax^2)+0.5; % the largest length which the leg can extend

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

%% Initialize the map

bnd = [-10,10;
    -10,10];
bnd_visual = [-5,5;
             -5,5];
num_grid = [10,10];
gnd = Ground(bnd,num_grid,1,bnd_visual);

hlim = 0.15;
[map_X,map_Y,map_V]=gnd.ground_gen_rand(hlim);

% num_holes = input('Please input the number of holes:');
% for i = 1:num_holes
%     disp('Please select the position of hole in the figure:')
%     gnd.add_hole(0.2,'circle')
% end

 
%% Create B_list
disp('Create target set B_list...')
bnd_B = [X.bnd(1,:);
         -0.4,  0.4];
B_list = Create_B(bnd_B,M_X);

% for i = 1:length(B_list)
%     tmp_x = get_coord(B_list(i),M_X);
%     tmp_x = tmp_x(1)*direction+coord_bias;
%     if(gnd.IsInHoles(tmp_x))
%         B_list(i)=-1;
%     end
% end
% B_list(B_list==-1)=[];
disp('Done.')

%% Calculate reference abstraction system
% the ref system is used to decide the position of x0 in coordinate of 1D
% planning, since the maximum of v0 is different when x0 is different.

% Please uncomment the following  when you modify the parameters of abstraction
%{
ts_ref = ArrayGener_parallel(M_X,M_U,tau,r,lmax);
ts_ref.create_fast();
[W_ref, ~, ~]=ts_ref.win_eventually_or_persistence([],{B_list'},1);
%}
% Please comment the following line when you modify the parameters of abstraction
% load W_ref;


%%
% TransSyst
uconstr.gnd = gnd;
uconstr.direction = [0;0];
uconstr.coord_bias = [0;0];
uconstr.max_leg = max_leg;
uconstr.eta = eta;
uconstr.hlim = hlim;
specify_num_workers(4);
ts = ArrayGener(M_X,M_U,tau,lmax,uconstr);
disp('Done.')

%% Controller
disp('Compute winning set and controller...')
ts.create_fast();
[W, C, cont]=ts.win_eventually_or_persistence([],{B_list'},1);

figure(2);
visual(M_X,B_list,bnd_B,W);

disp('Done.')
%%
clear fig
save ts
disp('Now please run ''test_control.m''!')
open test_control
