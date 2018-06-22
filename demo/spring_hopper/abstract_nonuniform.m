clc;clear all;close all;

% build abstraction

m = 1;
g = 10;
l0 = 0.5;
k = 7000;

% Grid of Kinetic Energy
v_max = 5;
X.bnd = [-1/2*m*v_max^2, 1/2*m*v_max^2];
X.gridsize = 0.1;
M_X = GridGener(X);
num_X = M_X.discr_bnd(3);
% Grid of input
dt_max = 10;
M_U = (90-dt_max):(90+dt_max);
num_U = length(M_U);
% initial condition
param.rest_len = l0;
param.gravity = g;
param.mass = m;
param.k = k;

y0 = 1.5;
dx0 = 1;
Dy = 0.2;

E = 1/2*m*dx0(1)^2 + m*g*y0;
dE = m*g*Dy;

transition_list = cell(num_U);
dx1_cand = zeros(4,1);
ts = TransSyst(num_X+1,num_U);    

for i = 18%1:length(M_U)
    u = M_U(i)*pi/180;
    transition_list{i}=false(num_X+1,num_X+1);
    i
    for j = 62%1:num_X
        j
        % initial kinetic energy
        K0_1 = M_X.V{1}(j)-X.gridsize;
        K0_2 = M_X.V{1}(j)+X.gridsize;
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
            K1 = (K1_max+K1_min)/2;
            r = (K1_max-K1_min)/2;
            s2_idx = mapping_ext(K1,M_X,r);
            keyboard();
        catch
            s2_idx = num_X+1;
            disp('ooops!')
        end
        transition_list{i}(j,s2_idx)=1;
        transition_list{i}(num_X+1,num_X+1) = 1;
    end
end

for i = 1:num_U
    for j = 1:num_X+1
        state2 = find(transition_list{i}(j,:));
        state1 = j*ones(length(state2),1);
        action = i*ones(length(state2),1);
        ts.add_transition(state1,state2,action);
    end
end

