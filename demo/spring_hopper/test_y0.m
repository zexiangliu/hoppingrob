close all;clear all;clc;
param.rest_len = 0.5;
param.gravity = 10;
param.mass = 1;
param.k = 1000;

% y0 = 0.8;
y0_list = linspace(0.6,2,10);
dx0 = 0.6;

u = pi/180*100;
E0 = zeros(length(y0_list),1);
E1 = E0;
K0 = E0;
K1 = E0;
P0 = E0;
P1 = E0;

for i = 1:length(y0_list)
    y0 = y0_list(i);
    init = [y0;dx0];

    [t_list,X,Y,dx1] = simuOneJump_xy(param, init, u);


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
