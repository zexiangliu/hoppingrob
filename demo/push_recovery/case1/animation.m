rob = SimHopRob(1/15,1/10,1);

fig = figure(3);
az = 45;
el = 30;

M = rob_anim(fig,Yt_list,Yx_list([1,2],:),Yx_list([5,6],:),[],rob,gnd,[az,el]);

save_video(M,'PR_case1.avi');
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