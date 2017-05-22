function y = specify_num_workers(w)
  y = ones(1,100);
  % w specifies maximum number of workers
  parfor (i = 1:100,w)
    y(i) = i;
  end
end