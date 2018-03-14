function [Pt,Vt_new] = patch_until(cont,ts, u_res, P_lost, P, B)
    
    if(~strcmp(cont.from,'win_until') && ~strcmp(cont.from,'win_until_and_always')...
            && ~strcmp(cont.from,'win_intermediate'))
        error('InputError: cont isn''t from win_until')
    end
    
    if(isa(ts,'TransSyst'))
        ts = TransSyst_array(ts);
    end
    num_loop = length(cont.sets);
    set_all = cell(num_loop,1);
    set_all{1} = cont.sets{1};
    Vt_old = P;
    P_new = setdiff(P, P_lost);
    Pt = P_lost;
    Vt_new = P_new;
%     K_up = {cont.subcontrollers{end-1}.copy,cont.subcontrollers{end}.copy};
%     V_up = cell(num_loop,1);
    for i = 2:num_loop
        cont_tmp = cont.subcontrollers{i};
        if(strcmp(cont_tmp.from,'pre'))            
            Vt_old = union(P, intersect(B,cont.sets{i}));
            P_l = patch_pre(cont_tmp,ts,u_res,Pt);           
            set_all{i} = setdiff(cont.sets{i},P_l);         
            Vt_new = union(P_new, intersect(B,set_all{i}));
        elseif(strcmp(cont_tmp.from,'pre_pg'))
            % return the new winning set
            Vt_old = union(Vt_old, cont.sets{i});
            PG_new = patch_pre_pg_md2(cont_tmp,ts,u_res,B,Pt);
            set_all{i} = PG_new; 
            Vt_new = union(Vt_new, set_all{i});
        end  
        Pt = setdiff(Vt_old,Vt_new);
%         V_up{i}=Vt_old;
    end
%     V_up = V_up(end-1:end);
    cont.set_sets(set_all);
end

% function [V, Cv, cont] = win_until_patch(ts, u_res, B, P, V_list, K_list, V, V_up, K_up)
%   % Compute the winning set of
%   %  B U P
%   % under (quant1, forall)-controllability
%   %
%   % Returns a sorted set
%   %
%   % Exanding algo
%     quant1 = true;
% 
%     while true
%         % Normal pre
%         cont_tmp = K_up{1}.copy;
%         Pt = setdiff(V_up{1},V);
%         P_l = patch_pre(cont_tmp, ts, u_res, Pt);
%         preV = setdiff(V_up{1},P_l);
%         Vt = union(P, intersect(B, preV));
% 
%         % PG pre
%         [preVinv, CpreVinv, preKinv] = ts.pre_pg(Vt, B, quant1);
%         Vt = union(Vt, preVinv);
%         Vt = reshape(Vt, 1, length(Vt));
% 
%         if length(V) == length(Vt)
%             break
%         end
% 
%         Vlist{end+1} = preV;
%         Klist{end+1} = preK;
%         Vlist{end+1} = preVinv;
%         Klist{end+1} = preKinv;
%         V = Vt;
%     end
%   
%     cont = Controller(Vlist, Klist, 'reach', 'win_until');
% end