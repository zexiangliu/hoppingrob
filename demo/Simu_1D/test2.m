clear all;clc;
load system
x0 = [100;0];
u = 100;
tau = 0.05;
y = ode45(@odefun,[0,tau],[x0;u]);
xt = y.y(1:2,end)

Phi = expm(A*tau);
xt_est = Phi*x0 - A\(eye(2)-Phi)*B*u


%%
clear all;clc;
syms t x1 x2 u c
A = [0 1;c 0];
B = [0;-c];
    
Phi = [1 0]*expm(A*t);

Phi_u = -[1 0]*inv(A)*(eye(2) - expm(A*t))*B;