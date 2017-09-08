function [lf,uf] = bnd_sin(lb,ub,mag)
% Give the interval [lb,ub], return the range of sin([lb,ub])
% unit: deg
% Input: bnd 
    if(nargin == 2)
        mag = 1;
    end
    
    sin_lb = mag.*sind(lb);
    sin_ub = mag.*sind(ub);
    lf = min(sin_lb,sin_ub);
    uf = max(sin_lb,sin_ub);
    
    % detect the peaks of sin
    l_int = ceil(lb/90);
    u_int = floor(ub/90);
    
    idx = find(l_int <= u_int);
    
    for i = idx'
        list_peaks = mag(i)*sind([l_int(i):u_int(i)]*90);
        
        lf(i) = min([list_peaks,lf(i)]);
        uf(i) = max([list_peaks',uf(i)]);
    end
    
end