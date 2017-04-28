% Test code
clc;clear all;close all;
%% grid generation
DC.gridsize = 0.1;
DC.bnd = [
    1.001,2.21;
    3.44,5.78;
    ];
Mesh = GridGener(DC);

% Visualization
bnd = Mesh.bnd;
u = Mesh.gridsize;
discr_bnd = Mesh.discr_bnd;
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
x0 = [1.5;4];     % Initial Cond
u0 = 3;         % Input
y0 = [x0;u0];    % States for numerical integration
tau = 0.01;     %
yt = ode45(@odefun,[0,tau],y0);
xt = yt.y(1:2,end)


%% mapping: A--->[A]_u
% xt = [1.5;4.5];
r = 0.08;
idx = mapping(xt,Mesh,r);

% Visualization
plot(xt(1),xt(2),'*','markersize',10)
[x1,x2] = ind2sub(Mesh.discr_bnd(:,3),idx); % xt

x1 = discr_bnd(1,1)+(x1-1)*u;
x2 = discr_bnd(2,1)+(x2-1)*u;
plot(x1,x2,'.','markersize',12);    % nodes included

[U,V] = meshgrid([xt(1)-r,xt(1)+r],[xt(2)-r,xt(2)+r]);
f=[1,2,4,3];
v = [U(:),V(:)];
% norm ball
patch('Faces',f,'Vertices',v,...
    'EdgeColor','red','FaceColor','none','LineWidth',2);

%% Everything
array = ArrayGener;