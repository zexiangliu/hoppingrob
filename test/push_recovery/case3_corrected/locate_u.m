function u_located = locate_u(gnd,x0,u0,h0,max_leg)
% given the pos of mass center x0 (2x1) and pos of virtual input u0 (2x1)
% return the real position of input u, that is the intersection of line
% x0-u0 and ground
% Solve using binary search----if multiple intersections exist, the
% algorithm may fail.
% max_leg = sqrt(h0^2+lmax^2); % the maximum length of leg
len_u = norm(u0-x0); %length of x0-u0
len_leg = sqrt(len_u^2+h0^2); % length of leg 
direct_xu = (u0-x0)/len_u;

len_u_prime = max_leg*len_u/len_leg; % len of extended x0-u0
h_u_prime = -(len_u_prime/len_u-1)*h0; % height of extended u0

u_low = [u0;0];
u_high = [len_u_prime*direct_xu;h_u_prime];

h_low = u_low(3)-gnd.get_height(u_low(1),u_low(2));
h_high = gnd.get_height(u_high(1),u_high(2))-u_high(3);

if(abs(h_low)<=1e-5)
    u_located = u_low;
    return;
elseif(abs(h_high)<=1e-5)
    u_located = u_high;
    return;
end

if(h_low<0||h_high<0)
    error('The input is not feasible.');
end

while(norm(u_high-u_low)>1e-5)
    tmp_u = (u_low+u_high)/2;
    tmp_h = gnd.get_height(tmp_u(1),tmp_u(2));
    if(tmp_u(3)>=tmp_h)
        u_low = tmp_u;
    else
        u_high = tmp_u;
    end
end

u_located = u_low;
end