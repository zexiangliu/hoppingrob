function [ind1, ind2] = split_cell(part, ind, dim, U_list, param)
  % SPLIT_CELL: Split a cell in the partition, which increases the number of cells by 1.
  % The adjacency matrix is updated automatically.
  %
  % If there is an associated transition system, this is also updated
  % 
  % SYNTAX
  % ------
  %
  % part.split_cell()
  % part.split_cell(i)
  % part.split_cell(i, dim)
  % 
  % INPUT
  % -----
  % 
  % i   number of cell to split (default: largest cell)
  %   dim   dimension to split along (default: largest dimension)
  %
  % OUTPUT
  % ------
  %
  %   [io, jo]  indices of new cells
  
  if nargin<2 || isempty(ind) 
    [~, ind] = max(volume(part.cell_list));
  end

  if nargin<3 || isempty(dim)
    [~, dim] = max(part.cell_list(ind).xmax - part.cell_list(ind).xmin);
  end

  old_adj_ind = part.get_neighbors(ind);
  N = length(part);

  % split cell number ind along dimension dim
  [p1, p2] = split(part.cell_list(ind),dim);

  %%% construct adjacency to be filled %%%
  new_adj = [part.adjacency zeros(N,1); zeros(1, N+1)];
  new_adj(ind,:) = 0;
  new_adj(:,ind) = 0;

  % mutual adjacency along dim
  new_adj(ind, N+1) = dim;
  new_adj(N+1, ind) = dim;

  % determine kept adj
  for num_oldadj=old_adj_ind
    [isn, d] = isNeighbor(p1, part.cell_list(num_oldadj));
    if isn
      new_adj(ind, num_oldadj) = d;
      new_adj(num_oldadj, ind) = d;
    end
    [isn, d] = isNeighbor(p2, part.cell_list(num_oldadj));
    if isn
      new_adj(N+1, num_oldadj) = d;
      new_adj(num_oldadj, N+1) = d;
    end
  end

  new_adj_out = [part.adjacency_outside 0];
  new_adj_out(ind) = 0;
  % adjacent to outside
  if part.adjacency_outside(ind)
    isi = contains_strictly(p1, part.domain);
    if ~isi
      new_adj_out(ind) = 1;
    end
    isi = contains_strictly(p2, part.domain);
    if ~isi
      new_adj_out(N+1) = 1;
    end
  end

  % Add new cells and adjacency matrix
  part.cell_list(ind) = p1; % add one at old position
  part.cell_list(end+1) = p2;     % and one at the end
  part.adjacency = new_adj;
  part.adjacency_outside = new_adj_out;

  ind1=ind; ind2=N+1;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % IF THERE IS A TS, UPDATE IT %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  if isempty(part.ts)
    return
  end
  
  if strcmp(part.ts.sys_setting, TransSyst.sparse_set)
    % Store transitions pertaining to split state
    % to reduce computation
    trans_in = [];
    trans_in_act = [];
    trans_out = [];
    trans_out_act = [];
    outdomain_act = [];
    non_transient_act = [];

    % remove all transitions pertaining to ind1
    % and store information
%     c = length(part.ts.action);
    for i=part.ts.num_trans():-1:1
      if part.ts.state1(i) == ind1 && part.ts.state2(i) == part.ts.n_s
        outdomain_act(end+1) = part.ts.action(i);
      elseif part.ts.state1(i) == ind1 && part.ts.state2(i) == ind1
        non_transient_act(end+1) = part.ts.action(i);
      elseif part.ts.state1(i) == ind1 
        trans_out(end+1) = part.ts.state2(i);
        trans_out_act(end+1) = part.ts.action(i);
      elseif part.ts.state2(i) == ind1 
        trans_in(end+1) = part.ts.state1(i);
        trans_in_act(end+1) = part.ts.action(i);
      end
      if part.ts.state1(i) == ind1 || part.ts.state2(i) == ind1
        part.ts.state1(i) = [];
        part.ts.state2(i) = [];
        part.ts.action(i) = [];
      end
    end

    % move last (outside) state forward---should only have 
    % outgoing transitions
    for i=1:part.ts.num_trans()
      if part.ts.state2(i) == part.ts.n_s
        part.ts.state2(i) = part.ts.n_s+1;
      end
    end

    % increase state counter
    part.ts.n_s = part.ts.n_s + 1;
    part.ts.array_computed = false;

%     trans_to_add = zeros(0, 3);
        
    % Transitions into union
    for i = 1:length(trans_in)
      in_state = trans_in(i);
      in_act = trans_in_act(i);
      [K_in, bool_in] = reachable_set(part.cell_list(in_state),U_list(in_act),...
                    param);
      if(bool_in == true)
          if K_in.intersects(part.cell_list(ind1))
            part.ts.add_transition(in_state, ind1, in_act);
          end
          if K_in.intersects(part.cell_list(ind2))
            part.ts.add_transition(in_state, ind2, in_act);
          end
      else
          part.ts.add_transition(in_state, ind1, in_act);
          part.ts.add_transition(in_state, ind2, in_act);
      end
    end

    K_list1 = cell(length(U_list),1);
    bool_list1 = cell(length(U_list),1);
    K_list2 = cell(length(U_list),1);
    bool_list2 = cell(length(U_list),1);
    for k = 1:length(U_list)
        [K_list1{k}, bool_list1{k}] = reachable_set(part.cell_list(ind1)...
            ,U_list(k),param);
        [K_list2{k}, bool_list2{k}] = reachable_set(part.cell_list(ind2)...
            ,U_list(k),param);
    end
    
    % Transitions out of union
    for i = 1:length(trans_out)
      out_state = trans_out(i);
      out_act = trans_out_act(i);
      if bool_list1{out_act} && ...
              K_list1{out_act}.intersects(part.cell_list(out_state))
            part.ts.add_transition(ind1, out_state, out_act);
      end
      
      if bool_list2{out_act} && ...
              K_list2{out_act}.intersects(part.cell_list(out_state))
        part.ts.add_transition(ind2, out_state, out_act);
      end
    end

    % Transitions between the two cells
    for act_num = 1:length(U_list)
      if bool_list1{act_num} && ...
              K_list1{act_num}.intersects(part.cell_list(ind2))
        part.ts.add_transition(ind1, ind2, act_num);
      end
      if bool_list2{act_num} && ...
              K_list2{act_num}.intersects(part.cell_list(ind1))
        part.ts.add_transition(ind2, ind1, act_num);
      end
    end

    % Out-of-domain
    for i = 1:length(outdomain_act)
      out_act = outdomain_act(i);
      if ~bool_list1{out_act}
           part.ts.add_transition(ind1*ones(N+2,1),...
               (1:(N+2))', out_act*ones(N+2,1));
%         part.ts.add_transition(ind1, N+2, out_act);
      end
      if ~bool_list2{out_act}
           part.ts.add_transition(ind2*ones(N+2,1),...
               (1:(N+2))', out_act*ones(N+2,1));
%         part.ts.add_transition(ind2, N+2, out_act);
      end
    end

    % Self transitions
    for nt_act = 1:length(U_list)
      if bool_list1{nt_act} && ...
              K_list1{nt_act}.intersects(part.cell_list(ind1))
        part.ts.add_transition(ind1, ind1, nt_act);
      end
      if bool_list2{nt_act} && ...
              K_list2{nt_act}.intersects(part.cell_list(ind2))
        part.ts.add_transition(ind2, ind2, nt_act);
      end
    end

  end
