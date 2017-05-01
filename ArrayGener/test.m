%=========Test code=========
% Segment 1~3: test each part of ArrayGener(), 
%      grid generation-------GridGener()
%      ode solver
%      mapping the solution xt into discretized state space----mapping()
% Segment 4: test ArrayGener()
%============================
%% Initialization
clc;clear all;close all;

%======= Test Parameter ========
tau = 0.5;     % time interval
r = 1;         % radius of norm ball when mapping xt to discr. state space
x0 = [0;3];    % Initial Cond (ode solver test)
u0 = 0;        % Input        (ode solver test)
% ==============================


% === Discretization Config ===
% state space grid size
X.gridsize = 1;   % eta
U.gridsize = 1;   % miu

% boundaries: i^th row -->  i^th dimension
X.bnd = [           
    -5,5;
    -5,5
    ];
U.bnd = [-1,1];
% ================================

%% grid generation

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
    'EdgeColor','green','FaceColor','none','LineWidth',2)

hold on;
x = linspace(discr_bnd(1,1),discr_bnd(1,2),discr_bnd(1,3));
y = linspace(discr_bnd(2,1),discr_bnd(2,2),discr_bnd(2,3));
[X,Y] = meshgrid(x,y);
plot(X,Y,'.','markersize',8);
axis equal;

%% nonlinear equation solver
y0 = [x0;u0];    % States for numerical integration

yt = ode45(@odefun,[0,tau],y0);
xt = yt.y(1:2,end)

%% mapping: A--->[A]_u
% xt = [1.5;4.5];
idx = mapping(xt,M_X,r);

% Visualization
plot(xt(1),xt(2),'*','markersize',10)
[x1,x2] = ind2sub(M_X.discr_bnd(:,3),idx); % xt

x1 = discr_bnd(1,1)+(x1-1)*u;
x2 = discr_bnd(2,1)+(x2-1)*u;
plot(x1,x2,'.r','markersize',12);    % nodes included

[U,V] = meshgrid([xt(1)-r,xt(1)+r],[xt(2)-r,xt(2)+r]);
f=[1,2,4,3];
v = [U(:),V(:)];
% norm ball
patch('Faces',f,'Vertices',v,...
    'EdgeColor','red','FaceColor','none','LineWidth',2);

%% Wrap everthing up
tic
array = ArrayGener(M_X,M_U,tau,r);
running_time = toc

% Simple Verification
idx_x0 = mapping(x0,M_X,0.5);
idx_u = 2;

idx_ver = find(array{idx_u}(idx_x0,:)==1)';
if(isempty(find((idx~=idx_ver), 1)))
    disp('Verification Pass.');
else
    disp('Verification Fail.');
end