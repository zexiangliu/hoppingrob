close all;
bnd = [-10,10;
    -10,10];
gridsize = [5,5];
gnd = Ground(bnd,gridsize,1);

[X,Y,V]=gnd.ground_gen_rand(0.1);
% mesh(X,Y,V)
% surf(X,Y,V,'EdgeColor','None');
%%
for i = -2:2
    gnd.add_hole(rand(1),'circle',[1;2*i]);
end

gnd.visual_holes();

%%
gnd.visual_ground();
axis equal;

% Hough Transform
[Mc,Md] = Hough(gnd);

% Find all the lines
lines = SegDetect(Mc,Md);


 
