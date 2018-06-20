function [t_list,X,Y,dx1] = simuOneJump_lt(param, init, u)
% Simulate the trajectory between two apex points.
% inputs: dyn --- a function handle for dynamics of the robot
%         param --- parameters characteristic of the robot
%         init --- [y0,dx0] at the apex
%         u --- intput for the current peroid, rad/s

l0 = param.rest_len;
g = param.gravity;
dyn = @hy_dy_lt;

X = [];
Y = [];

y0 = init(1);
dx0 = init(2);

% Landing
land_height = l0*sin(u);
dh = y0-land_height;
if(dh < 0)
    error('initial height is too low to land in angle theta!');
end

t0 = sqrt(2*dh/g);
t_list = linspace(0,t0,100)';

X = dx0 * t_list;
Y = y0 - 1/2*g*t_list.^2;

% Stance phase
s0_xy = [-l0*cos(u), land_height, dx0, -g*t0];
s0_c = xy2lt(s0_xy);
opt = odeset('RelTol',1e-13,'AbsTol',1e-14);
[t_list_stance,S_list] = ode45(@(t,s)dyn(t,s,param),[0:0.001:10],s0_c,opt);
idx_sat = find(S_list(:,1)<l0);
if(idx_sat(1) ~= 1)
    idx_sat = [1;idx_sat];
end

S_tmp = lt2xy(S_list);
energy = param.mass*10*S_tmp(idx_sat,2)+1/2*param.mass*...
    S_tmp(idx_sat,3).^2+1/2*param.mass*S_tmp(idx_sat,4).^2+...
    1/2*param.k*(sqrt((S_tmp(idx_sat,1).^2+S_tmp(idx_sat,2).^2))-...
    param.rest_len).^2;
    

if(S_list(idx_sat(end)+1,1)<=l0)
    idx_crt = idx_sat(end)+1;
    t_rk = t_list_stance(idx_crt);
    s_rk = S_list(idx_crt,:)';
else
    idx_crt = idx_sat(end);
    t_rk = t_list_stance(idx_crt);
    s_rk = S_list(idx_crt,:)';
    dt = t_list_stance(idx_crt+1)-t_rk;
    
    while(dt<1e-8)
        [t_rk1, s_rk1] = rk4(dyn,t_rk,s_rk,param,dt/3);
        [t_rk2, s_rk2] = rk4(dyn,t_rk,s_rk,param,2*dt/3);
%         [t_tmp,S_tmp] = ode45(@(t,s)dyn(t,s,param),[t_rk,t_rk+dt/3],s_rk,opt);
%         t_rk1 = t_tmp(end);
%         s_rk1 = S_tmp(end,:)';
%         [t_tmp,S_tmp] = ode45(@(t,s)dyn(t,s,param),[t_rk,t_rk+2*dt/3],s_rk,opt);
%         t_rk2 = t_tmp(end);
%         s_rk2 = S_tmp(end,:)';
        if(s_rk1(1) <= l0)
            if(s_rk2(1) > l0)
                t_rk = t_rk1;
                s_rk = s_rk1;
            else
                t_rk = t_rk2;
                s_rk = s_rk2;
            end
        end
        dt = dt/3;
    end    
end

S_list = lt2xy(S_list);
s_rk = lt2xy(s_rk');

t_list = [t_list;t_list_stance(idx_sat)+t_list(end);t_rk+t_list(end)];
X = [X;S_list(idx_sat,1)+X(end)-s0_xy(1);s_rk(1)+X(end)-s0_xy(1)];
Y = [Y;S_list(idx_sat,2);s_rk(2)];

% change to air again

dx1 = s_rk(3);
dy1 = s_rk(4);
if(dy1 < 0)
    error('The spring is overloaded!')
else
    t1 = dy1/g;
end
t_tmp = linspace(0,t1,100)';
X = [X;dx1*t_tmp+X(end)];
Y = [Y;dy1*t_tmp-1/2*g*t_tmp.^2+Y(end)];
t_list = [t_list;t_tmp+t_list(end)];
end