function [dx,x_t,v_t] = dist_utl_stable_tau(v0,lmax,h0,g,tau)

gh = sqrt(g/h0);

fun_c = @(v0,u) v0/gh./u;
% the time needed when v=0, that is the robot stops (when c <= 1)
fun_t = @(c) 1/2/gh*log((1+c)./(1-c)); 
fun_x1 = @(c,u,t) u.*(1+c.*sinh(gh*t)-cosh(gh*t));
fun_x2 = @(c,u,t) gh*u.*(cosh(gh*t).*c-sinh(gh*t));

n = length(v0);
% save the position and velocity after the time interval where the robot is
% stopped.
x_t = zeros(size(v0)); 

u_ref = ones(size(v0))*lmax;
% this is the largest u s.t. u - x1(tau) <= lmax
u = min(lmax/cosh(gh*tau)+v0/gh*sinh(gh*tau)/cosh(gh*tau),u_ref);
c = fun_c(v0,u);
idx_out = c<=1;
t = ones(size(c))*tau;
% find out the time the robot stops.
t(idx_out) = fun_t(c(idx_out));
% if the robot stops in more than tau, use the largest input to stop it in
% the next input
t(t>tau) = tau;
dx = fun_x1(c,u,t);
% if(any(dx>u+lmax))
%     error('x_1 is out of the constraint.');
% end

x_t = x_t+fun_x1(c,u,tau);
v_t = fun_x2(c,u,tau);
if(any(abs(u-fun_x1(c,u,tau))>lmax+1e-14))
    error('x_1 is out of the constraint.');
end
    
% idx_exist(idx_out) = [];
v0 = fun_x2(c,u,t);
v0(v0<=1e-14)=0;


while(sum(v0)>0)
    u = min(lmax/cosh(gh*tau)+v0/gh*sinh(gh*tau)/cosh(gh*tau),u_ref);
    c = fun_c(v0,u);
    idx_out = c<=1;
    t = ones(size(c))*tau;
    t(idx_out) = fun_t(c(idx_out));
%     idx_out = idx_out & t<=tau;
    t(t>tau) = tau;
    ddx = fun_x1(c,u,t);
    dx = dx+ddx;
%     if(any(ddx>u+lmax))
%         error('x_1 is out of the constraint.');
%     end
    
    x_t(v0~=0) = x_t(v0~=0)+fun_x1(c(v0~=0),u(v0~=0),tau);
    v_t(v0~=0) = fun_x2(c(v0~=0),u(v0~=0),tau);
    if(any(abs(u(v0~=0)-fun_x1(c(v0~=0),u(v0~=0),tau))>lmax+1e-14))
        keyboard();
        error('x_1 is out of the constraint.');
    end
    
    v0 = fun_x2(c,u,t);
    v0(v0<=1e-10)=0;
end

end