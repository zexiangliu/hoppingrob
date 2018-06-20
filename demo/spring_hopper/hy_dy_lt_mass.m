function ds = hy_dy_lt_mass(t,s,param)
% hybrid dynamics with (l, theta) coordinates
% inputs: t ---- time
%         s ---- state vector [x,y,dx,dy]
%         param ---- parameters 

l0 = param.rest_len;
m = param.mass;
g = param.gravity;
k = param.k;

ds = zeros(4,1);

if(s(1)<=l0)
    ds(1:2) = s(3:4);
    ds(3) = s(1)*s(4)^2 - k/m*(s(1) - l0) - g*sin(s(2));
    ds(4) = -2*s(3)*s(4)*s(1) - g*cos(s(2))*s(1);
end

end