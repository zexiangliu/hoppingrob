function y = uconstraints(uconstr,u0)
% Check the input constraints. If input is feasible, return 1
    y = true;
    gnd = uconstr.gnd;
    coord_bias = uconstr.coord_bias;
    direction = uconstr.direction;
    u = coord_bias+u0*direction; % input in world coordinate
    y = ~gnd.IsInHoles(u);
end