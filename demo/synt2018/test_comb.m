%% save_video(M,'synt1.mj2');
m = size(M_list{1}(1).cdata,1);
n = size(M_list{1}(1).cdata,2);

white_margin = zeros(50,n,3,'uint8')+255;
loops = length(M_list{1});
F(loops) = struct('cdata',[],'colormap',[]);

for i = 1:loops
    image= [M_list{1}(i).cdata;white_margin;M_list{2}(i).cdata;white_margin;M_list{3}(i).cdata];
%     imwrite(image,sprintf('pic/synt-%d.png',i-1),'png','BitDepth',8);
    F(i) = im2frame(image,[]);
end

save_video(F,'synt.avi');