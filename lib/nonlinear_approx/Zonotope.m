classdef Zonotope < handle
    properties
        cv;     % central vector
        gener;  % generators
    end
    
    methods
        function zt = Zonotope(cv,gener)
        % input: cv    ---- central vector
        %        gener ---- matrix where each column is a generator
            if(isempty(cv))
                cv = zeros(size(gener,1),1);
            elseif(size(cv,1)~=size(gener,1)&&~isempty(gener))
                error('some:siz_dismatch:id','Please make sure the dimension of cv and gener are the same.');
            
            end
           
            zt.cv = cv;
            zt.gener = gener;
        end
        
        function y = plus(zt1,zt2)
            if(isa(zt2,'double'))                
                cvNew = zt1.cv + zt2;
                generNew = [zt1.gener];
                y = Zonotope(cvNew,generNew);
                return;
            end
            cvNew = zt1.cv + zt2.cv;
            generNew = [zt1.gener,zt2.gener];
            y = Zonotope(cvNew,generNew);
        end
        
        function y = mtimes(M,zt)
            cvNew = M*zt.cv;
            if(~isempty(zt.gener))
                generNew = M*zt.gener;
            else
                generNew = [];
            end
            y = Zonotope(cvNew,generNew);
        end
        
        function bool = eq(zt1,zt2)
            bool = true;
            if(any(size(zt1.gener)~=size(zt2.gener)))
                bool = false;
                return;
            end
            
            if(any(zt1.cv~=zt2.cv))
                bool = false;
                return;
            end
            
            if(isempty(zt1.gener)&&isempty(zt2.gener))
                return;
            end
            
            g1_sorted = sortrows(zt1.gener')';
            g2_sorted = sortrows(zt2.gener')';
            if(any(any(g1_sorted ~= g2_sorted)))
                bool = false;
                return;
            end
        end
        
        function bool = in(zt,vec)
            % input: vec, the vector you want to see if in the zonotope.
            bool = true;
            Aeq = zt.gener;
            beq = vec - zt.cv;
            % if beq isn't in the range of Aeq, vec isn't in the zonotope
            if(rank([Aeq,beq])~=rank(Aeq))
                bool = false;
                return;
            end
            % see if LS solution is one feasiable solution
            x1 = Aeq\beq;
            x2 = pinv(Aeq)*beq;
            if(all(abs(x1)<=1|abs(x2)<=1))
                bool = true;
                return;
            end
            % if solution is unique, vec isn't in zt
            [m,n] = size(Aeq);
            if(rank(Aeq)==m)
                bool = false;
                return;
            end
            % finally, try linear programming
            f = zeros(n,1);
            ub = ones(n,1);
            lb = -ub;
            [~,~,exitflag,~] = linprog(f,[],[],Aeq,beq,lb,ub);
            if(exitflag == 1)
                bool = true;
            else
                bool = false;
            end
        end
        
        function zt = CH(zt1,zt2)
        % calculate convex hull of two zonotopes
            cvNew = zt1.cv+zt2.cv;
            gc = zt1.cv - zt2.cv;
            [~,n1] = size(zt1.gener);
            [~,n2] = size(zt2.gener);
            n = min(n1,n2);
            g1 = zt1.gener(:,1:n)+zt2.gener(:,1:n);
            g2 = zt1.gener(:,1:n)-zt2.gener(:,1:n);
            g3 = [];
            if(n1<n2)
                g3 = zt2.gener(:,n+1:n2);
            elseif(n1>n2)
                g3 = zt1.gener(:,n+1:n2);
            end
            zt = 1/2*Zonotope(cvNew,[gc,g1,g2,g3]);
        end
        
        function vec = abs(zt)
            vec = abs(zt.cv) + sum(abs(zt.gener),2);
        end
    end
end