rob = SimHopRob(1/15,1/10,1);

% % B_list
% 
% Target.vert = [bnd_B(1,1),bnd_B(2,1),h0
%     bnd_B(1,1),bnd_B(2,2),h0
%     bnd_B(1,2),bnd_B(2,2),h0
%     bnd_B(1,2),bnd_B(2,1),h0
%     ];
% Target.fac = [1,2,3,4];

fig = figure(3);
az = abs(atan2(direction(2),direction(1))/pi*180)+45;
el = 25;
M = rob_anim(fig,Yt_list,Yx_list([1,2],:),Yx_list([5,6],:),[],rob,gnd,[az,el],1);

save_video(M,'PR_case5.avi');
% %%
% t = 0;
% for i = 1:length(Yt_list)
%     pause(Yt_list(i)-t);
%     t= Yt_list(i);
% 
%     frame = M(i).cdata;
%     image(frame);
%     drawnow;
% end