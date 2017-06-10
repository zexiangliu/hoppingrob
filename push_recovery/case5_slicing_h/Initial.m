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
addpath(genpath('../'));
addpath(genpath('../../abstr-ref/'));
addpath('../../ArrayGener2.0/');
% addpath('../../Simu_2D');
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
lmax = 1;
dlim = 2.5;
vlim = 4;
max_leg = sqrt(h0^2+lmax^2)+0.5; % the largest length which the leg can extend
hlim = 0.15;

eta = [(g/h0-g/(h0+hlim))/20;0.1;0.2];
mu = 0.2;

% ==============================


% === Discretization Config ===
% state space grid size
X.gridsize = eta;   % eta
U.gridsize = mu;   % miu

x1min= -dlim;
x1max= dlim;

% boundaries: i^th row -->  i^th dimension
X.bnd = [%g/h0,g/h0
     g/(h0+hlim),g/h0
    -dlim,dlim;
    -vlim,vlim
    ];
U.bnd = [x1min-lmax,x1max+lmax];

% ================================

% 2 grid generation
ConsConfig.cons_fun = @cons_fun;
% Generating Grid
M_X = GridGener(X,ConsConfig);
M_U = GridGener(U,ConsConfig);
save visual_set.mat M_X
%% Initialize the map

bnd = [-10,10;
    -10,10];
bnd_visual = [-5,5;
             -5,5];
num_grid = [10,10];
gnd = Ground(bnd,num_grid,1,bnd_visual);

[map_X,map_Y,map_V]=gnd.ground_gen_rand(hlim);

% approximate the maximum gradient of the ground
[px,py] = gradient(map_V);
size_grid = [map_X(1,3)-map_X(1,2);map_Y(3,1)-map_Y(2,1)];
px = px/size_grid(1);
py = py/size_grid(2);
dhdx_max = hlim/(20/9);%max(sqrt(px(:).^2 + py(:).^2));
% num_holes = input('Please input the number of holes:');
% for i = 1:num_holes
%     disp('Please select the position of hole in the figure:')
%     gnd.add_hole(0.2,'circle')
% end

 
%% Create B_list
disp('Create target set B_list...')
bnd_B = [M_X.bnd(1,:);
        M_X.bnd(2,:);
         -1.4,  1.4];
B_list = Create_B(bnd_B,M_X);

% for i = 1:length(B_list)
%     tmp_x = get_coord(B_list(i),M_X);
%     tmp_x = tmp_x(1)*direction+coord_bias;
%     if(gnd.IsInHoles(tmp_x))
%         B_list(i)=-1;
%     end
% end
% B_list(B_list==-1)=[];
visual_set(M_X,B_list,[2;3])
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
uconstr.dhdx = dhdx_max;
% specify_num_workers(4);
ts = ArrayGener(M_X,M_U,tau,lmax,uconstr);
disp('Done.')
%%
visual_set(M_X,ts.state1(ts.state2==M_X.numV),[2;3])


%% Controller
disp('Compute winning set and controller...')
ts.create_fast();
[W, C, cont]=ts.win_eventually_or_persistence([],{B_list'},1);
W
visual_set(M_X,W,[2;3],'c')
% figure(2);
% visual(M_X,B_list,bnd_B,W);
% 
% disp('Done.')
%%
clear fig
save('ts','-v7.3')
disp('Now please run ''test_control.m''!')
open test_control
