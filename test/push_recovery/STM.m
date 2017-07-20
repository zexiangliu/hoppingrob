function [Phi,Phi_u] = STM(A,B,tau)
% assume that input u is a constant
% calculate the state transition matrices  Phi and Phi_u
% the solution is: x(t) = Phi*x0 + Phi_u*u
Phi = expm(A*tau);
Phi_u = -inv(A)*(eye(length(A))-Phi)*B;
end