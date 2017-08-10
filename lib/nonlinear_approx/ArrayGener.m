function ts = ArrayGener(M_X,M_U,tau,r_max,Aq,fq,Dq,constr_test)
% Generate over-approximate abstraction of nonlinear system    
% input: M_X  ---- mesh structure of state space
%        M_U  ---- mesh structure of input space
%        tau  ---- time interval
%        Aq   ---- function handle which outputs A matrix of linearized system
%        fq   ---- function handle witch outputs fq of linearized system
%        Dq   ---- function handle which approximates the Lagrange
%                  remainder.
%        constr_test ---- function handle with constraints of robot
    num_X =M_X.numV;  % remove the sink node
    num_U = M_U.numV; 
    num_s = 0; % used to count the num of transitions
    
    eta  = M_X.gridsize;
    
    avrg = mean(M_X.bnd,2);
    bnd_X = zonoBox(avrg,M_X.bnd(:,2)-avrg);
    
    transition_list = cell(num_U-1);
%    pg_list = cell(num_U-1);

    for i = 1:num_X-1
        q = M_X.get_coord(i);
        parfor k = 1:num_U-1
%         for k = 1:num_U-1
            r1 = 0*r_max;
            r2 = r_max;
            
            u = M_U.get_coord(k);
            A = feval(Aq,q,u);
            f = feval(fq,q,u);
            X0 = zonoBox(q,eta/2);
            
            % Make sure that r2 is large enough.
            while(1)
                r = r2;
                B_r = Zonotope(q,r);
                D = feval(Dq,q,r);
                [~,Rq_tube]=reachTube(M_X,M_U,q,tau,X0,A,f,D);
                if(zono_contain(Rq_tube,B_r))
                    break;
                else
                    [~,idx] = zono_contain(Rq_tube,B_r);
                    r2(idx) = r2(idx)*2; % alternative way: return distanct, add directly
                end
            end
            
            % Find the smallest feasible r
            while(norm(r2-r1)>1e-3)
                r = 1/2*(r1+r2);
                B_r = Zonotope(q,r);
                D= feval(Dq,q,r);
                [~,Rq_tube]=reachTube(M_X,M_U,q,tau,X0,A,f,D);
                if(zono_contain(Rq_tube,B_r))
                    r2 = r_max;
                else
                    r1 = r_max;
                end
            end
            
            r = r2;
            D= feval(Dq,q,r);
            [Rq,Rq_tube]=reachTube(M_X,M_U,q,tau,X0,A,f,D);
            
            % test the constraints
            % if pass, return 1.
            if(~feval(constr_test,Rq_tube,u))
                continue;
            end
            
            % if Rq is in the finite state space
            if(zono_contain(Rq,bnd_X))
                state1 = zeros(1e3,1,'uint32'); % you can enlarge 1e3 based on the scale of the problem
                state2 = zeros(1e3,1,'uint32');
                counter = 0;
                for j = 1:num_X-1
                    q_pi = M_X.get_coord(j);
                    Bq_pi = Zonotope(q_pi,eta/2);
                    zt_int = Zonotope([],[Rq.gener,Bq_pi.gener]);

                    % If q_pi-Rq.cv is in the zonotope (0,[Bq_pi.gener,Rq.gener]),
                    % then Bq_pi intersects with Rq.
                    if(zt_int.in(q_pi - Rq.cv))
                        counter = counter+1;
                        state1(counter) = i;
                        state2(counter) = j;
                    end
                end
            else
                % if the reachable set outside state space
                state1 = i;
                state2 = num_X;
                counter = 1;
            end
            num_s = num_s + counter;
            transition_list{k} = [transition_list{k};[state1(1:counter),state2(1:counter)]];
        end
    end
    
    ts = TransSyst(num_X,num_U-1,num_s); 
    for i = 1:num_U-1
%         if(~isempty(pg_list{i}))
%            ts.add_progress_group(i,pg_list{i});
%         end
        if(~isempty(transition_list{i}))
           ts.add_transition(transition_list{i}(:,1)',transition_list{i}(:,2)',i*ones(size(transition_list{i},1),1,'uint32')');
        end
    end
end