function [Mc,Md]= Hough(gnd,N,list_r)
% Make hough transformation for holes on the ground
% Input: gnd    --- the Ground structure
%        list_r --- the list of radius of holes (or the radius of cicumcircle)
%        N      --- the num of pieces in which we divide the circle
% Output: IntM  --- the interval matrix [Mc+-Md], where Mc is the center
% matrix and Md contains the size of intervals. The interval matrix
% represents the pos of holes in Hough coord, where the center is the pos
% of centers of holes and intervals come from the sizes of holes.

num_hole = length(gnd.holes);


if(nargin == 1)
    N = 180;
    list_r = [];
elseif(nargin == 2)
    list_r = [];
end

if(length(list_r)==1)
    list_r = list_r * ones(num_hole,1);
end

Mc = zeros(N,num_hole);
Md = Mc;

% temp matrix
M_l = Mc;
M_u = Mc;

nor = zeros(N,2);
list_deg = linspace(1,180,N)';
delta_deg = 179/(N-1);

% calculate all the normal vectors 
for i = 1:N
%     dir = [cosd(i),sind(i)]; % direction of line
    nor(i,:) = [sind(list_deg(i)),-cosd(list_deg(i))]; % normal vector of line    
end

for j = 1:num_hole
    % calculate the phase and magnitude
    pos = gnd.holes{j}.pos;
    phi = atand(pos(1)/pos(2));
    mag = norm(pos);
    
    lb = list_deg + phi - delta_deg/2;
    ub = list_deg + phi + delta_deg/2;
    
    [M_l(:,j),M_u(:,j)] = bnd_cos(lb,ub);
    M_l(:,j) = mag*M_l(:,j);
    M_u(:,j) = mag*M_u(:,j);

    if(isempty(list_r))
        if(strcmp(gnd.holes{j}.type,'circle'))
            M_l(:,j) = M_l(:,j) - gnd.holes{j}.r;
            M_u(:,j) = M_u(:,j) + gnd.holes{j}.r;
        else
            M_l(:,j) = M_l(:,j) - gnd.holes{j}.r*sqrt(2);
            M_u(:,j) = M_u(:,j) + gnd.holes{j}.r*sqrt(2);
        end
    else
        M_l(:,j) = M_l(:,j) - list_r(j);
        M_u(:,j) = M_u(:,j) + list_r(j);
    end
    
    Mc = (M_l + M_u)/2;
    Md = (M_u - M_l)/2;
    
end

end