%=========Test code=========
% Test controller strategy generation and do simulation for hopping robot
%======================

%% Generate abstraction transient system
clear all;clc;close all;
addpath(genpath('./'));
addpath(genpath('../abstr-ref/'));
addpath('../ArrayGener/');

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
mu = 0.2;
lmax = 1.5;
dlim = 2.5;
vlim = 5;

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
    -dlim,dlim;
    -vlim,vlim;
    -vlim,vlim
    ];
U.bnd = [x1min-lmax,x1max+lmax;
    x1min-lmax,x1max+lmax];

% divide the original system into two subsystem
X1 = X;
X1.bnd = X.bnd([1,3],:);
X2 = X;
X2.bnd = X.bnd([2,4],:);
U1 = U;
U1.bnd = U.bnd(1,:);
U2 = U;
U2.bnd = U.bnd(2,:);
% ================================

% 2 grid generation

% Generating Grid
% M_X = GridGener(X);
% M_U = GridGener(U);

M_X1 = GridGener(X1);
M_X2 = GridGener(X2);
M_U1 = GridGener(U1);
M_U2 = GridGener(U2);
% Visualization
% bnd = M_X.bnd;
% u = M_X.gridsize;
% discr_bnd = M_X.discr_bnd;
% [U,V] = meshgrid(bnd(1,:),bnd(2,:));
% f=[1,2,4,3];
% v = [U(:),V(:)];
% patch('Faces',f,'Vertices',v,...
%     'EdgeColor','black','FaceColor','none','LineWidth',2)
% 
% hold on;
% x = linspace(discr_bnd(1,1),discr_bnd(1,2),discr_bnd(1,3));
% y = linspace(discr_bnd(2,1),discr_bnd(2,2),discr_bnd(2,3));
% [X,Y] = meshgrid(x,y);
% plot(X,Y,'.b','markersize',8);
% axis equal;
%%
% TransSyst
ts1 = ArrayGener_parallel(M_X1,M_U1,tau,r,lmax/sqrt(2));
ts2 = ArrayGener_parallel(M_X2,M_U2,tau,r,lmax/sqrt(2));
disp('Done.')
%% Create B_list
disp('Create target set B_list...')
bnd_B = [-0.8,0.8
    -0.8,0.8
         -1.5,  1.5
         -1.5,  1.5];
bnd_B1 = bnd_B([1,3],:);
bnd_B2 = bnd_B([2,4],:);
B_list1 = Create_B(bnd_B1,M_X1);
B_list2 = Create_B(bnd_B2,M_X2);
% Visualization of the target set
% [x1,x2] = get_coord(B_list,M_X);
% plot(x1,x2,'.r','markersize',12);    % nodes included
% 
% [U,V] = meshgrid([bnd_B(1,:)],[bnd_B(2,:)]);
% f=[1,2,4,3];
% v = [U(:),V(:)];
% % norm ball
% patch('Faces',f,'Vertices',v,...
%     'EdgeColor','red','FaceColor','none','LineWidth',2);
% 
% hold on;


disp('Done.')
%% Controller
disp('Compute winning set and controller...')
ts1.create_fast();
ts2.create_fast();
[W1, C1, cont1]=ts1.win_eventually_or_persistence([],{B_list1'},1);
[W2, C2, cont2]=ts2.win_eventually_or_persistence([],{B_list2'},1);
%%
% Visualization of winning set
% [x1,x2] = get_coord(W,M_X);
% plot(x1,x2,'.c','markersize',12);    % nodes included
% 
% [U,V] = meshgrid([bnd_B(1,:)],[bnd_B(2,:)]);
% f=[1,2,4,3];
% v = [U(:),V(:)];
% 
% title('State Space (Black), B\_list (Red), Winning (Cyan)')

save ts


disp('Done.')
%%
disp('Now please run ''test_control.m''!')
open test_control
