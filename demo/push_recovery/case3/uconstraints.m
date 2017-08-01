function y = uconstraints(uconstr,u0,x0,h,r,type)
% Check the input constraints. If input is feasible, return 1
y = true;
if(type==1)
    gnd = uconstr.gnd;
    coord_bias = uconstr.coord_bias;
    direction = uconstr.direction;
    u = coord_bias+u0*direction; % input in world coordinate
    y = ~gnd.IsInHoles(u);
elseif(type==2)
    eta = uconstr.eta;
    max_leg = uconstr.max_leg;
    l = sqrt(h^2+(abs(x0(1)-u0)+eta(1)/2)^2);
    if(l>max_leg)
        y = false;
    end
elseif(type==3)
    max_leg = uconstr.max_leg;
    l = sqrt(h^2+(abs(x0(1)-u0)+r)^2);
    if(l>max_leg)
        y = false;
    end
end
end