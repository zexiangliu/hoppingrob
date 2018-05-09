function bool = compare_conts(cont1,cont2)
% input 1 is the reference controller, input 2 is the patching controller
% the order cannot exchange, since patching controller may have redundant
% sub-sets and sub-controllers.
    bool = false;
    if(isa(cont1.sets,'cell'))
        if(length(cont1.sets)>length(cont2.sets))
            return;
        end
        for i = 1:length(cont1.sets)
            len1 = length(cont1.sets{i});
            len2 = length(cont2.sets{i});
            if(len1~=len2)
                return;
            end
        end
    else
        len1 = length(cont1.sets);
        len2 = length(cont2.sets);
        if(len1~=len2)
            return;
        end
    end
    
    if(isa(cont1.subcontrollers,'cell'))
        if(length(cont1.subcontrollers)~=length(cont2.subcontrollers))
            return;
        end
        for i = 1:length(cont1.subcontrollers)
            cont_tmp1 = cont1.subcontrollers{i};
            cont_tmp2 = cont2.subcontrollers{i};
            if(~compare_conts(cont_tmp1,cont_tmp2))
                return;
            end
        end
    else
        key_list = reshape(cont1.sets,1,length(cont1.sets));
        if(~isempty(key_list)&&~cont1.subcontrollers.isempty)
            for key = reshape(cont1.sets,1,length(cont1.sets))
                action1 = cont1.subcontrollers(key);
                action2 = cont2.subcontrollers(key);
                if(any(sort(action1)~=sort(action2)))
                    return;
                end
            end
        end
    end
    bool = true;
end