rob = SimHopRob(1/15,1/10,1);

% map
map_bnd = [x1min-lmax,x1max+lmax;
           x1min-lmax,x1max+lmax];
num_grid = [2,2];
gnd = Ground(map_bnd,num_grid,0);
[map_X,map_Y,map_V]=gnd.ground_gen_rand(0.0);

%% Animation
fig = figure(3);
az = 0;
el = 0;

x_list = [Yx_list(1,:);Yx_list(1,:)*0];
u_list = [Yx_list(3,:);Yx_list(3,:)*0];
M = rob_anim(fig,Yt_list,x_list,u_list,[],rob,gnd,[az,el]);

save_video(M,'Simu_1D.avi');

%% Animation based on Simulink
% disp('Animation 2:')
% u_list = get_coord(M_U,U_list);
% 
% save cont t_list u_list % used as input in simulink
% len_leg1=h0/2;
% len_leg2=sqrt(h0^2+(x1max-x1min+lmax)^2);
% C = [1,0];
% D=[0];
% fre_hopping = pi/2/tau;
% % u_list = zeros(ts.n_s,1);
% % for i = 1:length(W)
% %     tmp=cont.get_input(W(i));
% %     u_list(W(i))=get_coord(tmp(1),M_U);
% % end
% % M_X.V = [];
% 
% % save cont u_list M_X
% hopping_robot_R2012b
