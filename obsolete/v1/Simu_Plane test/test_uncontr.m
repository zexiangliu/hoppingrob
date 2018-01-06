%% Visualization
% Visualization of state space
bnd = M_X.bnd;
u = M_X.gridsize;
discr_bnd = M_X.discr_bnd;
[U,V] = meshgrid(bnd(1,:),bnd(2,:));
f=[1,2,4,3];
v = [U(:),V(:)];
patch('Faces',f,'Vertices',v,...
    'EdgeColor','black','FaceColor','none','LineWidth',2)

hold on;
x = linspace(discr_bnd(1,1),discr_bnd(1,2),discr_bnd(1,3));
y = linspace(discr_bnd(2,1),discr_bnd(2,2),discr_bnd(2,3));
[X,Y] = meshgrid(x,y);
plot(X,Y,'.b','markersize',8);
axis equal;
% Visualization of the target set
[x1,x2] = get_coord(B_list,M_X);
plot(x1,x2,'.r','markersize',12);    % nodes included

[U,V] = meshgrid([bnd_B(1,:)],[bnd_B(2,:)]);
f=[1,2,4,3];
v = [U(:),V(:)];
% norm ball
patch('Faces',f,'Vertices',v,...
    'EdgeColor','red','FaceColor','none','LineWidth',2);

% Visualization of winning set
[x1,x2] = get_coord(W,M_X);
plot(x1,x2,'.c','markersize',12);    % nodes included

[U,V] = meshgrid([bnd_B(1,:)],[bnd_B(2,:)]);
f=[1,2,4,3];
v = [U(:),V(:)];
%%
[x,y]=ginput(1);
idx_x = mapping([x;y],M_X,eta/2);

idx_Xt =[];
for u = 1:ts.n_a-1
    idx_Xt = [idx_Xt;ts.fast_post{ts.n_s*(u-1)+idx_x}'];
end
idx_Xt(idx_Xt==ts.n_s)=[];
[x1,x2] = get_coord(idx_Xt,M_X);
plot(x1,x2,'og');