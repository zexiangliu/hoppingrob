function [lf,uf] = bnd_cos(lb,ub,mag)
% Give the interval [lb,ub], return the range of cos([lb,ub])
% unit: deg
% Input: bnd, mag
    if(nargin == 2)
        mag = 1;
    end
    
    cos_lb = mag*cosd(lb);
    cos_ub = mag*cosd(ub);
    lf = min(cos_lb,cos_ub);
    uf = max(cos_lb,cos_ub);
    
    % detect the peaks of cos
    l_int = ceil(lb/90);
    u_int = floor(ub/90);
    
    idx = find(l_int <= u_int);
    
    for i = idx'
        list_peaks = mag*cosd([l_int(i):u_int(i)]*90);
        
        lf(i) = min([list_peaks,lf(i)]);
        uf(i) = max([list_peaks',uf(i)]);
    end
    
end