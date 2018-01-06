function [X_list,U_list,t_list,Yt_list,Yx_list] = simu_loop(ode_fun,M_X,M_U,x0,idx_x0,cont,t_span,tau)

eta = M_X.gridsize;

idx_x = idx_x0;
xt = [x0];

idx_u = 0;
X_list = [idx_x0];
U_list = [];
t_list = [];

Yt_list=[]; % record ode solution for animation
Yx_list=[]; % record ode solution for animation

disp('Simulating...');
for i = 1:t_span
    % visual (on the grid)
    % get the options of input 
%     disp(idx_x)
    u_option = cont.get_input(idx_x);
    % keep the same input if not necessary
    if(i==1||i>=2&&~ismember(U_list(end),u_option))
        idx_u = u_option(1);
    end
     
    u0 = get_coord(M_U,idx_u);    % get the coordinate of input
    y0 = [xt;u0];    % States for numerical integration
    
    yt = ode45(ode_fun,[0,tau],y0);
    
    xt = yt.y(1:2,end); % destination in one step
    idx_x  = mapping(xt,M_X,eta/2*0);
    X_list = [X_list;idx_x]; % history of idx_x
    U_list = [U_list;idx_u]; % history of idx_u
    t_list = [t_list;i*tau];
    
    Yt_list = [Yt_list, (i-1)*tau + yt.x]; % time
    Yx_list = [Yx_list, yt.y]; % state
    % visual (time)
    
%     figure(1);
%     [x1,x2] = get_coord(idx_x,M_X);
%     plot(x1,x2,'xb','markersize',10);
%     hold on;
%     pause(0.2);
%     drawnow

    figure(2);
    plot((i-1)*tau+yt.x,yt.y(1,:),'r-'); % position red
    plot((i-1)*tau+yt.x,yt.y(2,:),'b-'); % velocity blue
    hold on;
    drawnow;
end
disp('Done.');