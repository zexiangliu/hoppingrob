clear all;
global ops
global opt_settings

ops = sdpsettings('solver', 'mosek', 'cachesolvers', 1, 'verbose', 0);
opt_settings.mode = 'sdsos';
opt_settings.max_deg = 4;

% max # of synthesis-refinement steps
maxiter = 1000;

% split final invariant set further to avoid zeno
split_inv = true;

% Disturbance: none
dmax = 0.;

% Progress group search depth
pg_depth = 2; 

%%%%%%%%%%%%%%%%%%%%%%%
% Initial abstraction %
%%%%%%%%%%%%%%%%%%%%%%%

tau = 0.08;     % time interval
eta = 0.18;
mu = 0.4;
lmax = 1;
dlim = 2.5;
vlim = 4;
x1min= -dlim;
x1max= dlim;

h0 = 1;
g = 10;

A = [0 1; g/h0 0];
B = [0;-g/h0];


U.gridsize = mu;
U.bnd = [x1min-lmax,x1max+lmax];

M_U = GridGener(U);

% Target set
goal_set = Rec([x1min, -0.4;
                x1max,  0.4], {'SET'});

%%
tic

% Build initial partition
part = Partition(Rec([-dlim,-vlim;dlim,vlim]));
part.add_area(goal_set);
part.check();   % sanity check

% Create abstraction
xvar = sdpvar(2,1);
dvar = sdpvar(2,1);

fx_list = cell(M_U.numV-1);

if dmax
  d_rec = Rec([-dmax -dmax; dmax dmax]);
  fx1 = a1 * xvar + k1 + e1 * dvar;
  fx2 = a2 * xvar + k2 + e2 * dvar;
  part.abstract({fx1, fx2}, [xvar; dvar], d_rec);
else
  for i = 1:M_U.numV-1
      fx_list{i}  = A * xvar + B * M_U.get_coord(i);
  end
  part.abstract(fx_list, [xvar]);
end

%% Search for transient regions
part.search_trans_reg_lin(pg_depth);

%% %%%%%%%%%%%%%%%%%%%%%%
% SYNTHESIS-REFINEMENT %
%%%%%%%%%%%%%%%%%%%%%%%%

Win = [];
iter = 0;
while true

  time = toc;
  disp(['iteration ', num2str(iter), ', time ', num2str(time), ', states ', num2str(length(part)), ', winning set volume ', num2str(sum(volume(part.cell_list(Win)))/volume(part.domain))])

  % Solve <>[] 'SET'
  B = part.get_cells_with_ap({'SET'});
  [Win, Cwin] = part.ts.win_primal([], B, [], 'exists', 'forall', Win);

  % No need to split inside winning set
  Cwin = setdiff(Cwin, Win);

  if isempty(Cwin) || iter == maxiter
    break
  end

  % Split largest cell in candidate set
  [~, C_index] = max(volume(part.cell_list(Cwin)));
  part.split_cell(Cwin(C_index));

  iter = iter + 1;
end


%% Split final set to eliminate Zeno
if split_inv
  inv_set = part.ts.win_primal(part.get_cells_with_ap({'SET'}), ...
                               [], [], 'forall','forall');
  for i=1:6^3
    if(isempty(inv_set))
        break;
    end
    [~, C_index] = max(volume(part(inv_set)));
    [ind1, ind2] = part.split_cell(inv_set(C_index));
    inv_set = union(inv_set, ind2);
  end
end
%%
% Get control strategy
[~, ~, cont] = part.ts.win_primal([], part.get_cells_with_ap({'SET'}), [], 'exists', 'forall');

toc