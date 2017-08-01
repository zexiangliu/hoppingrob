function visual_all(fig,M_X,B_list,bnd_B,W,idx)
    if(nargin == 5)
        idx = [];
    end
    figure(fig);
    hold on;
    M_X.visual(fig,1:M_X.numV-1,'.b',8,idx);
    M_X.visual_bnd(fig,[],'black',1.5,idx);
    axis equal;
    M_X.visual(fig,B_list,'.r',12,idx);
    M_X.visual_bnd(fig,bnd_B,'red',2,idx);
    M_X.visual(fig,W,'.c',12,idx);
end