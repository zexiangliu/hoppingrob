function [t_next, s_next] = rk4(dyn,t,s,param,dt)
    
    k1 = dt * dyn(t,s,param);
    k2 = dt * dyn(t+dt/2,s+k1/2,param);
    k3 = dt * dyn(t+dt/2,s+k2/2,param);
    k4 = dt * dyn(t+dt,s+k3,param);

    s_next = s + 1/6*(k1+k2+k3+k4);
    t_next = t + dt;
end