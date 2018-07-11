classdef TransSyst<handle

  properties (SetAccess={?Partition})
    n_s;
    n_a;
    pointer;
    pointer_enabled = false;
    % Transitions
    state1;
    state2; 
    action;
    % under test
    trans_array;
    trans_sum;
    
    % Progress groups
    pg_U = {};
    pg_G = {};

    % Pre-computed pre_all and post maps for speed
    fast_post = {};
    fast_pre_all = {};
    fast_enabled = false;
  end

  properties
    % Disable progress groups
    b_disable_pg = false;

    % Debugging flag
    b_debug = false;
  end

  methods
    function ts = TransSyst(n_s, n_a, n_state)
      % Create a TransSyst with n_s states and n_a actions
      % n_state = num of transitions, preallocation
      ts.n_s = uint32(n_s);
      ts.n_a = uint32(n_a);
      ts.pointer = 1;
      if(nargin == 2)
          ts.state1 = uint32([]);
          ts.state2 = uint32([]);
          ts.action = uint32([]);
      else
          ts.state1 = zeros(n_state,1,'uint32');
          ts.state2 = zeros(n_state,1,'uint32');
          ts.action = zeros(n_state,1,'uint32');
          ts.pointer_enabled = true;
      end
      % under test for faster pre
      ts.trans_array = [];
      ts.trans_sum = [];
    end

    function numact = add_action(ts)
      % Add an action, return its number
      ts.n_a = ts.n_a + 1;
      numact = ts.n_a;
      ts.fast_enabled = false;
    end

    function create_fast(ts)
      % Compute and store quick-access backward and forward
      % transition maps
%       if ts.fast_enabled
%           return
%       end
      ts.fast_post = cell(1, ts.n_s * ts.n_a);
      ts.fast_pre_all = cell(1, ts.n_s);

      for i=1:ts.num_trans()
          s1 = ts.state1(i);
          s2 = ts.state2(i);
          a = ts.action(i);
          try
              ts.fast_post{(a-1)*ts.n_s + s1}(end+1) = s2;
          catch
              keyboard();
          end
          ts.fast_pre_all{s2}(end+1) = s1;
      end

      ts.fast_enabled = true;
    end

    function add_transition(ts, s1, s2, a)
      % Add transition from s1 to s2 under action a

      if ts.b_debug
        assert(1 <= s1 && s1 <= ts.n_s)
        assert(1 <= s2 && s2 <= ts.n_s)
        assert(1 <= a && a <= ts.n_a)
      end
      if(ts.pointer_enabled||length(s1)>1)
          if(~ts.pointer_enabled)
              ts.pointer_enabled = true;
          end
        len = length(s2);
        ts.state1(ts.pointer:ts.pointer+len-1) = s1;
        ts.state2(ts.pointer:ts.pointer+len-1) = s2;
        ts.action(ts.pointer:ts.pointer+len-1) = a;
        ts.pointer = ts.pointer+len;
      else
        ts.state1(end+1) = s1;
        ts.state2(end+1) = s2;
        ts.action(end+1) = a;
      end
      ts.fast_enabled = false;
    end

    function ret = has_superior_pg(ts, U, G)
      % Return true if a superior progress group
      % is already present
      ret = false;
      for i=1:length(ts.pg_U)
        if all(ismember(U, ts.pg_U{i})) && ...
           all(ismember(G, ts.pg_G{i}))
           ret = true;
           return
         end
       end
    end

    function add_progress_group(ts, U, G)
      % Add progress group G under modes U

      if ts.b_debug
        assert(all(1 <= U) && all(U <= ts.n_a))
        assert(all(1 <= G) && all(G <= ts.n_s))
      end

      % Remove any pgs that are inferior
      for i=length(ts.pg_U):-1:1
        if all(ismember(ts.pg_U{i}, U)) && ...
           all(ismember(ts.pg_G{i}, G))
          ts.pg_U(i) = [];
          ts.pg_G(i) = [];
        end
      end

      ts.pg_U{end+1} = U;
      ts.pg_G{end+1} = G;
    end

    function ret = num_trans(ts)
      % Number of transitions
      ret = length(ts.state1);
    end
    
    % under test
    function trans_array_enable(ts)
        ts.trans_array = ts2array(ts);
        ts.trans_sum = cell(ts.n_a,1);
        for i = 1:ts.n_a
            ts.trans_sum{i} = sum(ts.trans_array{i},2);
        end
    end
  end
end
