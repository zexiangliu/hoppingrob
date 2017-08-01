
rob = SimHopRob(1/15,1/10,[]);

% % B_list
% 
% Target.vert = [bnd_B(1,1),bnd_B(2,1),h0
%     bnd_B(1,1),bnd_B(2,2),h0
%     bnd_B(1,2),bnd_B(2,2),h0
%     bnd_B(1,2),bnd_B(2,1),h0
%     ];
% Target.fac = [1,2,3,4];

fig = figure(3);
% axis([x1min-lmax, x1max+lmax, -0.5, 0.5, -0.5, 1.5]); 
% axis equal;
t = 0;
% hold on;

% gnd.visual_update();

for i = 1:length(Yt_list)/2
    KeyCallback();
    pause(Yt_list(i)-t);
    t= Yt_list(i);
    hold off;
    hopping_height = 0;%h0/4*abs(sin((3*pi/2/tau)*t));
    gnd.visual_ground(fig);
    hold on;
    rob.visual(fig,[Yx_list(1,i);Yx_list(2,i);h0],[Yx_list(5,i);Yx_list(6,i);hopping_height]);
    
    % camera configuration
%     axis([x1min-lmax, x1max+lmax, -0.5, 0.5, -0.5, 1.5]); 
    axis equal;
%     az = 0;
%     el = 90;
%     view(az, el);

    drawnow;
    M(i) = getframe;
    
    % write to video
end

video = VideoWriter('animation.avi');
open(video);
writeVideo(video,M);
close(video);
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