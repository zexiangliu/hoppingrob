% close all;clear all;clc;
m = 1;
g = 10;
l0 = 0.5;
k = 1000;

param.rest_len = l0;
param.gravity = g;
param.mass = m;
param.k = k;

y0 = 1;
dx0_list = 0.5;%linspace(0.4,0.5,10);

E = 1/2*m*dx0_list(1)^2 + m*g*y0+20;

u = pi/180*85;
E0 = zeros(length(dx0_list),1);
E1 = E0;
K0 = E0;
K1 = E0;
P0 = E0;
P1 = E0;

for i = 1:length(dx0_list)
    dx0 = dx0_list(i);
    y0 = (E-1/2*m*dx0^2)/m/g;
    init = [y0;dx0];
    try
        [t_list,X,Y,dx1] = simuOneJump_lt(param, init, u);
    catch ME1
        warning(ME1.message);
        continue;
    end

    E0(i) = param.mass*param.gravity*y0 + 1/2*param.mass*dx0^2
    E1(i) = param.mass*param.gravity*Y(end) + 1/2*param.mass*dx1^2

    K0(i) = 1/2*param.mass*dx0^2
    K1(i) = 1/2*param.mass*dx1^2

    P0(i) = param.mass*param.gravity*y0
    P1(i) = param.mass*param.gravity*Y(end)

    %%
    subplot(1,3,1);
    hold on;
    plot(X,Y)
    axis equal;
    title('X-Y');
    subplot(1,3,2);
    hold on;
    plot(t_list,X);
    axis equal;
    title('t-X');
    subplot(1,3,3);
    hold on;
    plot(t_list,Y);
    axis equal;
    title('t-Y');
    pause(0.5);
end
