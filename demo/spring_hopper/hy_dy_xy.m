function ds = hy_dy_xy(t,s,param)
% inputs: t ---- time
%         s ---- state vector [x,y,dx,dy]
%         param ---- parameters 

l0 = param.rest_len;
m = param.mass;
g = param.gravity;
k = param.k;

ds = zeros(4,1);

l = norm(s(1:2),2);
if(l<=l0)
    ds(1:2) = s(3:4);
    ds(3:4) = k/m*(l0/l-1)*s(1:2) + [0;-m*g];
end

end