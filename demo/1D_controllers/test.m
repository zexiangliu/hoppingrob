% clear all;close all;
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

r_list = zeros(length(gnd.holes),1);

for i = 1:length(gnd.holes)
    r_list(i) = gnd.holes{i}.r;
end

% Hough Transform
[M_l,M_u,Mc_l,Mc_u,list_deg,delta_deg] = Hough(gnd.holes);

% Find all the lines, Int_list saves the element intervals, seg_list saves
% the holes in each interval.
[Int_list, Seg_list] = SegDetect(M_l,M_u);

% Str_list saves the size of each holes
Str_list = ExtractStr(Int_list,Seg_list,Mc_l,Mc_u,r_list);

% Dist_list saves the pos of holes on projected line
Dist_list = ProjHole(gnd.holes,Seg_list,Str_list,list_deg,delta_deg);

% Bnd_list saves the boundary of projected lines in a circle region
R = 5;
Bnd_list = ProjBnd(R,Int_list);

% Controller Generation, SwPt_list saves all the switch points and
% Cont_list saves all the controllers' candidate
load ts_ref
[SwPt_list, Cont_list, Ures_list] = ContGener(Bnd_list,Dist_list,M_X,M_U,cont_ref,ts);
