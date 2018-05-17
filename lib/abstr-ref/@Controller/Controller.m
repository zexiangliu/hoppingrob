classdef Controller<matlab.mixin.Copyable

  properties (SetAccess=protected)
    sets;           % List of sets where subcontrollers are active
    subcontrollers; % List of Controller or containers.Map
    control_type;   % One of 'reach', 'recurrence', and 'simple'
    mem_var;        % Memory variable needed for higher-level controller
    patch_info;     % any information used for patching algorithms
  end

  properties (SetAccess={?TransSyst})
    from = [];
  end

  methods
    function cont = Controller(set_list, c_list, c_type, c_from)
      % Controller(set_list, c_list, c_type): construct a controller of type 'c_type',
      % which must be one of 'simple', 'reach', or 'recurrence'.
      % 
      % 'simple': Controller(set, containers.Map, 'simple')
      %           feedback controller on 'set'
      % 'reach': Controller({set1, ..., setn}, {cont1, ..., contn}, 'simple')
      %          Use Controller conti on seti to reach set1
      % 'recurrence': Controller({setall, reach1, ..., reachn}, {cont1, ..., contn}, 'recurrence')
      %               Use conti to reach reachi, then use conti+1 to reach reachi+1, etc.
      %               setall is controller domain

      % Some checks
      if strcmp(c_type, 'reach') && length(set_list) ~= length(c_list)
        error('reach controller: set_list and c_list must be same size')
      end
      if strcmp(c_type, 'recurrence') && length(set_list) ~= length(c_list) + 1
        error('recurrence controller: must have length(set_list) == length(c_list) + 1')
      end
      if strcmp(c_type, 'simple') && ~isa(c_list, 'containers.Map')
        class(c_list)
        error('simple controller: second argument must be containers.Map')
      end

      cont.sets = set_list;
      cont.subcontrollers = c_list;
      cont.control_type = c_type;
      cont.mem_var = 1;
      if nargin > 3
        cont.from = c_from;
      end
    end

    function varargout = subsref(obj,S)
      % Overload indexing operator to access cells directly
      switch S(1).type
        % call builtin method to access class properties
      case '.' 
        [varargout{1:nargout}] = builtin('subsref', obj, S);
        % delegate to cell_list indexing
      case '()'
        varargout{1} = obj.get_input(S.subs{:});
      end 
    end

    function  a_list = get_input(cont, state)
      % Return controller input for 'state'
      if strcmp(cont.control_type, 'simple')
        if ~ismember(state, cont.sets)
          error('outside controller domain')
        end

        a_list = cont.subcontrollers(state);
        return
      end

      bottom_cnt = cont;
      while ~isa(bottom_cnt.subcontrollers, 'containers.Map')

        if strcmp(bottom_cnt.control_type, 'reach')
          if ismember(state, bottom_cnt.sets{max(1, bottom_cnt.mem_var-1)})
            % See if moved to lower
            bottom_cnt.mem_var = max(1, bottom_cnt.mem_var-1);
            
            % Test for skipping the error of progress group sets (Zexiang)
            % When creating the cont of pg, set V and a empty
            % controller will always be added at first, which causes error
            % when execute line 114 'a_list = bottom_cnt.subcontrollers(state);'
            if(bottom_cnt.mem_var~=1)
                continue;
            end
            
          elseif ~ismember(state, bottom_cnt.sets{bottom_cnt.mem_var})
            % Do whole search
            for i = 1:length(bottom_cnt.sets)
              if ismember(state, bottom_cnt.sets{i})
                bottom_cnt.mem_var = i;
                break
              end
            end
          end
          if ~ismember(state, cont.sets{cont.mem_var})
            error('outside controller domain')
          end
        
        elseif strcmp(bottom_cnt.control_type, 'recurrence')
          if ~ismember(state, bottom_cnt.sets{1})
            error('outside controller domain')
          end
          if ismember(state, bottom_cnt.sets{bottom_cnt.mem_var + 1})
            if bottom_cnt.mem_var == length(bottom_cnt.subcontrollers)
              bottom_cnt.mem_var = 1;
            else
              bottom_cnt.mem_var = bottom_cnt.mem_var + 1;
            end
          end
        end
        bottom_cnt = bottom_cnt.subcontrollers{bottom_cnt.mem_var};
      end
      a_list = bottom_cnt.subcontrollers(state);
    end

    function restrict_to(cont, r_set)
      % Restrict controller domain
      if strcmp(cont.control_type, 'simple')
        if(isempty(r_set))
            cont.sets = r_set;
        else
            cont.sets = intersect(cont.sets, r_set);
        end
      else
        error('complex controller cant be restricted')
      end
    end
  end
  
  methods(Access = protected)
      % Override copyElement method:
  function cpObj = copyElement(obj)
     cpObj = copyElement@matlab.mixin.Copyable(obj);
     if(iscell(obj.subcontrollers))
         for i=1:length(obj.subcontrollers)
             cpObj.subcontrollers{i} = copyElement(obj.subcontrollers{i});
         end
     else   
         if(isempty(obj.subcontrollers.keys))
             cpObj.subcontrollers = containers.Map();
         else
             cpObj.subcontrollers = containers.Map(obj.subcontrollers.keys,obj.subcontrollers.values);
         end
     end
  end
  
%   function cpObj = copy_subc(obj)
%      if(iscell(obj.subcontrollers))
%          for i=1:length(obj.subcontrollers)
%              cpObj.subcontrollers{i} = copy_subc(obj.subcontrollers{i});
%          end
%      else     
%          cpObj = copyElement@matlab.mixin.Copyable(obj);
%          cpObj.subcontrollers = copy(obj.subcontrollers);
%      end
%   end
  end
  
end