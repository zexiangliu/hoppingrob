clc;clear all;close all;

load ts.mat
load cont.mat

TSpan = 50;

t_real = 0;
x_real = 0;

K0 = M_X.get_coord(W(20));
dx0 = sign(K0)*sqrt(2*abs(K0)/m);
y0 = (E-1/2*m*dx0^2)/m/g;

%%
t_list = [];
X_list = [];
Y_list = [];
U_list = [];

while(t_real<TSpan)
    
    init = [y0,dx0]
    K0_idx = mapping_ext(sign(dx0)*1/2*m*dx0^2,M_X,0);
    
    u_list = cont(K0_idx);
    u = M_U(u_list(1))*pi/180;
    [t,X,Y,dx1,U1] = simuOneJump_xy(param, init, u);
    t_list = [t_list;t_real+t];
    X_list = [X_list;x_real+X];
    Y_list = [Y_list;Y];
    U_list = [U_list; U1];
    
    dx0 = dx1
    y0 = Y(end);
    t_real = t_real + t(end)
    x_real = x_real + X(end);
end
%%
plot(X_list,Y_list)
xlabel('x');
ylabel('y');
set(gca,'fontsize',20);
axis([-12,0.2,0.3,1.7]);

%%
save simu.mat K0 dx0 y0 t_list X_list Y_list U_list
