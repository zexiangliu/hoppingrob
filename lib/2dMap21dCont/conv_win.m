function freq = conv_win(winning_full,mask,r)
% Convolute winning set with the mask and return the percentage of points
% of mask in the winning set.

win_cnt = 0;
for i=1 : size(mask,1)
    pos = mask(i,:);
    tmp = min((winning_full(:,1)-pos(1)).^2+(winning_full(:,2)-pos(2)).^2);
    if(tmp<=r^2)
        win_cnt = win_cnt+1;
    end
end

freq = win_cnt/size(mask,1);

end