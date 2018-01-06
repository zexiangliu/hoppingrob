classdef Ground<handle
    properties (SetAccess = private)
        bnd;
        holes;
        gridsize;
        X; % x-coordinates of vertices
        Y; % y-coordinates of vertices
        V; % coordinates of vertices
        % mode = 0 (default), linear surface
        % mode = 1 smooth surface by interpolation 
        mode; 
        X_interp; % finer grid for visualization
        Y_interp;
        V_interp;
        hlim_hole; % height limit of holes
        V_animation; % grid values for animation (ground+holes)
        bnd_visual
    end
    
    methods
        function gnd = Ground(bnd,num_grid,mode,bnd_visual)
            % bnd is the boundary of ground
            % bnd_visual is the boundary of ground which is visualized
            if(nargin==3)
                bnd_visual=bnd;
            end
            gnd.bnd = bnd; % bnd = [xmin,xmax;ymin,ymax]
            gnd.holes = {};
            x = linspace(bnd(1,1),bnd(1,2),num_grid(1));
            y = linspace(bnd(1,1),bnd(1,2),num_grid(2));
            [gnd.X,gnd.Y]=meshgrid(x,y);
            gnd.V = zeros(size(gnd.X));
            gnd.mode = mode;
            gnd.bnd_visual=bnd_visual;
            x = linspace(bnd_visual(1,1),bnd_visual(1,2),num_grid(1)*20);
            y = linspace(bnd_visual(1,1),bnd_visual(1,2),num_grid(2)*20);
            [gnd.X_interp,gnd.Y_interp]=meshgrid(x,y);
            gnd.V_interp = zeros(size(gnd.X_interp));
            gnd.hlim_hole = 10;
            gnd.V_animation = gnd.V_interp;
        end
        
        function [X,Y,V]=ground_gen_rand(gnd,hlim)
            % hlim is height limitation of the ground, set the height of
            % summit of ground is 0.
            gnd.V = -rand(size(gnd.X))*hlim;
            
%             % set some points as zero
%             idx_zero = randi(numel(gnd.V),ceil(numel(gnd.V)/3),1);
%             gnd.V(idx_zero)=0;
            if(gnd.mode == 0)
                gnd.V_interp = griddata(gnd.X,gnd.Y,gnd.V,gnd.X_interp,gnd.Y_interp,'linear');
                X = gnd.X_interp;
                Y = gnd.Y_interp;
                V = gnd.V_interp;
            else
                gnd.V_interp = griddata(gnd.X,gnd.Y,gnd.V,gnd.X_interp,gnd.Y_interp,'natural');
                X = gnd.X_interp;
                Y = gnd.Y_interp;
                V = gnd.V_interp;
            end
            if(hlim~= 0)
                gnd.hlim_hole = hlim/2;
            else
                gnd.hlim_hole = 0.1;
            end
        end
        
        function [height]=get_height(gnd,X,Y)
            % input the x-coordinates and y-coordinates
            % return heights
            height = griddata(gnd.X,gnd.Y,gnd.V,X,Y,'natural');
            if(isnan(height))
                height = 0;
            end
        end
        
        function [y,height] = IsInHoles(gnd,pos)
            y = false;
            height = 0;
            if(~isempty(gnd.holes))
                for i = 1:length(gnd.holes)
                    tmp = gnd.holes{i};
                    if(all(tmp.type=='square'))
                        if(norm(pos-tmp.pos,'inf')<=tmp.r)
                           y = true;
                           height = gnd.hlim_hole;
                           break;
                        end
                    elseif(all(tmp.type=='circle'))
                        if(norm(pos-tmp.pos)<=tmp.r)
                           y = true;
                           height = gnd.hlim_hole;
                           break;
                        end
                    end
                end
            end
        end
        
        function add_hole(gnd,radius,type,pos)
            % type supported: 'circle', 'square'
            if(nargin==5)
                hole.pos = pos;
            else
                % input the position of hole from mouse
                gnd.visual_holes();
                title('Please Select Position of Holes')
                [x,y]=ginput(1);
                pos = [x;y];
                hole.pos = pos;
                close;
            end
            if(any(pos<gnd.bnd(:,1))||any(pos>gnd.bnd(:,2)))
                error('The hole is out of bound.');
            end
            hole.r = radius;
            hole.h = 10;
            hole.type = type;
            gnd.holes = [gnd.holes,{hole}];
            gnd.visual_update();
        end
        
        function visual_holes(gnd,fig)
            if(nargin==1)
                figure;
            else
                figure(fig);
            end
            contourf(gnd.X_interp,gnd.Y_interp,gnd.V_interp);
            % visualize holes
            if(~isempty(gnd.holes))
               hold on;
               for i = 1:length(gnd.holes)
                   tmp = gnd.holes{i};
                   if(all(gnd.holes{i}.type=='square'))
                       rectangle('Position',[tmp.pos'-[tmp.r,tmp.r],tmp.r*2,tmp.r*2],'FaceColor','black');
                   elseif(all(gnd.holes{i}.type=='circle'))
                       rectangle('Position',[tmp.pos'-[tmp.r,tmp.r],tmp.r*2,tmp.r*2],'Curvature',[1 1],'FaceColor','black');
                   end
               end
            end 
            grid on;
            axis equal;
        end
        
        function visual_ground(gnd,fig)
            if(nargin==1)
                fig = figure;
            else
                figure(fig);
            end
            hold on;
            X=gnd.X_interp;
            Y=gnd.Y_interp;
            V=gnd.V_animation;
%             
%             if(~isempty(gnd.holes))
%                 for i = 1:numel(V)
%                     [flag_hole,h]=gnd.IsInHoles([X(i);Y(i)]);
%                    if(flag_hole)
%                        V(i)=V(i)-h;
%                    end
%                 end
%             end 
            C = (V-min(V(:)))/range(V(:))*1;
%             surf(X,Y,V,C,'EdgeColor','none');
            mesh(X,Y,V,C);
%             axis equal;
        end
        
        function visual_update(gnd)
           % add holes into V_interp
           % only be called before animation
            X=gnd.X_interp;
            Y=gnd.Y_interp;
            V=gnd.V_interp;
            
            if(~isempty(gnd.holes))
                for i = 1:numel(V)
                    [flag_hole,h]=gnd.IsInHoles([X(i);Y(i)]);
                   if(flag_hole)
                       V(i)=V(i)-h;
                   end
                end
            end 
            gnd.V_animation = V;
        end
    end
end