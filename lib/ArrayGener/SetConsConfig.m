function ConsCfg = SetConsConfig(cons_fun,varargin)
% input : handle of constraint function
% extra inputs must follow the format: ...,'fieldname', value,...
  ConsCfg = cons_fun;
  if(~isempty(varargin))
    for i = 1:length(varargin)/2
        ConsCfg=setfield(ConsCfg,2*varargin{i}-1,2*varargin{i});
    end
  end
end