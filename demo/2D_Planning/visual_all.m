function [fig1,fig2]=visual(M_X,bnd,X,coord_bias,ROT,type)
% Only visualizate the results of 2D_Planning
if(type == 'X')
    u = M_X.gridsize;
    discr_bnd = M_X.discr_bnd;
    fig1 = figure(1);
    [U,V] = meshgrid(bnd(1,:),bnd(2,:));
    v_u = U(:);
    v_v = V(:);
    v = ROT*[v_u';v_v'];
    v_u = v(1,:)'+coord_bias(1);
    v_v = v(2,:)'+coord_bias(2);

    f=[1,2,4,3];
    v_grid = [v_u,v_v];
    patch('Faces',f,'Vertices',v_grid,...
        'EdgeColor','green','FaceColor','none','LineWidth',2)

    hold on;
    x = get_coord(M_X,X);
    rot_x = ROT*x(1:2,:);
    plot(rot_x(1,:)+coord_bias(1),rot_x(2,:)+coord_bias(2),'.r')
    axis('equal');

    if(length(bnd)>=3)
        fig2 = figure(2);
        [U,V] = meshgrid(bnd(3,:),bnd(4,:));
        v_u = U(:);
        v_v = V(:);
        v = ROT*[v_u';v_v'];
        v_u = v(1,:)'+coord_bias(1);
        v_v = v(2,:)'+coord_bias(2);

        f=[1,2,4,3];
        v_grid = [v_u,v_v];
        patch('Faces',f,'Vertices',v_grid,...
            'EdgeColor','green','FaceColor','none','LineWidth',2)
        hold on;
        x = get_coord(M_X,X);
        rot_x = ROT*x(3:4,:);
        plot(rot_x(1,:)+coord_bias(1),rot_x(2,:)+coord_bias(2),'.')
        axis('equal');
    end
elseif(type == 'U')
    u = M_X.gridsize;
    discr_bnd = M_X.discr_bnd;
    fig1 = figure(1);
    [U,V] = meshgrid(bnd(1,:),bnd(2,:));
    v_u = U(:);
    v_v = V(:);
    v = ROT*[v_u';v_v'];
    v_u = v(1,:)'+coord_bias(1);
    v_v = v(2,:)'+coord_bias(2);

    f=[1,2,4,3];
    v_grid = [v_u,v_v];
    patch('Faces',f,'Vertices',v_grid,...
        'EdgeColor','black','FaceColor','none','LineWidth',2)

    hold on;
    x = get_coord(M_X,X);
    rot_x = ROT*x(1:2,:);
    plot(rot_x(1,:)+coord_bias(1),rot_x(2,:)+coord_bias(2),'.b')
    axis('equal');
elseif(type == 'W')
    fig1 = figure;
    u = M_X.gridsize;
    discr_bnd = M_X.discr_bnd;
    fig1 = figure(1);
    [U,V] = meshgrid(bnd(1,:),bnd(3,:));
    v_u = U(:);
    v_v = V(:);
    v = [v_u';v_v'];
    v_u = v(1,:)';
    v_v = v(2,:)';

    f=[1,2,4,3];
    v_grid = [v_u,v_v];
    patch('Faces',f,'Vertices',v_grid,...
        'EdgeColor','green','FaceColor','none','LineWidth',2)

    hold on;
    x = get_coord(M_X,X);
    rot_x = x([1,3],:);
    plot(rot_x(1,:),rot_x(2,:),'.')
    axis('equal');

end
