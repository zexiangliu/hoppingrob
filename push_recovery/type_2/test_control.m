% Test push_recovery
% Ground Type I: only holes
% Information of holes is considered when 1D planning

%% run Initial.m first.
% close all; clear all; clc;

% load ts

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

% figure(1);
% rad = linspace(0,2*pi,100);
% plot(vlim*cos(rad),vlim*sin(rad));
% axis equal;
% grid on;
% xlabel('v_1');
% ylabel('v_2');
% 
% figure(2);
% visual(M_X,B_list,bnd_B,W);
% xlabel('x_2');
% ylabel('v_2');


%% Initialization
% select the initial condition of x0(1)
% while(x0(1)>=X.bnd(1,1)&&x0(1)<=X.bnd(1,2))
%     if(~ismember(idx_x0,W))
%         x0(1) = x0(1)-M_U.gridsize;
%         idx_x0 = mapping(x0,M_X,eta/2);
%     else
%         break;
%     end
% end


% for i = 1:length(M_X.V{1})
%     x0 = [M_X.V{1}(i);v];
%     idx_x0 = mapping(x0,M_X,eta/2);
%     if(ismember(idx_x0_1,W1))
%         break;
%     end
% end
% x0 = W(1);


idx_x = idx_x0(1);
xt = [coord_bias+x0(1)*direction;x0(2)*direction];

idx_u = 0;
X_list = [idx_x0];
U_list = [];
t_list = [];

Yt_list=[]; % record ode solution for animation
Yx_list=[]; % record ode solution for animation
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
    
%     u0 = get_coord(idx_u,M_U)*direction + coord_bias;    % get the coordinate of input
    y0 = [xt;u0];    % States for numerical integration
    
    yt = ode45(@odefun,[0,tau],y0);
    
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
figure(2);
visual(M_X,B_list,bnd_B,W);

[x1,x2] = get_coord(X_list,M_X);
for i=1:length(x1)-1
    arrow('Start',[x1(i),x2(i)],'Stop',[x1(i+1),x2(i+1)],'Length',10,'TipAngle',5)
    pause(0.01);
end

%% Animation based on Plot
disp('Animation 1:')
animation
