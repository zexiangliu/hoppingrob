function [M_l,M_u,Mc_l,Mc_u,list_deg,delta_deg]= Hough(holes,N,list_r)
% Make hough transformation for holes on the ground
% Input: gnd    --- the Ground structure
%        list_r --- the list of radius of holes (or the radius of cicumcircle)
%        N      --- the num of pieces in which we divide the circle
% Output: M_l,M_u  --- the interval matrix [M] which is the Hough
%                       coordinates of holes
%         Mc_l,Mc_u --- the interval matrix [Mc] which is the Hough coord
%                       of center of holes (with disturb of deg.)
%         list_deg  --- list of line directions
%         delta_deg --- the step size of line directions
% matrix and Md contains the size of intervals. The interval matrix
% represents the pos of holes in Hough coord, where the center is the pos
% of centers of holes and intervals come from the sizes of holes.

num_hole = length(holes);


if(nargin == 1)
    N = 180;
    list_r = [];
elseif(nargin == 2)
    list_r = [];
end

if(length(list_r)==1)
    list_r = list_r * ones(num_hole,1);
end

% temp matrix
M_l = zeros(N,num_hole);
M_u = zeros(N,num_hole);

Mc_l = M_l;
Mc_u = M_u;

% nor = zeros(N,2);
list_deg = linspace(1,180,N)';
delta_deg = 179/(N-1);

% calculate all the normal vectors 
% for i = 1:N
% %     dir = [cosd(i),sind(i)]; % direction of line
%     nor(i,:) = [sind(list_deg(i)),-cosd(list_deg(i))]; % normal vector of line    
% end

for j = 1:num_hole
    % calculate the phase and magnitude
    pos = holes{j}.pos;
    phi = atan2d(pos(1),pos(2));
    mag = norm(pos);
    
    lb = list_deg + phi - delta_deg/2;
    ub = list_deg + phi + delta_deg/2;
    
    [Mc_l(:,j),Mc_u(:,j)] = bnd_cos(lb,ub,mag);

    if(isempty(list_r))
        if(strcmp(holes{j}.type,'circle'))
            M_l(:,j) = Mc_l(:,j) - holes{j}.r;
            M_u(:,j) = Mc_u(:,j) + holes{j}.r;
        else
            M_l(:,j) = Mc_l(:,j) - holes{j}.r*sqrt(2);
            M_u(:,j) = Mc_u(:,j) + holes{j}.r*sqrt(2);
        end
    else
        M_l(:,j) = M_l(:,j) - list_r(j);
        M_u(:,j) = M_u(:,j) + list_r(j);
    end
    
end

end