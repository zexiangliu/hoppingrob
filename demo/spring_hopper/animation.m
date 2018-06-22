load ts.mat
load simu.mat

rob = SimHopRob(1/15,1/10,l0);

% % map
% map_bnd = [x1min-lmax,x1max+lmax;
%            x1min-lmax,x1max+lmax];
% num_grid = [2,2];
% gnd = Ground(map_bnd,num_grid,0);
% [map_X,map_Y,map_V]=gnd.ground_gen_rand(0.0);

%% Animation
fig = figure(3);
az = 0;
el = 0;



save_video(M,'spring_hopper.avi');