% close all;clear all;clc;

for test_num = 1:3
load(sprintf('simu%d.mat',test_num))

rob = SimHopRob(1/15,1/10,1);

% map
map_bnd = [x1min-lmax,x1max+lmax;
           x1min-lmax,x1max+lmax];
num_grid = [2,2];
gnd = Ground(map_bnd,num_grid,0);
[map_X,map_Y,map_V]=gnd.ground_gen_rand(0.0);
for i = 1:length(u_res)
    r = M_U.gridsize;
    center = M_U.V{1}(u_res(i));
    gnd.add_hole(r,'square',[center,0]');
end
%%

dt = 0.005;
t_play = 0:dt:Yt_list(end);
[Yt_list,idx] = unique(Yt_list);
Yx_list = Yx_list(:,idx);

X_play = interp1(Yt_list,Yx_list(1,:),t_play);
for i = 1:length(t_play)
    t = max(find(t_play(i)>=Yt_list));
    U_play(i) = Yx_list(3,t);
end
    
%% Animation
close all;
fig = figure('units','normalized','outerposition',[0 0 1 1])

az = 0;
el = 0;

x_list = [X_play;X_play*0];
u_list = [U_play;U_play*0];
set(gcf,'color','w');

M = rob_anim(fig,t_play,x_list,u_list,[],rob,gnd,[az,el]);

M_list{test_num} = M;

end

%% save_video(M,'synt1.mj2');
m = size(M_list{1}(1).cdata,1);
n = size(M_list{1}(1).cdata,2);

white_margin = zeros(50,n,3,'uint8')+255;
loops = length(M_list{1});
F(loops) = struct('cdata',[],'colormap',[]);

for i = 1:loops
    image= [M_list{1}(i).cdata;white_margin;M_list{2}(i).cdata;white_margin;M_list{3}(i).cdata];
%     imwrite(image,sprintf('pic/synt-%d.png',i-1),'png','BitDepth',8);
    F(i) = im2frame(image,[]);
end

save_video(F,'synt.avi');
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
