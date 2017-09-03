% a=cont.subcontrollers{5};
% 
% b=cont_ref.subcontrollers{5};
% 
% m = 6
% n = 2
% length(a.subcontrollers{m}.sets)
% length(b.subcontrollers{n}.sets)
% 
% c=  setdiff(b.subcontrollers{n}.sets,a.subcontrollers{m}.sets);
% 
% intersect(a.subcontrollers{m-2}.sets,c)
% 
% av = a.subcontrollers{m}.subcontrollers.values;
% bv = b.subcontrollers{n}.subcontrollers.values;
% 
% av{1}
% bv{1}

% 
% a=cont.subcontrollers{6};
% 
% b=cont_ref.subcontrollers{6};
% length(a.sets{1})
% length(b.sets{1})
% 
% size(setdiff(a.sets{1},b.sets{1}))

% 
% a=cont.sets{5};
% b=cont_ref.sets{5}; 
% 
% length(a)
% length(b)
% 
% size(setdiff(b,a))

for i = 1:length(cont.sets)
    a = cont.sets{i};
    b = cont_ref.sets{i};
    int = intersect(a,b);
    if(length(a) ~= length(int))
        keyboard();
    else
        i
        disp('pass!');
    end
end

fig = figure(1);
M_X.visual(fig,cont_ref.sets{end},'.r',12);
hold on;
M_X.visual(fig,cont.sets{end},'.c',12);
% fig = figure(2);