function myPool = specify_num_workers(w)
% input: w  num of workers
% Note: If no input, the program will detect the num of processors defined
% by PBS file as w or use default number 4.
  if(nargin==0||isempty(w))
    if isempty(getenv('PBS_NP'))
        w = 4;
    else
        w = str2double(getenv('PBS_NP'));
    end
  end
  try
      myPool = parpool('local', w);
  catch
      delete(gcp('nocreate'));
      myPool = parpool('local', w);
  end
%   y = ones(1,100);
%   % w specifies maximum number of workers
%   parfor (i = 1:100,w)
%     y(i) = i;
%   end
end