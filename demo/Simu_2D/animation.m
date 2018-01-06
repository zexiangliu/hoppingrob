rob = SimHopRob(1/15,1/10,1);

% map
map_bnd = [x1min-lmax,x1max+lmax;
           x1min-lmax,x1max+lmax];
num_grid = [2,2];
gnd = Ground(map_bnd,num_grid,0);
[map_X,map_Y,map_V]=gnd.ground_gen_rand(0.0);

% B_list

Target.vert = [bnd_B(1,1),bnd_B(2,1),h0
    bnd_B(1,1),bnd_B(2,2),h0
    bnd_B(1,2),bnd_B(2,2),h0
    bnd_B(1,2),bnd_B(2,1),h0
    ];
Target.fac = [1,2,3,4];

fig = figure(3);
az = 25;
el = 15;

M = rob_anim(fig,Yt_list,Yx_list([1,2],:),Yx_list([5,6],:),bnd_B,rob,gnd,[az,el]);

save_video(M,'Simu_2D.avi');

% %% Animation based on Simulink
% disp('Animation 2:')
% u_list1 = get_coord(M_U1,U1_list);
% u_list2 = get_coord(M_U2,U2_list);
% 
% save cont t_list u_list1 u_list2 % used as input in simulink
% len_leg1=h0/2;
% len_leg2=sqrt(h0^2+(x1max-x1min+lmax)^2);
% C = [1,0,0,0;
%     0,1,0,0];
% D=[0,0
%    0,0];
% fre_hopping = pi/2/tau;
% % u_list = zeros(ts.n_s,1);
% % for i = 1:length(W)
% %     tmp=cont.get_input(W(i));
% %     u_list(W(i))=get_coord(tmp(1),M_U);
% % end
% % M_X.V = [];
% 
% % save cont u_list M_X
% hopping_robot_plane_R2012b
