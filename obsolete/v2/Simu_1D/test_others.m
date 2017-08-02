clc;

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
Adj = zeros(length(B_list));
preB= [];

inv_B_list = zeros(626,1);
for i = 1:length(B_list)
    inv_B_list(B_list(i))=i;
end
% Adj = zeros(626);
for j = 1:length(B_list)
    idx = find(ts.state1==B_list(j));
    idx2 = intersect(unique(ts.state2(idx)),B_list);
    preB=[preB;idx2];
    Adj(j,inv_B_list(idx2))=1;
end

Adj=sparse(Adj);
preB = unique(preB)
% h = view(biograph(Adj));

% [S,C] = graphconncomp(Adj);

%%
preB_ts = [];
for i = B_list,
    preB_ts = [preB_ts;ts.fast_pre_all{i}];
end
preB_ts = intersect(B_list,preB_ts)

preB_ts2 = intersect(ts.pre(B_list,[],1,0),B_list)


preB_ts3 = intersect(ts.pre(preB_ts2,[],1,0),B_list)
%%
% x_B = M_X.ind2sub(B_list,:); % xt
% 
% x1 = discr_bnd(1,1)+(x_B(:,1)-1)*u;
% x2 = discr_bnd(2,1)+(x_B(:,2)-1)*u;
% plot(x1,x2,'.r','markersize',12);    % nodes included
% 
% for i = 1:length(Adj)
%     for j = 1:length(Adj)
%         if(Adj(i,j)==1)
%             x_1 = [x1(i);x2(i)];
%             x_2 = [x1(j);x2(j)];
%             arrow('Start',x_1,'Stop',x_2,'Length',1,'TipAngle',10);
%         end
%     end
% end
%%
hold on;
x_B = M_X.ind2sub(B_list,:); % xt

x1 = discr_bnd(1,1)+(x_B(:,1)-1)*u;
x2 = discr_bnd(2,1)+(x_B(:,2)-1)*u;
plot(x1,x2,'.r','markersize',12);    % nodes included

[U,V] = meshgrid([bnd_B(1,:)],[bnd_B(2,:)]);
f=[1,2,4,3];
v = [U(:),V(:)];
% % norm ball
% patch('Faces',f,'Vertices',v,...
%     'EdgeColor','red','FaceColor','none','LineWidth',2);
grid on;
%%
x_B = M_X.ind2sub(preB_ts2,:); % xt

x1 = discr_bnd(1,1)+(x_B(:,1)-1)*u;
x2 = discr_bnd(2,1)+(x_B(:,2)-1)*u;
plot(x1,x2,'.b','markersize',12);    % nodes included

[U,V] = meshgrid([bnd_B(1,:)],[bnd_B(2,:)]);
f=[1,2,4,3];
v = [U(:),V(:)];
% % norm ball
% patch('Faces',f,'Vertices',v,...
%     'EdgeColor','red','FaceColor','none','LineWidth',2);

%%
preB_ts3 =[];
for i = 1:ts.n_a
    preB_ts3=union(preB_ts3,ts.fast_post{(i-1)*ts.n_s+184});
end
preB_ts3(preB_ts3==626)=[];
% preB_ts3=409;
x_B = M_X.ind2sub(preB_ts3,:); % xt

x1 = discr_bnd(1,1)+(x_B(:,1)-1)*u;
x2 = discr_bnd(2,1)+(x_B(:,2)-1)*u;
plot(x1,x2,'.c','markersize',12);    % nodes included

[U,V] = meshgrid([bnd_B(1,:)],[bnd_B(2,:)]);
f=[1,2,4,3];
v = [U(:),V(:)];
% % norm ball
% patch('Faces',f,'Vertices',v,...
%     'EdgeColor','red','FaceColor','none','LineWidth',2);
