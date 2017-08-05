classdef Zonotope < handle
    properties
        cv;     % central vector
        gener;  % generators
    end
    
    methods
        function zt = Zonotope(cv,gener)
        % input: cv    ---- central vector
        %        gener ---- matrix where each column is a generator
            if(size(cv,1)~=size(gener,1)&&~isempty(gener))
                error('some:siz_dismatch:id','Please make sure the dimension of cv and gener are the same.');
            end
           
            zt.cv = cv;
            zt.gener = gener;
        end
        
        function y = plus(zt1,zt2)
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
    end
end