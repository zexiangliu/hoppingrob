clc;clear all;close all;
%% Robot Configuration
m = 1;
g = 10;
l0 = 0.5;
k = 7000;

% Grid of Kinetic Energy
v_max = 5;
M_X = [-1/2*m*v_max^2, 1/2*m*v_max^2];
% Grid of input
dt_max = 10;
M_U = (90-dt_max):(90+dt_max);
num_U = length(M_U);
% initial condition
param.rest_len = l0;
param.gravity = g;
param.mass = m;
param.k = k;

y0 = 1.5;
dx0 = 1;
Dy = 0.2;

E = 1/2*m*dx0(1)^2 + m*g*y0;
dE = m*g*Dy;

param.E = E;
param.dE = dE;

%% sparse setting
system_setting = TransSyst.sparse_set;
encoding_setting = [];

% max # of synthesis-refinement steps
maxiter = 3000;


% Target set
goal_set = Rec([-0.2 0.2], {'SET'});

% split final invariant set further to avoid zeno
split_inv = true;

% Disturbance: unit is W/m^2 --- heat added per unit floor area
dmax = 0;

% Progress group search depth
pg_depth = 0;

%% build abstraction

% Build initial partition
part = Partition(Rec([M_X(1) M_X(2)]));
part.add_area(goal_set);
part.check();   % sanity check

part.abstract(M_U,param, system_setting, encoding_setting);


% SYNTHESIS-REFINEMENT %
Win = [];
iter = 0;

%%
while true
    
    % Solve <>[] 'SET'
    B = part.get_cells_with_ap({'SET'});
    part.ts.trans_array_enable();
    [Win, Cwin] = part.ts.win_primal([], B, [], 'exists', 'forall', Win);

    % No need to split inside winning set
    Cwin = setdiff(Cwin, Win);
    
    percent = 0;
    if(~isempty(Win))
        for i = 1:length(Win)
            percent = percent + part.cell_list(Win(i)).volume;
        end
        percent = percent/part.domain.volume;
    end
    
    info = sprintf(['iter %d, winning percent %f, state num %d,'...
        ' transitions %d'],iter,percent,length(part),...
         part.ts.num_trans);
    disp(info);
    
    %   Split largest cell in candidate set
    % find all nodes adjacent to winning set
    Adj_win = [];
    for i = 1:length(Win)
        Adj_win = [Adj_win, find(part.adjacency(Win(i),:))];
    end
    Adj_win = setdiff(unique(Adj_win),Win);
    
    if isempty(Adj_win) && isempty(Cwin)
        Cwin = setdiff(1:length(part),Win);
    elseif ~isempty(intersect(Cwin,Adj_win))
        Cwin = intersect(Cwin,Adj_win);
    elseif ~isempty(Adj_win)
        Cwin = Adj_win;
    end
    [~, C_index] = max(volume(part.cell_list(Cwin)));
    part.split_cell(double(Cwin(C_index)),1,M_U,param);
    
    if iter == maxiter
        break;
    end
    iter = iter + 1;
end


