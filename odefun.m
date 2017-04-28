function dydt=odefun(t,y)
% linear system x = Ax + Bu
g = 9.8;
h0 = 10;
A =[0 1;g/h0 0];
B = [0;-1];

x = y(1:2);
u = y(3);
dxdt = A*x + B*u;  
dydt = [dxdt;0];           % u doesn't change. 