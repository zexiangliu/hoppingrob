classdef GridGener < handle
	properties (SetAccess = protected)
        gridsize;
        bnd;
		discr_bnd;
        V;
        ind2sub;
        ind2ind;
        numV;
        numVfull;
        withCons;
    end
methods 
    % Generate uniform grid of set A given the boundaries and grid size [A]_u 
    function Mesh = GridGener(DiscrConfig,ConsConfig)
        % Input: a structure containing discretization configuration
        % ~.bnd : nx2 matrix, i^th row [left_bound, right_bound] for i^th elem in
        %        R^n
        % ~.gridsize 
        % Output: Input + discr_bnd
        % ~.discr_bnd: nx2 matrix, i^th row [ln,rn,num] means left node
        % position ln, right node pos rn and # nodes in total in this dimension
        Mesh.withCons = true;
        if(nargin == 1)
            default_cons_fun = @(coord,ConsConfig)true;
            ConsConfig.cons_fun = default_cons_fun;
            Mesh.withCons = false;
        end
        Mesh.gridsize = DiscrConfig.gridsize;
        Mesh.bnd = DiscrConfig.bnd;

        bnd = DiscrConfig.bnd;            % boundary values for set A
        u = DiscrConfig.gridsize;       % size of grid

        if(size(bnd,2)~=2)
            error('DiscrConfig.bnd should have 2 columns.');
        end

        range = abs(bnd(:,2)-bnd(:,1));  % range of each dimension
        num_node = ceil(range./u-1); % num of discretized points in each dimension
        num_node(num_node<0)=0;
        bnd_layer = (range-num_node.*u)/2;

        % discretize the boundaries
        Mesh.discr_bnd = [bnd(:,1)+bnd_layer, bnd(:,2)-bnd_layer, num_node+1]; 
        % 
        % num = floor((bnd(:,2)-bnd(:,1))/u);
        % Mesh.discr_bnd = [bnd(:,1),bnd(:,1)+num*u,num+1]; % discretize the boundaries

        %% pre-calculation
        % % Generate the data needed by mapping
        n =  size(Mesh.discr_bnd,1);
        if(n~=length(Mesh.gridsize))
            Mesh.gridsize = ones(n,1)*Mesh.gridsize;
        end
        Mesh.V = cell(n,1);          % vertex in the grid, catagorized according to dimension
        for i = 1:n
            Mesh.V{i}=linspace(Mesh.discr_bnd(i,1),Mesh.discr_bnd(i,2),Mesh.discr_bnd(i,3));
        end

        % n =  size(Mesh.bnd,1);
        num_V = prod(Mesh.discr_bnd(:,3));
        Mesh.numVfull = num_V + 1;
        Mesh.ind2sub=zeros(num_V,n,'uint32');
        % for i = 1:num_V
        %     Mesh.ind2sub(i,:)=ind2sub2(Mesh.discr_bnd(:,3),i)';
        % end

        %% Check the real boundary of the region and build up the hash mapping index of rectangle 
        % region to the region of interest
        count = 1;
        cons_fun = ConsConfig.cons_fun;
        Mesh.ind2ind = sparse(num_V+1,1);
        for i = 1:num_V
            coord = Mesh.get_coord_full(i);
            if(feval(cons_fun,coord,ConsConfig)==1)
                Mesh.ind2ind(i)=count;
                Mesh.ind2sub(count,:) = ind2sub2(Mesh.discr_bnd(:,3),i)';
                count = count+1;
            end
        end
        Mesh.numV = count;
        % Mesh.ind2ind(num_V+1,1)=count;
        % Mesh.ind2ind(Mesh.ind2ind==0)=count;
        if(count ~= num_V+1)
            Mesh.ind2sub(count:end,:)=[];
        end
        if(nargin == 1)
            Mesh.ind2ind = [];
        end
    end

    function coord = get_coord_full(Mesh,X)
        sub = ind2sub2(Mesh.discr_bnd(:,3),X);
        coord = Mesh.discr_bnd(:,1) + (sub-1).*Mesh.gridsize;
    end
    
    function [v1,v2,varargout] = get_coord(Mesh,X,idx)
        % input index of nodes and mesh structure, return the coordinates of input
        % nodes
        nout = max(nargout,1);
        x_B = double(Mesh.ind2sub(X,:)); % xt
        n = length(Mesh.discr_bnd(:,1));
        coord = zeros(n,length(X));

        for i = 1:n
            % ith coordinates of all nodes in X
            coord(i,:) = Mesh.discr_bnd(i,1)+(x_B(:,i)'-1)*Mesh.gridsize(i);
        end

        if(nout>2)
            v1 = coord(1,:)';
            v2 = coord(2,:)';
            for i = 3:nout
                varargout{i-2}=coord(i,:)';
            end
        elseif (nout==2)
            v1 = coord(1,:)';
            v2 = coord(2,:)';
        else
            v1 = coord; % output everything if nout == 1
        end
    end
    
    function fig = visual(Mesh, fig, X, MAC, markersize)
        % input: fig: figure handle
        %        X: set for visualization
        %        MAC: marker and color (option of plot)
        %        markersize
        if(nargin == 4)
            markersize = 1;
        end
        coords = get_coord(Mesh, X);
        figure(fig);
        plot(coords(1,:),coords(2,:),MAC,'markersize',markersize);
    end
    
     function fig = visual_bnd(Mesh, fig, bnd, color,linewidth)
        % input: fig: figure handle
        %        color
        if(nargin == 2)
            color = 'black';
            linewidth = 2;
        elseif (nargin == 3)
            linewidth = 2;
        end
        if(isempty(bnd))
            bnd = Mesh.bnd;
        end
        [U,V] = meshgrid(bnd(1,:),bnd(2,:));
        f=[1,2,4,3];
        v = [U(:),V(:)];
        patch('Faces',f,'Vertices',v,...
        'EdgeColor',color,'FaceColor','none','LineWidth',linewidth)
    end
end
end