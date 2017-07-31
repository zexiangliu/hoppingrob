function visual_all(fig,M_X,B_list,bnd_B,W)
    figure(fig);
    hold on;
    M_X.visual(fig,1:M_X.numV-1,'.b',8);
    M_X.visual_bnd(fig,[],'black',1.5);
    axis equal;
    M_X.visual(fig,B_list,'.r',12);
    M_X.visual_bnd(fig,bnd_B,'red',2);
    M_X.visual(fig,W,'.c',12);
end