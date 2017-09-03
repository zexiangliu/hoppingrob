if split_inv
  inv_set = part.ts.win_primal(part.get_cells_with_ap({'SET'}), ...
                               [], [], 'forall','forall');
  for i=1:6^3
    [~, C_index] = max(volume(part(inv_set)));
    [ind1, ind2] = part.split_cell(inv_set(C_index));
    inv_set = union(inv_set, ind2);
  end
end