function square(figure,pos,r)
hold on;
x = pos(1);
y = pos(2);
V = [x-r,y-r,0;
    x-r,y+r,0;
    x+r,y+r,0;
    x+r,y-r,0];
fac = [1,2,3,4]
patch('Faces',fac,'Vertices',V,'FaceColor','black');
end