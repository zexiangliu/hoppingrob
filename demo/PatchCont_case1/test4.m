
Z_ref = union(V_Compl_ref{5},V_Compl_ref{6});

V_ref = cont_ref.sets{2};
Z1 = ts_ref.pre(V_ref,[],true,false);
Z2 = ts_ref.pre_pg(V_ref,A,true);

Z = union(Z1,Z2)