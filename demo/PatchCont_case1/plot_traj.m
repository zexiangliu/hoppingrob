% clc;clear all;close all;
% load visual
% 
% num_cont = length(cont);
% 
% fig = figure(1);
% 
% M_X.visual_grid(fig,1:M_X.numV-1,[0,0,0],1);
% 
% % color = ['g','r','y','b','g','m'];
% color = [178,255,255]/255;
% for i = 1:num_cont
%     W = cont{i}.sets{end};
%     hold on;
% %     M_X.visual(fig,W,['.',color],8);
%     M_X.visual_grid(fig,W,color,0.3);
% end

%%
% hold on;
% W = cont{1}.sets{end};
% M_X.visual(fig,W,['.','c'],4);

% axis equal
% axis([M_X.bnd(1,:),M_X.bnd(2,:)])


clc;clear all;close all;
load visual

num_cont = length(cont_patch);

fig = figure(1);
X = M_X.V{1};
Y = M_X.V{2};
len_X = length(X);
len_Y = length(Y);
Z = zeros(len_X,len_Y);

W1 = cont_ref{1}.sets{end};
W2 = cont_patch{3}.sets{end};

num_cont =length(cont_patch);

color=['b','b','r'];

t_span = 60;
plot([0,t_span-1],[-1.6,-1.6],'-.r');
fig = figure(2)
M_X.visual_bnd(fig,bnd_B,[255,169,81]/255,2);

cont_compare{1} = cont;
cont_compare{2} = cont_patch{3};
for k = [1,2]
    %% Initialization
    % constants
    eta = M_X.gridsize;
    % initial state 
    idx_x0 = W2(1);


    [x1,x2] =get_coord(M_X,idx_x0);
%     plot(x1,x2,'xb','markersize',10)

    idx_x = idx_x0;
    xt = [x1;x2];

    idx_u = 0;
    X_list = [idx_x0];
    U_list = [];
    t_list = [];
    u_list =[];

    Yt_list=[]; % record ode solution for animation
    Yx_list=[]; % record ode solution for animation
    %% hopping
    disp('Simulating...');
    cont = cont_compare{k};
    cont = cont.copy;
    cont.cont_trim();
    for i = 1:t_span
        % visual (on the grid)
        % get the options of input 
    %     disp(idx_x)
        u_option = cont(idx_x);
        % keep the same input if not necessary
        if(i==1||i>=2&&~ismember(U_list(end),u_option))
            idx_u = u_option(1);
        end
        u0 = get_coord(M_U,idx_u);    % get the coordinate of input
        y0 = [xt;u0];    % States for numerical integration

        u_list = [u_list;u0];
        yt = ode45(@odefun,[0,tau],y0);

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

    %     figure(2);
    %     plot((i-1)*tau+yt.x,yt.y(1,:),'r-'); % position red
    %     plot((i-1)*tau+yt.x,yt.y(2,:),'b-'); % velocity blue
    %     hold on;
    %     drawnow;
    end
    disp('Done.');

%     legend('Vel of Mass Center','Pos of Mass Center');
%     xlabel('t');

    %%
    figure(1);
    hold on;
    plot(0:t_span-1,u_list,'linewidth',2);
    pause(0.5);
    fig = figure(2);
    traj_anim(fig,M_X,X_list,[1,2],0.01,color(k));
    pause(0.05);    
end
fig1=figure(1)
% axis equal;
axis([0,t_span-1,-3.5,3.5])
xlabel('time');
ylabel('input');
box on;
% img_tight(fig1);

fig2=figure(2)
axis equal;
axis([M_X.bnd(1,:),M_X.bnd(2,:)]);
xlabel('x')
ylabel('v')
grid on;
box on;
img_tight(fig2);
%% Trajectory in state space
% disp('Trajectory:')
% fig = figure(1);

% traj_anim(fig,M_X,X_list,[1,2],0.01,'r');
