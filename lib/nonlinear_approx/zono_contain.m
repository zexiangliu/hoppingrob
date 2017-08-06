function [bool,idx] = zono_contain(zt,box)
% determine if zt is contained by box.
% output: bool   return 1 if zt is contained by box
%         idx    return the idx of dimension where zt is not contained.
    bnd_box = [box.cv-sum(box.gener,2),box.cv+sum(box.gener,2)];
    bnd_zt  = [box.cv-sum(abs(zt.gener),2),box.cv+sum(abs(zt.gener),2)];
    if(all(bnd_zt(:,1)>=bnd_box(:,1))&& all(bnd_zt(:,2)<=bnd_box(:,2)))
        bool = true;
    else
        bool = false;
    end
    if(nargout == 2)
        idx = bnd_zt(:,1)<bnd_box(:,1) | bnd_zt(:,2)>bnd_box(:,2);
    end    
end