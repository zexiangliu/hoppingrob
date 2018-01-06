% Simulation of the hopping robot
%% run test.m first.
close all; clear all; clc;

load ts

A = [0 0 1 0;
     0 0 0 1;
    g/h0 0 0 0;
    0 g/h0 0 0];
B = [0 0
     0 0
     -g/h0 0
     0 -g/h0];
save system A B; % the system dx = Ax + Bu is saved in file system.mat

%% Visualization and get initial condition from mouse

fig = figure(1);
visual_all(fig,M_X1,B_list1,bnd_B1,W1);
xlabel('x_1');
ylabel('v_1');

fig = figure(2);
visual_all(fig,M_X2,B_list2,bnd_B2,W2);
xlabel('x_2');
ylabel('v_2');


%% Initialization
% initial state 
figure(1)
disp('Please select the initial value of x_1 & v_1 on the plot:')
[x1,v1]=ginput(1);
figure(2)
disp('Please select the initial value of x_1 & v_1 on the plot:')
[x2,v2]=ginput(1);

% x=-1.4;
% y=-4.5;
x0 = [x1;x2;v1;v2];
idx_x0_1 = mapping(x0([1,3]),M_X1,M_X1.gridsize*0);
idx_x0_2 = mapping(x0([2,4]),M_X2,M_X2.gridsize*0);
if(~ismember(idx_x0_1,W1)||~ismember(idx_x0_2,W2))
    error('x0 is beyond winning set.');
end
% x0 = W(1);

figure(1)
[x1,x2] = get_coord(M_X1,idx_x0_1)
plot(x1,x2,'xb','markersize',10)


figure(2)
[x1,x2] = get_coord(M_X2,idx_x0_2)
plot(x1,x2,'xb','markersize',10)


idx_x1 = idx_x0_1;
idx_x2 = idx_x0_2;
xt = [x0];

idx_u = 0;
X1_list = [idx_x0_1];
X2_list = [idx_x0_2];
U1_list = [];
U2_list = [];
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
    u_option1 = cont1.get_input(idx_x1);
    u_option2 = cont2.get_input(idx_x2);
        % keep the same input if not necessary
    if(i==1||i>=2&&~ismember(U1_list(end),u_option1))
        idx_u1 = u_option1(1);
    end
    
    if(i==1||i>=2&&~ismember(U2_list(end),u_option2))
        idx_u2 = u_option2(1);
    end
    
    u0 = [get_coord(M_U1,idx_u1);get_coord(M_U2,idx_u2)];    % get the coordinate of input
    y0 = [xt;u0];    % States for numerical integration
    
    yt = ode45(@odefun,[0,tau],y0);
    
    xt = yt.y(1:4,end); % destination in one step
    idx_x1  = mapping(xt([1,3]),M_X1,M_X1.gridsize*0);
    idx_x2  = mapping(xt([2,4]),M_X2,M_X2.gridsize*0);
    X1_list = [X1_list;idx_x1]; % history of idx_x
    X2_list = [X2_list;idx_x2]; % history of idx_x
    U1_list = [U1_list;idx_u1]; % history of idx_u
    U2_list = [U2_list;idx_u2]; % history of idx_u
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

    figure(3);
    hold on;
    plot((i-1)*tau+yt.x,yt.y(1,:),'-'); % position red
    plot((i-1)*tau+yt.x,yt.y(2,:),'-'); % velocity blue
    plot((i-1)*tau+yt.x,yt.y(3,:),'-'); % position red
    plot((i-1)*tau+yt.x,yt.y(4,:),'-'); % position red
    drawnow;
end
disp('Done.');

legend('Vel of Mass Center','Pos of Mass Center');
xlabel('t');
%% Trajectory in state space
disp('Trajectory:')
fig = figure(1);

traj_anim(fig,M_X1,X1_list);

figure(2);

traj_anim(fig,M_X2,X2_list);
