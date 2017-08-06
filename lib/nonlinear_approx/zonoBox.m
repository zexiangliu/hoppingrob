function box = zonoBox(center,radius)
% Generate a hyper-rectangle box in the form of zonotope
% input: center --- coordinates of center of the box. Default is
%                   origin.
%        radius --- a vector, the size of the box

if(isempty(center))
    center = zeros(length(radius),1);
end

if(length(radius)==1)
    gener = radius*ones(length(center));
else
    gener = diag(radius);
end

box = Zonotope(center,gener);
end
