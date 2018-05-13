function draw_thy_winset(fig,M_X,lmax,h0,g,tau)
figure(fig);
hold on;
xmax = M_X.bnd(1,2);
xmin = M_X.bnd(1,1);
vmax = M_X.bnd(2,2);
vmin = M_X.bnd(2,1);

v0 = 0:0.01:max(vmax,vmin);

u = lmax;

if(nargin==5)
    dx = dist_utl_stable(v0,u,h0,g);
elseif(nargin==6)
    [dx,x_t,v_t] = dist_utl_stable_tau(v0,u,h0,g,tau);
end
    
x = xmax-dx;
hold on;
x(x>xmax) = xmax;
plot(x,v0,'-r','linewidth',3)

x = xmin+dx;
x(x<xmin) = xmin;
plot(x,-v0,'-r','linewidth',3)

if(nargin==6)  
    x_t = xmax-dx+x_t;  
    plot(x_t,v_t,'o','markersize',3,'MarkerEdge',[0.9290, 0.6940, 0.1250]);
end
axis equal;
axis([xmin,xmax,vmin,vmax])