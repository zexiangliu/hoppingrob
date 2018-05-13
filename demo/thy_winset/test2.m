v0 = 0:0.01:4;

u = 1;
h0 = 1;
g = 10;

dx = dist_utl_stable(v0,u,h0,g);

x = 3.5-dx;
hold on;
x(x>2.5)=2.5;
plot(x,v0,'-r','linewidth',5)

x = -3.5+dx;
x(x<-2.5)=-2.5;
plot(x,-v0,'-r','linewidth',5)

axis equal;
axis([-2.5,2.5,-4,4])