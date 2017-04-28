function dydt=odefun(t,y)
% linear system x = Ax + Bu
persistent g h0 A B
if(isempty(g))
    g = 9.8;
    h0 = 10;
    A =[0 1;g/h0 0];
    B = [0;-1];
end

dxdt = A*y(1:2) + B*y(3);  % x=y(1:2) u = y(3)
dydt = [dxdt;0];           % u doesn't change. 