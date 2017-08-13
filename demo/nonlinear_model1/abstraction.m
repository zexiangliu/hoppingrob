%=========Test code=========
% Test controller strategy generation and do simulation for hopping robot
%======================
%% Generate abstraction transient system

disp('Start generating transient system...')
%======= Test Parameter ========
g = 10;
tau = 0.08;     % time interval
eta = [0.18;0.18;0.18;0.18];
mu = [0.2;1];
dlim = 2.5;
vlim = 4;
h0 = 1;
hlim = 0.5;
hvlim = 2;
lmax = 1; % define how much input space is larger than state space
dumax = 5; 
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
    h0-hlim,h0+hlim;
    -vlim,vlim;
    -hvlim,hvlim
    ];
% u1 is position of foot, u2 is force given by foot
U.bnd = [x1min-lmax,x1max+lmax
         g/h0-dumax,g/h0+dumax];
% ================================


% 2 grid generation

% Generating Grid
M_X = GridGener(X);
M_U = GridGener(U);

%% Visualization
fig = figure;
M_X.visual_bnd(fig,[],'black',2,[1;2]);

hold on;
M_X.visual(fig,1:M_X.numV-1,'.b',8,[1;2]);
axis equal;
%% TransSyst

profile on;
ts = ArrayGener_simplified(M_X,M_U,tau,[1;1;1;1],@Aq,@fq,@Dq,@constr_test);
profile viewer

zero = 0;
disp('Done.')
%% Create B_list
disp('Create target set B_list...')
bnd_B = [x1min,x1max;
          h0-hlim,h0+hlim;
         -0.4, 0.4;
         -0.2, 0.2];
B_list = Create_B(bnd_B,M_X);

M_X.visual(fig,B_list,'.r',12,[1,2]);

M_X.visual_bnd(fig,bnd_B,'red',2,[1,2]);

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
disp('Press any key...');
pause;
close all;
save ts

disp('Done.')
