% xy = -2.5 + 5*gallery('uniformdata',[200 2],0);
% x = xy(:,1);
% y = xy(:,2);
% v = x.*exp(-x.^2-y.^2);
close all;
bnd = [-3,3;
    -3,3];
gridsize = [5,5];
gnd = Ground(bnd,gridsize,1);

[X,Y,V]=gnd.ground_gen_rand(0.1);
% mesh(X,Y,V)
% surf(X,Y,V,'EdgeColor','None');
%%
for i = 1:2
    gnd.add_hole(0.3,'square')
end

gnd.visual_holes();

%%
gnd.visual_ground();
axis equal;