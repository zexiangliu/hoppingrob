function [Rq,Rq_tube]=reachTubeExt(rec,tau,Aq,fq,Dq)
    q = rec.getMidpoint';
    eta = (rec.xmax-rec.xmin)';
    X_q_hat = zonoBox([],eta/2);
    X0 = zonoBox(q,eta/2);
    e_At = expm(Aq*tau);
    
    % Calculate G
    if(rank(Aq) == length(Aq))
        G = (-Aq)\(eye(size(Aq))-e_At);
    else
        f = @(t) expm(Aq.*(tau-t));
        G = integral(f,0,tau,'ArrayValued',true);
    end
    
    % Calculate alpha, beta, gamma
    inf_A = norm(Aq,'inf');
    expA = exp(tau*inf_A);
    com_fact = (expA - 1 - tau*inf_A);
    one = ones(length(Aq));
    
    inf_x = sum(abs(X0.gener),2);
    nx1 = norm(X0.cv+inf_x,'inf');
    nx2 = norm(X0.cv-inf_x,'inf');
    alpha_t = com_fact*max(nx1,nx2)*one;
    
    max_u = max(abs(Dq.cv)+sum(abs(Dq.gener),2));
    beta_t = com_fact*inf_A^(-1)*max_u*one;
    
    gamma_t = com_fact*inf_A^(-1)*norm(fq,'inf')*one;
    
    Yt = (e_At*X_q_hat) + G*fq + tau*Dq + zonoBox([],beta_t);
    
    Rq = Yt + q;
    
    B_ag = zonoBox([],alpha_t+gamma_t);
    
    Rq_tube = CH(X_q_hat,Yt+B_ag) + q;%CH(X_q_hat,Yt+B_ag)+q;
    
    % clean zero generators
    Rq.clean_gener;
    Rq_tube.clean_gener;
end