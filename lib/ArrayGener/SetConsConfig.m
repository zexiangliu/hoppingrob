function ConsCfg = SetConsConfig(cons_fun,varargin)
% input : handle of constraint function
% extra inputs must follow the format: ...,'fieldname', value,...
  ConsCfg.cons_fun = cons_fun;
  if(~isempty(varargin))
    for i = 1:length(varargin)
        ConsCfg.(inputname(i+1))=varargin{i};
    end
  end
end