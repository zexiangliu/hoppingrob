function s = lt2xy(s_bar)
% input: s_bar must be n*4 array

    l = s_bar(:,1); theta = s_bar(:,2);
    s = zeros(size(s_bar));
    s(:,1) = -l.*cos(theta);
    s(:,2) = l.*sin(theta);
    s(:,3:4) = [-cos(theta).*s_bar(:,3)+l.*sin(theta).*s_bar(:,4), ...
                   sin(theta).*s_bar(:,3)+l.*cos(theta).*s_bar(:,4)];
               
end