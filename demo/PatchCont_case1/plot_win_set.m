% clc;clear all;close all;
% load visual
% 
% num_cont = length(cont);
% 
% fig = figure(1);
% 
% M_X.visual_grid(fig,1:M_X.numV-1,[0,0,0],1);
% 
% % color = ['g','r','y','b','g','m'];
% color = [178,255,255]/255;
% for i = 1:num_cont
%     W = cont{i}.sets{end};
%     hold on;
% %     M_X.visual(fig,W,['.',color],8);
%     M_X.visual_grid(fig,W,color,0.3);
% end
% 
% %%
% % hold on;
% % W = cont{1}.sets{end};
% % M_X.visual(fig,W,['.','c'],4);
% 
% % axis equal
% axis([M_X.bnd(1,:),M_X.bnd(2,:)])


clc;clear all;close all;
load visual

num_cont = length(cont);

fig = figure(1);
X = M_X.V{1};
Y = M_X.V{2};
len_X = length(X);
len_Y = length(Y);
Z = zeros(len_X,len_Y);

for i = 1:num_cont
    W = cont{i}.sets{end};
    for j = 1:length(W)
        [subx,suby] = ind2sub([len_X,len_Y],W(j));
        Z(subx,suby)=Z(subx,suby)+1;
    end
end
%%
[C,h]=contourf(X,Y,Z');

clabel(C,h,'FontSize',12)
set(gca,'fontsize',10)
% colorbar

axis equal
axis([M_X.bnd(1,:),M_X.bnd(2,:)])


