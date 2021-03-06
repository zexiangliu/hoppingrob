function fig = traj_anim(fig,M_X,X_list,idx,tstep,color)
% drawing trajectory of states on the figure handle 'fig'
% input: figure handle: fig
%        grid class   : M_X
%        states       : X_list
%        idx of states: idx
%        time step    : tstep
if(nargin == 3||isempty(idx))
    idx = [1,2];
    tstep = 0.01;
elseif(nargin == 4)
    tstep = 0.01;
end
coords = get_coord(M_X,X_list);
x1 = coords(idx(1),:)';
x2 = coords(idx(2),:)';
for i=1:length(x1)-1
    if(KeyCallback())
        KeyCallback('reset');
        break;
    end
    if(nargin==6)
        arrow('Start',[x1(i),x2(i)],'Stop',[x1(i+1),x2(i+1)],'Length',...
            10,'TipAngle',5,'EdgeColor',color,'FaceColor',color);
    else
        arrow('Start',[x1(i),x2(i)],'Stop',[x1(i+1),x2(i+1)],...
            'Length',10,'TipAngle',5)
    end
    if(tstep>0) 
        pause(tstep);
    end
end


end