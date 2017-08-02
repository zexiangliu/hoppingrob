function M = rob_anim(fig,t_list,x_list,u_list,bnd_B,rob,gnd,prespect,flag_CoM)
% input: fig   ---- figure handle
%        Yt_list -- output of simulation
%        Yx_list -- output of simulation
%        bnd_B ---- boundary of target set, has to be 2xm matrix
%        rob   ---- SimHopRob structure
%        gnd   ---- Ground structure
%        prespect-- a vector of camera prespective information, e.g.
%                   [az,el]
% output: M    ---- a set of frames
    % user can choose show boundary of target set or not.
    if(nargin == 8)
        flag_CoM = 0;
    end
    h0 = rob.Height;
    if(isempty(bnd_B))
        flag_b = 0;
    else
        flag_b = 1;
        % B_list
        Target.vert = [bnd_B(1,1),bnd_B(2,1),h0
            bnd_B(1,1),bnd_B(2,2),h0
            bnd_B(1,2),bnd_B(2,2),h0
            bnd_B(1,2),bnd_B(2,1),h0
            ];
        Target.fac = [1,2,3,4];
    end
    
    t = 0;
    if(~isempty(prespect))
        az = prespect(1);
        el = prespect(2);
        flag_p = 1;
    else
        flag_p = 0;
    end
    % hold on;
    gnd.visual_update();
    for i = 1:length(t_list)
        if(KeyCallback())
            KeyCallback('reset');
            break;
        end
        pause(t_list(i)-t);
        t= t_list(i);
        hold off;
        hopping_height = 0;%1/4*abs(sin((3*pi/2/0.08)*t));
        
        if(flag_CoM==1)
            plot3(x_list(1,1:i),x_list(2,1:i),h0*ones(1,i),'or','markersize',1);
            hold on;
        end
        
        rob.visual(fig,[x_list(1,i);x_list(2,i);h0],[u_list(1,i);...
            u_list(2,i);hopping_height]);
        hold on;
        gnd.visual_ground(fig);
        if(flag_b)
            patch('Faces',Target.fac,'Vertices',Target.vert,'FaceColor',...
                'none','EdgeColor','red');  % patch function
        end
        % camera configuration
    %     axis([x1min-lmax, x1max+lmax, -0.5, 0.5, -0.5, 1.5]); 
        axis equal;
        if(flag_p)
            view(az, el);
        end
        drawnow;
        M(i) = getframe;
    end
end