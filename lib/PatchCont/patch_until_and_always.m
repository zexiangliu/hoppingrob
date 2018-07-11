function P_l = patch_until_and_always(cont,ts,u_res,P_lost,P,B, Vinv_lost, Vinv)

    if(~strcmp(cont.from,'win_until_and_always'))
        error('InputError: cont isn''t from win_until_and_always')
    end
        
%     if(isa(ts,'TransSyst'))
%         ts = TransSyst_array(ts);
%     end
    
    P_l = patch_until(cont,ts, u_res, union(P_lost,Vinv_lost), ...
                intersect(P, Vinv),intersect(B, Vinv));
end


