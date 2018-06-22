load ts.mat
load simu.mat

rob = SimHopRob(1/15,1/10,l0);

% % map

p1 = [min(X_list)-0.1,0,0];
p2 = [max(X_list)+0.1,0,max(Y_list)+0.1];

% map_bnd = [min(X_list),max(X_list);
%            min(Y_list),max(Y_list)];
% num_grid = [2,2];
% gnd = Ground(map_bnd,num_grid,0);
% [map_X,map_Y,map_V]=gnd.ground_gen_rand(0.0);

%% pre-processing
[t_list,idx] = unique(t_list);
X_list = X_list(idx);
Y_list = Y_list(idx);
U_list = U_list(idx);

dt = 0.05;
t_play = 1:dt:t_list(end);
X_play = interp1(t_list,X_list,t_play);
Y_play = interp1(t_list,Y_list,t_play);
U_play = interp1(t_list,U_list,t_play);

%% Animation
fig = figure(1);
az = 0;
el = 0;

t_real = 0;

for i = 1:length(t_play)
   
    x = X_play(i); y = Y_play(i); u = U_play(i);
    pCoM = [x, 0, y];
    if(y >= l0*sin(u))
        pPadel = [x + l0*cos(u); 0; y-l0*sin(u)];
    end
    figure(1);
    rob.visual(fig,pCoM,pPadel);
    hold on;
%     gnd.visual_ground(fig);
    plot3(p1(1),p1(2),p1(3));
    plot3(p2(1),p2(2),p2(3));
    hold off;
    
    axis equal;
    view(az, el);
    drawnow;
%     pause(dt);
    t_real = t_play(i);
    M(i) = getframe;
    
%     figure(2);
%     plot(X_play(1:i),Y_play(1:i));
end

save_video(M,'spring_hopper.avi');