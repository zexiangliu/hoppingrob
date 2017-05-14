%=========Test code=========
% Segment 2~4: test each part of ArrayGener(), 
%      grid generation-------GridGener()
%      ode solver
%      mapping the solution xt into discretized state space----mapping()
% Segment 5: test ArrayGener()
% Segment 6: test ArrayGener_ts()
    % transfer the array into struct of TransSyst.m
    % add progress group for linear case
%======================
%% 1 Initialization
clc;clear all;close all;

% Please modify the parameter into the path of 'abstr_refinement' in your computer
addpath(genpath('../abstr-refinement/abstr-ref/')); 

%====== Define the system ======
g = 10;
h0 = 1;
% A =[0 1;g/h0 0];
A = [0 1; g/h0 0];
B = [0;-g/h0];
save system A B; % the system dx = Ax + Bu is saved in file system.mat


%======= Test Parameter ========
tau = 0.08;     % time interval
eta = 0.2;
mu = 0.2;
lmax = 1;
dlim = 2.5;
vlim = 2.5;

r1 = norm(expm(A*tau),'inf')*eta/2; % the upper bnd of ||x_0(tau)-x_1(tau)||
r = r1+eta/2;         % radius of norm ball when mapping xt to discr. state space
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
ts = ArrayGener_ts(M_X,M_U,tau,r);
%% 2 grid generation

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

%% Testing for array generation
% %% 3 nonlinear equation solver
% sub_x0 = M_X.ind2sub(idx_x0,:);     % subscripts of x0
% x0 = [M_X.V{1}(sub_x0(1));M_X.V{2}(sub_x0(2))];    % initial cond.
% sub_u0 = M_U.ind2sub(idx_u0);
% u0 = M_U.V{1}(sub_u0);                 % input
% 
% y0 = [x0;u0];    % States for numerical integration
% 
% yt = ode45(@odefun,[0,tau],y0);
% xt = yt.y(1:2,end)
% 
% %% 4 mapping: A--->[A]_u
% % xt = [1.5;4.5];
% idx = mapping(xt,M_X,r);
% 
% % Visualization
% plot(xt(1),xt(2),'*','markersize',10)
% [x1,x2] = ind2sub(M_X.discr_bnd(:,3),idx); % xt
% 
% x1 = discr_bnd(1,1)+(x1-1)*u;
% x2 = discr_bnd(2,1)+(x2-1)*u;
% plot(x1,x2,'.r','markersize',12);    % nodes included
% 
% [U,V] = meshgrid([xt(1)-r,xt(1)+r],[xt(2)-r,xt(2)+r]);
% f=[1,2,4,3];
% v = [U(:),V(:)];
% % norm ball
% patch('Faces',f,'Vertices',v,...
%     'EdgeColor','red','FaceColor','none','LineWidth',2);

%%% 5 Wrap everthing up (task 1)
% tic
% array = ArrayGener(M_X,M_U,tau,r);
% running_time = toc
% 
% % Simple Verification
% idx_x0 = mapping(x0,M_X,0.001);
% idx_u = idx_u0;
% 
% idx_ver = find(array{idx_u}(idx_x0,:)==1)';
% if(isempty(find((idx~=idx_ver), 1)))
%     disp('Verification Pass.');
% else
%     disp('Verification Fail.');
% end

%% 6 Test ArrayGener_ts 
% store the transist system in class 'TransSyst'
% add progress group in ArrayGener_ts.m
ts = ArrayGener_ts(M_X,M_U,tau,r);

%% 7 find target set B_list



















