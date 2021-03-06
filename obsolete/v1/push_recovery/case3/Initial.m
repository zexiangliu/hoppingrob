%=========Initial=========
% Set up everything for simulation: abstraction system, controller
% Ground Type 2: uneven ground, no holes
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
save system A B; % the system dx = Ax + Bu is saved in file system.mat


%======= Test Parameter ========
tau = 0.08;     % time interval
eta = 0.2;
mu = 0.1;
lmax = 1;
dlim = 2.5;
vlim = 5;
max_leg = sqrt(h0^2+lmax^2)+1.5; % the largest length which the leg can extend

r1 = norm(expm(A*tau),'inf')*eta/2; % the upper bnd of ||x_0(tau)-x_1(tau)||
r = r1+eta/2;         % radius of norm ball when mapping xt to discr. state space

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

bnd = [-5,5;
    -5,5];
num_grid = [5,5];
gnd = Ground(bnd,num_grid,1);

hlim = 1;
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

%% Initial Condition (Push)
fig = figure(1);
gnd.visual_holes(fig);
hold on;
disp('Please select the initial value of x_1 & x_2 on the plot:')
title('Please Select Initial Position')
[x1,x2]=ginput(1); % The initial position of robot in world coordinate

plot(x1,x2,'*r','Markersize',5);

rad = linspace(0,2*pi,100);
plot(vlim*cos(rad)+x1,vlim*sin(rad)+x2);
axis equal;
disp('Please select the initial value of v_1 & v_2 on the plot:')
title('Please Select Initial Velocity')
[v1,v2]=ginput(1); % The initial velocity of robot in world coordinate
v = norm([v1;v2]-[x1;x2]); 
direction = [v1-x1;v2-x2]/v;

x0 = [M_X.discr_bnd(1,1)+M_X.gridsize;v]; % Initial Condition of robot in 1D coordinates (planning coordinate)
idx_x0 = mapping(x0,M_X,eta/2);

% while(x0(1)>=X.bnd(1,1)&&x0(1)<=X.bnd(1,2))
%     if(~ismember(idx_x0,W_ref))
%         x0(1) = x0(1)-M_U.gridsize;
%         idx_x0 = mapping(x0,M_X,eta/2);
%     else
%         break;
%     end
% end


if(idx_x0==size(M_X.ind2sub,1)+1)
    error('error: out of region of interest.');
end

coord_bias = [x1;x2]-x0(1)*direction;
%%
% TransSyst
uconstr.gnd = gnd;
uconstr.direction = direction;
uconstr.coord_bias = coord_bias;


lmax_ub = h0/(h0+hlim)*sqrt(max_leg^2-(h0+hlim)^2); % the upper bound of lmax

if(lmax_ub<lmax)
    lmax=lmax_ub;% make sure that the leg is long enough to reach the ground
end
ts = ArrayGener_uconstr(M_X,M_U,tau,r,lmax,uconstr);
disp('Done.')

%% Controller
disp('Compute winning set and controller...')
ts.create_fast();
[W, C, cont]=ts.win_eventually_or_persistence([],{B_list'},1);

figure(2);
visual(M_X,B_list,bnd_B,W);

disp('Done.')
%%
save ts
disp('Now please run ''test_control.m''!')
open test_control
