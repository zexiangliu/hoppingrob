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

% Visualization
bnd = M_X.bnd;
u = M_X.gridsize;
discr_bnd = M_X.discr_bnd;
[U,V] = meshgrid(bnd(1,:),bnd(2,:));
f=[1,2,4,3];
v = [U(:),V(:)];
patch('Faces',f,'Vertices',v,...
    'EdgeColor','black','FaceColor','none','LineWidth',2)

hold on;
x = linspace(discr_bnd(1,1),discr_bnd(1,2),discr_bnd(1,3));
y = linspace(discr_bnd(2,1),discr_bnd(2,2),discr_bnd(2,3));
[X,Y] = meshgrid(x,y);
plot(X,Y,'.b','markersize',8);
axis equal;
%%
% TransSyst
ts = ArrayGener_parallel(M_X,M_U,tau,r,lmax);

disp('Done.')
%% Create B_list
disp('Create target set B_list...')
bnd_B = [x1min,x1max
         -0.4,  0.4];
B_list = Create_B(bnd_B,M_X);

% Visualization of the target set
[x1,x2] = get_coord(M_X,B_list);
plot(x1,x2,'.r','markersize',12);    % nodes included

[U,V] = meshgrid([bnd_B(1,:)],[bnd_B(2,:)]);
f=[1,2,4,3];
v = [U(:),V(:)];
% norm ball
patch('Faces',f,'Vertices',v,...
    'EdgeColor','red','FaceColor','none','LineWidth',2);

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
[x1,x2] = get_coord(M_X,W);
plot(x1,x2,'.c','markersize',12);    % nodes included

[U,V] = meshgrid([bnd_B(1,:)],[bnd_B(2,:)]);
f=[1,2,4,3];
v = [U(:),V(:)];

title('State Space (Black), B\_list (Red), Winning (Cyan)')

save ts


disp('Done.')
%%
disp('Now please run ''test_control.m''!')
open test_control