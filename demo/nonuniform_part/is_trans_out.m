function ret = is_trans_out(rec, dom, u, tau)
  % Assuming that rec \subset dom, see if there is a transition from
  % rec to the outside of dom.
  rest = mldivide(Rec([-Inf*ones(1,rec.dim); Inf*ones(1,rec.dim)]), dom);
  ret = false;
  for part=rest
    if intersects(rec, part)
      if is_trans(rec, part, u, tau)
        ret = true;
        return;
      end
    end
  end
end