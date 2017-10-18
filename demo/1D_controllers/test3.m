clear all;close all;
% bnd = [-10,10;
%     -10,10];
% gridsize = [5,5];
% gnd = Ground(bnd,gridsize,1);
% 
% [X,Y,V]=gnd.ground_gen_rand(0.0);
% % mesh(X,Y,V)
% % surf(X,Y,V,'EdgeColor','None');
% %%
% for i = 1:20
%     gnd.add_hole(rand(1)*0.5,'circle',(rand(2,1)-0.5)*10);
% %     gnd.add_hole(rand(1)*0.6,'circle',2*[i-2.5;0]);
% end
% 
% gnd.visual_holes();
% save gnd gnd
load gnd
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
R = 7;
Bnd_list = ProjBnd(R,Int_list);
%%
% Controller Generation, SwPt_list saves all the switch points and
% Cont_list saves all the controllers' candidate
load ts_ref
% profile on
tic
[SwPt_list, Cont_list, Ures_list, Bnd_Grid] = ContGener_compact(Bnd_list,Dist_list,M_X,M_U,cont,ts);
toc
% profile viewer
%%
% load gnd
% fig = figure(1);
% fig2 = figure(2);
% freq = [];
% for i = 1:5%length(SwPt_list)
%     for j = 1:length(SwPt_list{i})
%         if(~isempty(Dist_list{i}{j}))
%             j
% %             hold off;
%             freq = [freq;comb_win3(fig,SwPt_list{i}{j},M_X,Cont_list,Bnd_list{i}{j},Dist_list{i}{j},Bnd_Grid{i}{j},M_U.V{1}(1))]
% 
% %             visual_comb_win2(fig,SwPt_list{i}{j},M_X,Cont_list,Bnd_list{i}{j},Dist_list{i}{j},Bnd_Grid{i}{j},M_U.V{1}(1));
% %             hold off;
% %             list_deg(i)
% %             Int_list{i}(j:j+1)
% %             d = mean(Int_list{i}(j:j+1));
% %             gnd.visual_holes(fig2);
% %             x = linspace(-Bnd_list{i}{j},Bnd_list{i}{j},100);
% %             y = tand(list_deg(i))*(x-d*sind(list_deg(i)))+d*cosd(list_deg(i));
% %             plot(x,y,'r-','linewidth',1);
% %             pause();
% %             drawnow;
%         end 
%     end
% end
%%
% i=1;j=24;
% fig = figure;
% subplot(1,2,1)
% visual_comb_win2(fig,SwPt_list{i}{j},M_X,Cont_list,Bnd_list{i}{j},Dist_list{i}{j},Bnd_Grid{i}{j},M_U.V{1}(1));
% subplot(1,2,2)
% hold on;
% list_deg(i)
% Int_list{i}(j:j+1)
% d = mean(Int_list{i}(j:j+1));
% gnd.visual_holes(fig2);
% x = linspace(gnd.bnd(1,1),gnd.bnd(1,2),100);
% y = tand(list_deg(i))*(x-d*sind(list_deg(i)))+d*cosd(list_deg(i));
% plot(x,y,'r-','linewidth',Int_list{i}(j+1)-Int_list{i}(j));

%%
% load gnd
% fig = figure(1);
% counter = 0;
% for i = 1:5
%     for j = 1:length(Dist_list{i})
%         if(~isempty(Dist_list{i}{j}))
%             hold on;
%             list_deg(i)
%             Int_list{i}(j:j+1)
%             d = mean(Int_list{i}(j:j+1));
%             gnd.visual_holes(fig);
%             x = linspace(-Bnd_list{i}{j},Bnd_list{i}{j},100);
%             y = tand(list_deg(i))*(x-d*sind(list_deg(i)))+d*cosd(list_deg(i));
%             plot(x,y,'g-','linewidth',Int_list{i}(j+1)-Int_list{i}(j));
%             drawnow;
%             counter = counter+1;
%         end 
%     end
% end
% 
% i=1;j=11;
% list_deg(i)
% Int_list{i}(j:j+1)
% d = mean(Int_list{i}(j:j+1));
% gnd.visual_holes(fig);
% x = linspace(-Bnd_list{i}{j},Bnd_list{i}{j},100);
% y = tand(list_deg(i))*(x-d*sind(list_deg(i)))+d*cosd(list_deg(i));
% plot(x,y,'r-','linewidth',2);
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