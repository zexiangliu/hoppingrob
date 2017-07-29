% Simulation of the hopping robot
%% run test.m first.
close all; clear all; clc;
addpath('../../lib/SimuAndAnim/');
load ts

%% Visualization and get initial condition from mouse

fig = figure(1);
title('State Space (Black), B\_list (Red), Winning Set (Cyan)')
% Visualization of state space

M_X.visual_bnd(fig, [], 'black', 2);
hold on;
M_X.visual(fig,1:M_X.numV-1,'.b',8);
axis equal;

% Visualization of the target set
M_X.visual(fig,B_list,'.r',12);
M_X.visual_bnd(fig,bnd_B,'red',2);

% Visualization of winning set
M_X.visual(fig,W,'.c',12);

%% Initialization
% constants
eta = M_X.gridsize;
% initial state 
disp('Please select the initial point on the plot:')
[x,y]=ginput(1);
% x=-1.4;
% y=-4.5;
x0 = [x;y];
idx_x0 = mapping(x0,M_X, M_X.gridsize/2*0);
if(~ismember(idx_x0,W))
    error('x0 is beyond winning set.');
end
% x0 = W(1);

[x1,x2] =get_coord(M_X,idx_x0)
plot(x1,x2,'xb','markersize',10)

idx_x = idx_x0;
xt = [x0];

idx_u = 0;
X_list = [idx_x0];
U_list = [];
t_list = [];

Yt_list=[]; % record ode solution for animation
Yx_list=[]; % record ode solution for animation
%% hopping
disp('Simulating...');
t_span = 60;
for i = 1:t_span
    % visual (on the grid)
    % get the options of input 
%     disp(idx_x)
    u_option = cont.get_input(idx_x);
    % keep the same input if not necessary
    if(i==1||i>=2&&~ismember(U_list(end),u_option))
        idx_u = u_option(1);
    end
     
    u0 = get_coord(M_U,idx_u);    % get the coordinate of input
    y0 = [xt;u0];    % States for numerical integration
    
    yt = ode45(@odefun,[0,tau],y0);
    
    xt = yt.y(1:2,end); % destination in one step
    idx_x  = mapping(xt,M_X,eta/2*0);
    X_list = [X_list;idx_x]; % history of idx_x
    U_list = [U_list;idx_u]; % history of idx_u
    t_list = [t_list;i*tau];
    
    Yt_list = [Yt_list, (i-1)*tau + yt.x]; % time
    Yx_list = [Yx_list, yt.y]; % state
    % visual (time)
    
%     figure(1);
%     [x1,x2] = get_coord(idx_x,M_X);
%     plot(x1,x2,'xb','markersize',10);
%     hold on;
%     pause(0.2);
%     drawnow

    figure(2);
    plot((i-1)*tau+yt.x,yt.y(1,:),'r-'); % position red
    plot((i-1)*tau+yt.x,yt.y(2,:),'b-'); % velocity blue
    hold on;
    drawnow;
end
disp('Done.');

legend('Vel of Mass Center','Pos of Mass Center');
xlabel('t');
%% Trajectory in state space
disp('Trajectory:')
fig = figure(1);

traj_anim(fig,M_X,X_list);
%% Animation based on Plot
disp('Animation 1:')
animation

%% Animation based on Simulink
disp('Animation 2:')
u_list = get_coord(U_list,M_U);

save cont t_list u_list % used as input in simulink
len_leg1=h0/2;
len_leg2=sqrt(h0^2+(x1max-x1min+lmax)^2);
C = [1,0];
D=[0];
fre_hopping = pi/2/tau;
% u_list = zeros(ts.n_s,1);
% for i = 1:length(W)
%     tmp=cont.get_input(W(i));
%     u_list(W(i))=get_coord(tmp(1),M_U);
% end
% M_X.V = [];

% save cont u_list M_X
hopping_robot_R2012b