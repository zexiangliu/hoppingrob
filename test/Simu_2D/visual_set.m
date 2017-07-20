function visual_set(M_X,X,idx,color)
% figure;
% Visualization of state space
if(nargin == 3)
    color = 'r';
end
if(isempty(M_X))
    load visual_set.mat;
end
discr_bnd = M_X.discr_bnd;

x = linspace(discr_bnd(idx(1),1),discr_bnd(idx(1),2),discr_bnd(idx(1),3));
y = linspace(discr_bnd(idx(2),1),discr_bnd(idx(2),2),discr_bnd(idx(2),3));
[mX,mY] = meshgrid(x,y);
plot(mX,mY,'.b','markersize',8);
axis equal;
hold on;
% Visualization of the target set
coord_x = get_coord(X,M_X);
plot(coord_x(idx(1),:),coord_x(idx(2),:),['.',color],'markersize',12);    % nodes included
