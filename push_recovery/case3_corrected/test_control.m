% Test push_recovery
% Information of holes is considered when 1D planning

%% run Initial.m first.
close all; clear all; clc;

if(exist('ArrayGener_ts','file')~=2)
    addpath('../');
    addpath(genpath('../ground_gen'));
    addpath(genpath('../../abstr-ref/'));
    addpath('../../ArrayGener/');
    addpath('../../Simu_2D');
end

disp('Start generating transient system...')

load ts
global A B


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
hold off;
%% Initialization

idx_x = idx_x0(1);
xt = [coord_bias+x0(1)*direction;x0(2)*direction];

idx_u = 0;
X_list = [idx_x0];
U_list = [];
t_list = [];

Yt_list=[]; % record ode solution for animation
Yx_list=[]; % record ode solution for animation

% show initial conditions
figure(1);
hold off;
plot(xt(1),xt(2),'*r','markersize',10);
hold on;
arrow('Start',[xt(1),xt(2)],'Stop',[xt(3)+xt(1),xt(4)+xt(2)],'Length',50,'TipAngle',5)
grid on;
hold off;
axis([gnd.bnd_visual(1,:),gnd.bnd_visual(2,:)]);
title('Initial Position and Velocity of the Robot')
disp('Press any key to conitue...');
pause;
%% hopping
disp('Simulating...');
t_span = 50;
for i = 1:t_span
    % visual (on the grid)
    % get the options of input 
%     disp(idx_x)
    u_option = cont.get_input(idx_x);
        % keep the same input if not necessary
    if(i==1||i>=2&&~ismember(U_list(end),u_option))
        for j = 1:length(u_option);
            idx_u = u_option(j);
            u0 = get_coord(idx_u,M_U)*direction+coord_bias; 
            if(~gnd.IsInHoles(u0))
                break;
            end
        end
        if(gnd.IsInHoles(u0))
            warning('No feasible input.');
            break;
        end
    end
    
    h = h0-gnd.get_height(u0(1),u0(2));
    A = [0 0 1 0;
         0 0 0 1;
        g/h 0 0 0;
        0 g/h 0 0];
    B = [0 0
         0 0
        -g/h 0
        0 -g/h];
%     u0 = get_coord(idx_u,M_U)*direction + coord_bias;    % get the coordinate of input
    y0 = [xt;u0];    % States for numerical integration
    
    yt = ode45(@odefun2,[0,tau],y0);
    
    xt = yt.y(1:4,end); % destination in one step
    x_proj = [xt(1:2)'-coord_bias';xt(3:4)']*direction; % project xt into the line
    idx_x  = mapping(x_proj,M_X,eta/2);
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

    figure(3);
    hold on;
    plot((i-1)*tau+yt.x,yt.y(1:2,:)'*direction-coord_bias'*direction,'-r'); % position red
    plot((i-1)*tau+yt.x,yt.y(3:4,:)'*direction,'-b'); % velocity blue
    drawnow;
end
disp('Done.');

legend('Pos of Mass Center','Vel of Mass Center');
xlabel('t');
%% Trajectory in state space
disp('Press any key to conitue...');
pause;
disp('Trajectory:')
figure(2);
visual(M_X,B_list,bnd_B,W);

[x1,x2] = get_coord(X_list,M_X);
for i=1:length(x1)-1
    arrow('Start',[x1(i),x2(i)],'Stop',[x1(i+1),x2(i+1)],'Length',10,'TipAngle',5)
    pause(0.01);
end
disp('Press any key to conitue...');
pause;
%% Animation based on Plot
disp('Animation 1:')
animation
