function [res] = is_trans(rec1, rec2, u, tau)
  % is_trans: determine if there is a transition from rec1 to rec2
  % under mode dyn = {A, K, E}  (linear)
  %                = {fx, vars} (yalmip-sos)
  %                = pol        (Polynomial-sdsos)
    
    q = rec1.getMidpoint;
    A = Aq(q',u);
    f = fq(q',u);
    eta = (rec1.xmax-rec1.xmin)';
    r = r_estimate(q',u,tau,eta);
    D = Dq(q',u,r);
    [Rq,~]=reachTubeExt(rec1,tau,A,f,D);
        
    f_lin = ones(size(Rq.gener,2),1);
    A_lin = [Rq.gener;-Rq.gener];
    b_lin = [rec2.xmax'-Rq.cv;-rec2.xmin'+Rq.cv];
    options = optimoptions('linprog','MaxIterations',10);
    [~,~,exitflag]=linprog(f_lin,A_lin,b_lin,[],[],-f_lin,f_lin,options);
    
    if(exitflag~=1&&exitflag~=0)
        res = false;
    else
        res = true;
    end
end