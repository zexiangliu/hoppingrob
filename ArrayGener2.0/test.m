% ===============Test code=====================
% Generate even grid within a irregular region
% =============================================

%% 1 Initialization
clc;clear all;close all;
addpath('../GroundGener/');
addpath(genpath('../abstr-ref/'));

% Please modify the parameter into the path of 'abstr_refinement' in your computer
addpath(genpath('../abstr-refinement/abstr-ref/')); 

%====== Define the system ======
g = 10;
h0 = 1;
A = [0 0 1 0;
     0 0 0 1;
    g/h0 0 0 0;
    0 g/h0 0 0];
B = [0 0
     0 0
     -g/h0 0
     0 -g/h0];
system.g = 10;
system.h0 = h0;
% save system A B; % the system dx = Ax + Bu is saved in file system.mat


%======= Test Parameter ========
tau = 0.08;     % time interval
eta = [0.2;0.1;0.2;0.1]; %gridsize in each dimension
mu = [0.2;0.2];
lmax = 1;
dlim = 2.5;
vlim = 2.5;

r1 = norm(expm(A*tau),'inf')*eta/2; % the upper bnd of ||x_0(tau)-x_1(tau)||
r = r1+eta(1)/2;         % radius of norm ball when mapping xt to discr. state space
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
U.bnd = [x1min-lmax,x1max+lmax
        x1min-lmax,x1max+lmax];
%==========================

%==== Ground Constraints Config ===

bnd = X.bnd(1:2,:);
gridsize = [5,5];
gnd = Ground(bnd,gridsize,1);

gnd.ground_gen_rand(0.0);
for i = 1:1
    gnd.add_hole(0.1,'square')
end

gnd.visual_holes();
hold on;
%==================================

%=== Initial Condition ===
fig = figure(1);
gnd.visual_holes(fig);
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
direction = direction*sign(direction(1));
coord_bias = [x1;x2];
%=========================    


%=== Grid Constraints Config ===
ConsConfig.cons_fun = @constraints;
ConsConfig.angle = 10; % unit: deg
ConsConfig.bias = [0;0];
ConsConfig.rotat = atan2(direction(2),direction(1))*180/pi; % unit: deg
% ================================

%=== Input Constraints Config ===
UConsConfig.ucons_fun = @uconstraints;
% UConsConfig.direction = 0;
UConsConfig.coord_bias = coord_bias;
UConsConfig.gnd=gnd;
%================================
disp('Initialization Done.');
%% 2 grid generation

% Generating Grid
M_X = GridGener(X,ConsConfig);
M_U = GridGener(U,ConsConfig);
disp('Griding Done.');
% Visualization
bnd = M_X.bnd;
u = M_X.gridsize;
discr_bnd = M_X.discr_bnd;
[U,V] = meshgrid(bnd(1,:),bnd(2,:));
f=[1,2,4,3];
figure(1);
v = [U(:),V(:)];
patch('Faces',f,'Vertices',v,...
    'EdgeColor','green','FaceColor','none','LineWidth',2)

hold on;
[x1,x2] = get_coord(1:length(M_X.ind2sub),M_X);
plot(x1+coord_bias(1),x2+coord_bias(2),'.')

axis equal;
xlabel('x_1');ylabel('x_2');
disp('Visualization Done.');
%% 6 Test ArrayGener_ts 
% store the transist system in class 'TransSyst'
% add progress group in ArrayGener_ts.m
NP = 4;
thePool = parpool('local',4);
ts = ArrayGener(M_X,M_U,tau,lmax,UConsConfig,system);
delete(thePool);
disp('Abstraction Done.');

%% 7 find target set B_list



















