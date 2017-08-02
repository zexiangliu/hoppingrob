function M = rob_anim(fig,Yt_list,Yx_list,rob,gnd,prespect)
% input: fig   ---- figure handle
%        rob   ---- SimHopRob structure
%        gnd   ---- Ground structure
%        prespect-- a vector of camera prespective information, e.g.
%                   [az,el]
% output: M    ---- a set of frames
    t = 0;
    h0 = rob.Height;
    az = prespect(1);
    el = prespect(2);
    % hold on;
    gnd.visual_update();
    for i = 1:length(Yt_list)
        if(KeyCallback())
            KeyCallback('reset');
            break;
        end
        pause(Yt_list(i)-t);
        t= Yt_list(i);
        hold off;
        hopping_height = 0;%1/4*abs(sin((3*pi/2/tau)*t));
        rob.visual(fig,[Yx_list(1,i);0;h0],[Yx_list(3,i);0;hopping_height]);
        hold on;
        gnd.visual_ground(fig);
        % camera configuration
    %     axis([x1min-lmax, x1max+lmax, -0.5, 0.5, -0.5, 1.5]); 
        axis equal;
        view(az, el);
        drawnow;
        M(i) = getframe;
    end
end