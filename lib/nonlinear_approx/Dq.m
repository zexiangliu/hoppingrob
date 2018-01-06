function D = Dq(q,u,r)
    [Hc,Hd] = Hessian(q,u,r);
    n = length(Hc);
    p = length(r);
    sigma = (p+2)*(p+1)/2 - 1;
    
    d = zeros(n,1);
    gener = zeros(n,sigma);
    e = zeros(n,1);
    
    Z_Br = zonoBox([],r);
    Zc = Z_Br.cv;
    Zgener = Z_Br.gener;
    
    absZBr = Z_Br.abs();
    % quad(H_c^d,Z_Br)
    for i = 1:n
        Q = Hc{i};
        d(i) = Zc'*Q*Zc + 0.5*trace(Zgener'*Q*Zgener);
        gener(i,1:p)= Zc'*(Q+Q')*Zgener;%Zc'*Q*Zgener + (Zgener'*Q*Zc)';
        
        gQg = Zgener'*Q*Zgener;
        gener(i,p+1:2*p) = 1/2*diag(gQg)';
        
        cnt = 1;
        for j = 1:p-1
            for k = j+1:p
                gener(i,2*p+cnt)=gQg(j,k)+gQg(k,j);
                cnt = cnt + 1;
            end
        end    
        e(i) = absZBr'*Hd{i}*absZBr;
    end
    
    quad_Hc = Zonotope(d,gener);
    eta_Hd = zonoBox([],e);
    D = quad_Hc + eta_Hd;
end
