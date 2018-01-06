load ts_ref.mat

u_res = [5,6,7,8]+25;

patch_cont_md(cont,ts,u_res);

fig = figure(1); hold on;

M_X.visual(fig,1:M_X.numV-1,'.b',8);
M_X.visual_bnd(fig,[],'black',2);
M_X.visual(fig,B_list,'.r',12);
M_X.visual_bnd(fig,bnd_B,'red',2);
M_X.visual(fig,cont.sets{end},'.c',12);

holes = M_U.get_coord(u_res);
plot(holes,holes*0,'ob','markersize',5)
axis equal