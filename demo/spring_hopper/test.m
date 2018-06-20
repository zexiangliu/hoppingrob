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

% Grid of input
dt_max = 10;
M_U = (90-dt_max):(90+dt_max);

% initial condition

param.rest_len = l0;
param.gravity = g;
param.mass = m;
param.k = k;

y0 = 1.5;
dx0 = 1;
dy = 0.2;

E = 1/2*m*dx0(1)^2 + m*g*y0;
dE = m*g*dy;

%% test
cnt = 1;
for j = 20%:length(M_U)
    figure(cnt);
    for i =1:length(M_X.V{1})
        %% type 1
        dx0 = M_X.V{1}(i);
        y0 = (E-1/2*m*dx0^2)/m/g;
        init = [y0;dx0];
        u = M_U(j)*pi/180;
        try
            [t_list,X,Y,dx1] = simuOneJump_lt(param, init, u);

            E0_1(i) = m*g*y0 + 1/2*m*dx0^2;
            E1_1(i) = m*g*Y(end) + 1/2*m*dx1^2;

            K0_1(i) = 1/2*m*dx0^2;
            K1_1(i) = 1/2*m*dx1^2;

            P0_1(i) = m*g*y0;
            P1_1(i) = m*g*Y(end);
        catch ME1
            warning(ME1.message);
        end
        %% type 2
        y0 = (E-1/2*m*dx0^2+dE)/m/g;
        init = [y0;dx0];
        u = M_U(j)*pi/180;
        try
            [t_list,X,Y,dx1] = simuOneJump_lt(param, init, u);
            
            E0_2(i) = m*g*y0 + 1/2*m*dx0^2;
            E1_2(i) = m*g*Y(end) + 1/2*m*dx1^2;

            K0_2(i) = 1/2*m*dx0^2;
            K1_2(i) = 1/2*m*dx1^2;

            P0_2(i) = m*g*y0;
            P1_2(i) = m*g*Y(end);
        catch ME1
            warning(ME1.message);
        end

         %% type 3
        y0 = (E-1/2*m*dx0^2-dE)/m/g;
        init = [y0;dx0];
        u = M_U(j)*pi/180;
        try
            [t_list,X,Y,dx1] = simuOneJump_lt(param, init, u);
            E0_3(i) = m*g*y0 + 1/2*m*dx0^2;
            E1_3(i) = m*g*Y(end) + 1/2*m*dx1^2;

            K0_3(i) = 1/2*m*dx0^2;
            K1_3(i) = 1/2*m*dx1^2;

            P0_3(i) = m*g*y0;
            P1_3(i) = m*g*Y(end);
        catch ME1
            warning(ME1.message);
        end

        
    end
    
    figure(1);
    hold on;
    plot(K1_1);
    plot(K1_2);
    plot(K1_3);
    plot(E1_1);
    plot(E1_2);
    plot(E1_3);
    plot(1/2*m*M_X.V{1}.^2)
    cnt = cnt + 1;
end
%%
transition_list = cell(length(M_U));

for i = 1:length(M_U)
    u = M_U(i)*pi/180;
    
    
    
end