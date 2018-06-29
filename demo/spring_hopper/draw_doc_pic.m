close all;clear all;clc;
m = 1;
g = 10;
l0 = 0.5;
k = 6000;

param.rest_len = l0;
param.gravity = g;
param.mass = m;
param.k = k;

y0 = 1;

E = 1.5 + m*g*y0;

dE = 0.2;

u_list = 85;
% u = pi/180*80;

for u = u_list

u = pi/180*u;
%% experiment 1 fix dx, change y0
E_list = E + linspace(-dE,dE,20);
y0_list = (E_list -1.5)/m/g;
dx0_list = sqrt(2*1.5/m)*ones(length(y0_list),1);

E0 = zeros(length(dx0_list),1);
E1 = E0;
K0 = E0;
K1 = E0;
P0 = E0;
P1 = E0;

for i = 1:length(dx0_list)
    dx0 = dx0_list(i);
    y0 = y0_list(i);
    init = [y0;dx0];
    try
        [t_list,X,Y,dx1] = simuOneJump_lt(param, init, u);
    catch ME1
        warning(ME1.message);
        continue;
    end

    E0(i) = param.mass*param.gravity*y0 + 1/2*param.mass*dx0^2;
    E1(i) = param.mass*param.gravity*Y(end) + 1/2*param.mass*dx1^2;

    K0(i) = sign(dx0)*1/2*param.mass*dx0^2;
    K1(i) = sign(dx1)*1/2*param.mass*dx1^2;

    P0(i) = param.mass*param.gravity*y0;
    P1(i) = param.mass*param.gravity*Y(end);
    i
end
%%
figure(1);
hold on;
plot(E_list,K1,'.b','markersize',50);
plot(E_list(1),K1(1),'.r','markersize',50);
plot(E_list(end),K1(end),'.r','markersize',50);
xlabel('Total Energy');
ylabel('Final Kinetic Energy');
set(gca,'fontsize',40)
axis auto;

%% experiment 1 fix E0, change dx_
E_up = E + dE;
dx0_list = sqrt(2*linspace(1,2,20)/m);
y0_list = (E_up - 1/2*m*dx0_list.^2)/m/g;

E0 = zeros(length(dx0_list),1);
E1 = E0;
K0 = E0;
K1 = E0;
P0 = E0;
P1 = E0;

for i = 1:length(dx0_list)
    dx0 = dx0_list(i);
    y0 = y0_list(i);
    init = [y0;dx0];
    try
        [t_list,X,Y,dx1] = simuOneJump_lt(param, init, u);
    catch ME1
        warning(ME1.message);
        continue;
    end

    E0(i) = param.mass*param.gravity*y0 + 1/2*param.mass*dx0^2;
    E1(i) = param.mass*param.gravity*Y(end) + 1/2*param.mass*dx1^2;

    K0(i) = sign(dx0)*1/2*param.mass*dx0^2;
    K1(i) = sign(dx1)*1/2*param.mass*dx1^2;

    P0(i) = param.mass*param.gravity*y0;
    P1(i) = param.mass*param.gravity*Y(end);
    i
end
%%
fig = figure(2);
hold on;
plot(linspace(1,2,20),K1,'.b','markersize',50);
plot(1,K1(1),'.g','markersize',50);
plot(2,K1(end),'.g','markersize',50);
xlabel('Initial Kinetic Energy');
ylabel('Final Kinetic Energy');
set(gca,'fontsize',40)
axis auto;
end