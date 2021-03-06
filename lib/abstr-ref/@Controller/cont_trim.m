function cont_trim(cont)
% all the controllers generated by win_xxx_patch or patch_xxx must be 
%passed to this function to remove redundant pg_pre controllers.
    if(strcmp(cont.from,'win_until'))
        cont_tmp = cont;
        num_tmp = length(cont_tmp.sets);
        remove_list = false(num_tmp,1);
        for j = 1:num_tmp
            subc_tmp = cont_tmp.subcontrollers{j};
            if(strcmp(subc_tmp.from,'pre_pg')...
                &&subc_tmp.subcontrollers{1}.subcontrollers.Count==0)
                remove_list(j)=true;
            end
        end
        cont_tmp.sets(remove_list)=[];
        cont_tmp.subcontrollers(remove_list)=[];
        return;
    end
    
    num_subc = length(cont.subcontrollers);
    for i = 1:num_subc
%         if(strcmp(cont.subcontrollers{i}.from,'win_until'))
%             cont_tmp = cont.subcontrollers{i};
%             num_tmp = length(cont_tmp.sets);
%             remove_list = false(num_tmp,1);
%             for j = 1:num_tmp
%                 subc_tmp = cont_tmp.subcontrollers{j};
%                 if(strcmp(subc_tmp.from,'pre_pg')...
%                     &&subc_tmp.subcontrollers{1}.subcontrollers.Count==0)
%                     remove_list(j)=true;
%                 end
%             end
%             cont_tmp.sets(remove_list)=[];
%             cont_tmp.subcontrollers(remove_list)=[];
%             return;
%         else
        cont_trim(cont.subcontrollers{i});
%         end
    end
end