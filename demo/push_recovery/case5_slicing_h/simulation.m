% Test push_recovery
% Information of holes is considered when 1D planning

%% run Initial.m first.
close all; clear all; clc;
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

x0 = [M_X.discr_bnd(2,1)+M_X.gridsize(2);v]; % Initial Condition of robot in 1D coordinates (planning coordinate)

coord_bias = [x1;x2]-x0(1)*direction;

figure(2);
disp('Please select the initial position of the foot:');
plot([-lmax;lmax],[0;0],'-o');
grid on;
title('Please select the initial position of the foot:');

[u0_1d,~]=ginput(1);
u0 = u0_1d*direction+coord_bias;
c0 = g/(h0-gnd.get_height(u0(1),u0(2)));
idx_z0 = mapping([c0;x0],M_X,[0;0;0]);

% while(x0(1)>=X.bnd(1,1)&&x0(1)<=X.bnd(1,2))
%     if(~ismember(idx_x0,W_ref))
%         x0(1) = x0(1)-M_U.gridsize;
%         idx_x0 = mapping(x0,M_X,eta/2);
%     else
%         break;
%     end
% end


if(idx_z0==M_X.numV+1)
    error('error: out of region of interest.');
end

hold off;
%% Initialization

idx_z = idx_z0;
xt = [coord_bias+x0(1)*direction;x0(2)*direction];
x_proj = x0;
c = c0;

idx_u = mapping(u0,M_U,0);
X_list = [idx_z];
U_list = [idx_u];
t_list = [0];

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
t_span = 400;
for i = 1:t_span
    % visual (on the grid)
    % get the options of input 
%     disp(idx_x)
    u_option = cont.get_input(idx_z);
        % keep the same input if not necessary
    if(i==1||i>=2&&~ismember(U_list(end),u_option))
        for j = 1:length(u_option)
            idx_u = u_option(j);
            u0 = get_coord(M_U,idx_u)*direction+coord_bias; 
            if(~gnd.IsInHoles(u0))
                break;
            end
        end
        if(gnd.IsInHoles(u0))
            warning('No feasible input.');
            break;
        end
    end
%     disp('u is:')
%     get_coord(idx_u,M_U)
%     disp('x is:')
%     x_proj
    
    h = h0-gnd.get_height(u0(1),u0(2));
    c = g/h;
    A = [0 0 1 0;
         0 0 0 1;
        c 0 0 0;
        0 c 0 0];
    B = [0 0
         0 0
        -c 0
        0 -c];
%     u0 = get_coord(idx_u,M_U)*direction + coord_bias;    % get the coordinate of input
    xt =[x_proj(1)*direction+coord_bias;x_proj(2)*direction];
    y0 = [xt;u0];    % States for numerical integration
    norm((y0(1:2)-coord_bias)'*direction*direction-y0(1:2)+coord_bias)
    norm(y0(3:4)'*direction*direction-y0(3:4))
    yt = ode45(@odefun2,[0,tau],y0);
    
    xt = yt.y(1:4,end); % destination in one step
    x_proj = [xt(1:2)'-coord_bias';xt(3:4)']*direction; % project xt into the line
    idx_z  = mapping([c;x_proj],M_X,[0;0;0]);
    if(idx_z == 40001)
        keyboard();
    end
    X_list = [X_list;idx_z]; % history of idx_x
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
fig = figure(2);
visual_all(fig,M_X,B_list,bnd_B,W,[2;3]);

traj_anim(fig,M_X,X_list,[2;3],0.01);

disp('Press any key to conitue...');
pause;
