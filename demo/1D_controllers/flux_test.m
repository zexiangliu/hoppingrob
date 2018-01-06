clear all;close all;

abstraction(2.5,10,0); % no visualization

% The compact version

bnd = [-10,10;
    -10,10];
gridsize = [5,5];
gnd = Ground(bnd,gridsize,1);

[X,Y,V]=gnd.ground_gen_rand(0.0);
% mesh(X,Y,V)
% surf(X,Y,V,'EdgeColor','None');
%%
for i = 1:20
    gnd.add_hole(rand(1)*0.5,'circle',(rand(2,1)-0.5)*10);
%     gnd.add_hole(rand(1)*0.6,'circle',2*[i-2.5;0]);
end

save gnd_flux.mat gnd

%%

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
R = 7;
Bnd_list = ProjBnd(R,Int_list);
%%
% Controller Generation, SwPt_list saves all the switch points and
% Cont_list saves all the controllers' candidate
load ts_ref
tic
[SwPt_list, Cont_list, Ures_list, Bnd_Grid] = ContGener_compact(Bnd_list,Dist_list,M_X,M_U,cont,ts);
toc

save conts_flux.mat SwPt_list Ures_list Bnd_list Dist_list % -v7.3
%% Test
load gnd_flux
freq = [];
for i = 1:length(SwPt_list)
    for j = 1:length(SwPt_list{i})
        if(~isempty(Dist_list{i}{j}))
            j
            freq = [freq;comb_win3(SwPt_list{i}{j},M_X,Cont_list,Bnd_list{i}{j},Dist_list{i}{j},Bnd_Grid{i}{j},M_U.V{1}(1))]

        end 
    end
end
save freq_flux.mat freq