function r = r_estimate(q,u,tau,eta)
    K = norm(Aq(q,u),'inf');
    r1 = max(eta/2)*exp(K*tau);
    
    f0 = fq(q,u);
    f1 = fq(q+1/2*tau*f0,u);
    f2 = fq(q+1/2*tau*f1,u);
    f3 = fq(q+tau*f2,u);
    
    r = abs(tau/6*(f0+2*f1+2*f2+f3))+r1;

end