function ret = post(ts, q, a)
  % post(ts, q, a): compute the post set of state q and action a
  % 
  % Returns a sorted set
  if ts.fast_enabled
    ret = ts.fast_post{(a-1) * ts.n_s + q};
  else
    ret = uint32([]);
    for i = 1:ts.num_trans()
      if q == ts.state1(i) && a == ts.action(i)
        ret(end+1) = ts.state2(i);
      end
    end
    ret = unique(ret);
  end
end
