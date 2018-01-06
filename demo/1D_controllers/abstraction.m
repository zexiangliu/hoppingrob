function abstraction(dlim,vlim,vflag)
%=========Initial=========
% Set up everything for simulation: abstraction system, controller
% Ground Type 1: holes distributed in ground. The robot needs to avoid
% stepping in these holes.
%======================
if(nargin == 2)
    vflag=1; % enable visualization
end
%% Generate abstraction transient system
disp('Start generating transient system...')
%====== Define the system ======
g = 10;
h0 = 1;
A =[0 1;g/h0 0];
B = [0
    -g/h0];

save system A B; % the system dx = Ax + Bu is saved in file system.mat


%======= Test Parameter ========
tau = 0.08;     % time interval
eta = 0.1;
mu = 0.2;
lmax = 1;
% dlim = 2.5;
% vlim = 4;

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
U.bnd = [x1min,x1max];
% ================================

% 2 grid generation

% Generating Grid
M_X = GridGener(X);
M_U = GridGener(U);

if(vflag)
    % Visualization
    fig = figure;
    M_X.visual_bnd(fig,[],'black',2);

    hold on;
    M_X.visual(fig,1:M_X.numV-1,'.b',8);
    axis equal;
end

%% without u_res
% TransSyst
ts = ArrayGener_parallel(M_X,M_U,tau,r,lmax);
disp('Done.')
%% Create B_list
disp('Create target set B_list...')
bnd_B = [X.bnd(1,:);
         -0.4,  0.4];
B_list = Create_B(bnd_B,M_X);

if(vflag)
    % Visualization of the target set
    M_X.visual(fig,B_list,'.r',12);
    M_X.visual_bnd(fig,bnd_B,'red',2);
end

hold on;

disp('Done.')
%% Controller
disp('Compute winning set and controller...')
ts.create_fast();
[W, C, cont]=ts.win_eventually_or_persistence([],{B_list'},1);

%%
if(vflag)
    % Visualization of winning set
    fig = figure(2);
    M_X.visual(fig,W,'.c',12);

    title('State Space (Black), B\_list (Red), Winning (Cyan)')
    disp('Press any key to continue...');
    pause;
    close all;
end
save ts_ref

disp('Done.')
