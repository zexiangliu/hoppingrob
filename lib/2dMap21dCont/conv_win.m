function freq = conv_win(winning_full,mask,r)
% Convolute winning set with the mask and return the percentage of points
% of mask in the winning set.

win_cnt = 0;
for i=1 : size(mask,1)
    pos = mask(i,:);
    tmp = any(abs(winning_full(:,1)-pos(1))<=r(1)&abs(winning_full(:,2)-pos(2))<=r(2));
    if(tmp)
        win_cnt = win_cnt+1;
    end
end

freq = win_cnt/size(mask,1);

end