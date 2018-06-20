function s_bar = xy2lt(s)
% input: s must be n*4 array

    s_bar = zeros(size(s));
    l = sqrt(s(:,1).^2 + s(:,2).^2);
    theta = acos(-s(:,1)./l);
    s_bar(:,1:2) = [l,theta];
    s_bar(:,3:4) = [-cos(theta).*s(:,3)+sin(theta)*s(:,4), ...
                        sin(theta).*s(:,3)./l + cos(theta).*s(:,4)./l];
    
end