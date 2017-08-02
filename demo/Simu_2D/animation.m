% Playground

Playground.vert = [U.bnd(1,1),U.bnd(2,1),0;
                   U.bnd(1,1),U.bnd(2,2),0;
                   U.bnd(1,2),U.bnd(2,2),0;
                   U.bnd(1,2),U.bnd(2,1),0;
                   ];

Playground.fac = [1 2 3 4];

rob = SimHopRob(1/15,1/10,Playground);
% B_list

Target.vert = [bnd_B(1,1),bnd_B(2,1),h0
    bnd_B(1,1),bnd_B(2,2),h0
    bnd_B(1,2),bnd_B(2,2),h0
    bnd_B(1,2),bnd_B(2,1),h0
    ];
Target.fac = [1,2,3,4];

figure(3);
% axis([x1min-lmax, x1max+lmax, -0.5, 0.5, -0.5, 1.5]); 
% axis equal;
t = 0;
% hold on;


for i = 1:length(Yt_list)
    pause(Yt_list(i)-t);
    t= Yt_list(i);
    hold off;
    
    hopping_height = h0/4*abs(sin((3*pi/2/tau)*t));
    rob.visual(fig,[Yx_list(1,i);0;h0],[Yx_list(3,i);0;hopping_height]);
    % B_list
    patch('Faces',Target.fac,'Vertices',Target.vert,'FaceColor','none','EdgeColor','red');  % patch function

    % camera configuration
%     axis([x1min-lmax, x1max+lmax, -0.5, 0.5, -0.5, 1.5]); 
    axis equal;
    az = 25;
    el = 15;
    view(az, el);
    drawnow;
end

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
