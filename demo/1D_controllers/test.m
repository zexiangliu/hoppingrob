clear all;close all;
bnd = [-10,10;
    -10,10];
gridsize = [5,5];
gnd = Ground(bnd,gridsize,1);

[X,Y,V]=gnd.ground_gen_rand(0.1);
% mesh(X,Y,V)
% surf(X,Y,V,'EdgeColor','None');
%%
for i = -2:2
    gnd.add_hole(rand(1)*0.3,'circle',[1;2*i]);
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
%%
% Controller Generation, SwPt_list saves all the switch points and
% Cont_list saves all the controllers' candidate
load ts_ref
% profile on
[SwPt_list, Cont_list, Ures_list] = ContGener(Bnd_list,Dist_list,M_X,M_U,cont,ts);
% profile viewer
%%
fig = figure;
for i = 1:length(SwPt_list)
    for j = 1:length(SwPt_list{i})
        if(~isempty(Dist_list{i}{j}))
            hold off;
            visual_comb_win(fig,SwPt_list{i}{j},M_X,Cont_list,Bnd_list{i}{j},Dist_list{i}{j});
            pause(0.5);
            drawnow;
        end 
    end
end
%%
% zero = 0;
save conts.mat SwPt_list Ures_list Bnd_list Dist_list % -v7.3
%%
% i = 90;
% j = 5;
% fig = figure(1);
% winning_full = visual_comb_win(fig,SwPt_list{i}{j},M_X,Cont_list,Bnd_list{i}{j},Dist_list{i}{j});
% 
% n1 = length(M_X.V{1});
% n2 = length(M_X.V{2});
% 
% len_X = M_X.bnd(1,2)-M_X.bnd(1,1);
% 
% V1 = M_X.V{1}(1:floor(n1/2));
% V2 = M_X.V{2}((ceil(n2/2)+1):end);
% 
% [Vx,Vy]=meshgrid(V1,V2);
% 
% num_l = floor((Bnd_list{i}{j}*2-len_X)/M_X.gridsize(1));
% freq = zeros(num_l,1);
% 
% Vx = Vx - Bnd_list{i}{j} + len_X/2;
% 
% for l = 1:num_l
%     
%     mask = [Vx(:),Vy(:)];
% 
%     freq(l) = conv_win(winning_full,mask,M_X.gridsize/2);
%     
%     
%     Vx = Vx + M_X.gridsize(1);
%     
% end
% 
% figure;
% plot(freq)