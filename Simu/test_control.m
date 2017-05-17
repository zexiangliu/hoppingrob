% Simulation of the hopping robot
%% run test.m first.
close all; clear all; clc;

load ts

%% Visualization and get initial condition from mouse
figure(1);

title('State Space (Black), B\_list (Red), Winning Set (Cyan)')
% Visualization of state space
bnd = M_X.bnd;
u = M_X.gridsize;
discr_bnd = M_X.discr_bnd;
[U,V] = meshgrid(bnd(1,:),bnd(2,:));
f=[1,2,4,3];
v = [U(:),V(:)];
patch('Faces',f,'Vertices',v,...
    'EdgeColor','black','FaceColor','none','LineWidth',2)

hold on;
x = linspace(discr_bnd(1,1),discr_bnd(1,2),discr_bnd(1,3));
y = linspace(discr_bnd(2,1),discr_bnd(2,2),discr_bnd(2,3));
[X,Y] = meshgrid(x,y);
plot(X,Y,'.b','markersize',8);
axis equal;
% Visualization of the target set
[x1,x2] = get_coord(B_list,M_X);
plot(x1,x2,'.r','markersize',12);    % nodes included

[U,V] = meshgrid([bnd_B(1,:)],[bnd_B(2,:)]);
f=[1,2,4,3];
v = [U(:),V(:)];
% norm ball
patch('Faces',f,'Vertices',v,...
    'EdgeColor','red','FaceColor','none','LineWidth',2);

% Visualization of winning set
[x1,x2] = get_coord(W,M_X);
plot(x1,x2,'.c','markersize',12);    % nodes included

[U,V] = meshgrid([bnd_B(1,:)],[bnd_B(2,:)]);
f=[1,2,4,3];
v = [U(:),V(:)];

%% Initialization
% initial state 
disp('Please select the initial point from winning set using mouse:')
[x,y]=ginput(1);
% x=-1.4;
% y=-4.5;
x0 = mapping([x;y],M_X,eta/2);
if(~ismember(x0,W))
    error('x0 is not in winning set.');
end
% x0 = W(1);

[x1,x2] =get_coord(x0,M_X)
plot(x1,x2,'xb','markersize',10)

idx_x = x0;
[x1,x2] = get_coord(idx_x,M_X);
xt = [x1;x2];

idx_u = 0;
X_list = [idx_x];
U_list = [];
%% hopping
for i = 1:50
    % visual (on the grid)
    % get the options of input 
    disp(idx_x)
    u_option = cont.get_input(idx_x);
    % keep the same input if not necessary
    if(i==1||i>=2&&~ismember(U_list(end),u_option))
        idx_u = u_option(1);
    end
     
    u0 = get_coord(idx_u,M_U);    % get the coordinate of input
    y0 = [xt;u0];    % States for numerical integration
    
    yt = ode45(@odefun,[0,tau],y0);
    
    xt = yt.y(1:2,end); % destination in one step
    idx_x  = mapping(xt,M_X,eta/2);
    X_list = [X_list;idx_x]; % history of idx_x
    U_list = [U_list;idx_u]; % history of idx_u
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

legend('Vel of Mass Center','Pos of Mass Center');
%%
figure(1);

[x1,x2] = get_coord(X_list,M_X);
for i=1:length(x1)-1
    arrow('Start',[x1(i),x2(i)],'Stop',[x1(i+1),x2(i+1)],'Length',10,'TipAngle',5)
    pause(0.1);
end