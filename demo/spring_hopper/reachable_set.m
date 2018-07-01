function [ K, bool ] = reachable_set(x_cell,u,param)
% Comput reachable set for hopping robot
% Inputs:   x_cell: the range of K0
%           u: input (unit: deg)
%           param: parameters used in simuOneJump_xy
% Outputs:  K: reachable set represented using Rec
%           bool: 1 success 0 out of bound        
    E = param.E;
    dE = param.dE;
    m = param.mass;
    g = param.gravity;
    u = pi*u/180;
    % initial kinetic energy
    K0_1 = x_cell.xmin;
    K0_2 = x_cell.xmax;
    % initial height
    y0_11 = (E + dE - abs(K0_1))/m/g;
    y0_12 = (E - dE - abs(K0_1))/m/g;
    y0_21 = (E + dE - abs(K0_2))/m/g;
    y0_22 = (E - dE - abs(K0_2))/m/g;
    % initial horizontal velocity
    dx0_1 = sign(K0_1)*sqrt(2*abs(K0_1)/m);
    dx0_2 = sign(K0_2)*sqrt(2*abs(K0_2)/m);
    try
        [~,~,~,dx1_cand(1)] = simuOneJump_xy(param, [y0_11,dx0_1], u);
        [~,~,~,dx1_cand(2)] = simuOneJump_xy(param, [y0_12,dx0_1], u);
        [~,~,~,dx1_cand(3)] = simuOneJump_xy(param, [y0_21,dx0_2], u);
        [~,~,~,dx1_cand(4)] = simuOneJump_xy(param, [y0_22,dx0_2], u);
        K1_max = sign(max(dx1_cand))*1/2*m*max(dx1_cand)^2;
        K1_min = sign(min(dx1_cand))*1/2*m*min(dx1_cand)^2;
        K = Rec([K1_min K1_max], {'SET'});
        bool = true;
    catch
        K = [];
        bool = false;
    end
end

