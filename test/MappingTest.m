function tests = MappingTest
  tests = functiontests(localfunctions);
end

function mapping_noconstraint_test(testCase)
    % 2D (ig. state space for 1D planning)
  gridsize = 0.2;
  bnd = [-1,1;3,5];
  X = SetDisConfig(gridsize,bnd);
  M_X = GridGener(X);
  xt = [0.1;3.5];
  r = [0.1;0.2];
  idx = mapping(xt,M_X,r);
  coords = M_X.get_coord(idx);
  for i = 1:size(coords,2)
      assert(all(abs(coords(:,i)-xt)<=M_X.gridsize/2+r+1e-10));
  end
  
  r = [0.1,0.2;0.3,0.4];
  idx = mapping_ext(xt,M_X,r);
  coords = M_X.get_coord(idx);
  for i = 1:size(coords,2)
      assert(all(coords(:,i)<=xt+M_X.gridsize/2+r(:,2)+1e-10));
      assert(all(coords(:,i)>=xt-M_X.gridsize/2-r(:,1)-1e-10));
  end
  
end

function mapping_constraint_test(testCase)
    % 2D (ig. state space for 1D planning)
  gridsize = 0.2;
  bnd = [-1,1;3,5];
  X = SetDisConfig(gridsize,bnd);
  xt = [0.1;3.5];
  radius = 0.5;
  ConsConfig = SetConsConfig(@cons_fun,xt,radius);
  M_X = GridGener(X,ConsConfig);
  r = [0.1;0.2];
  idx = mapping(xt,M_X,r);
  coords = M_X.get_coord(idx);
  for i = 1:size(coords,2)
      assert(all(abs(coords(:,i)-xt)<=M_X.gridsize/2+r+1e-10));
      assert(norm(coords(:,i)-xt)<=radius);
  end
  
  r = [0.1,0.2;0.3,0.4];
  idx = mapping_ext(xt,M_X,r);
  coords = M_X.get_coord(idx);
  for i = 1:size(coords,2)
      assert(all(coords(:,i)<=xt+M_X.gridsize/2+r(:,2)+1e-10));
      assert(all(coords(:,i)>=xt-M_X.gridsize/2-r(:,1)-1e-10));
  end
  
  r = [0.1;0.2];
  idx = mapping(xt,M_X,r,'o');
  coords = M_X.get_coord_full(idx);
  for i = 1:size(coords,2)
      assert(all(abs(coords(:,i)-xt)<=M_X.gridsize/2+r+1e-10));
      assert(norm(coords(:,i)-xt)<=radius);
  end
  
  r = [0.1,0.2;0.3,0.4];
  idx = mapping_ext(xt,M_X,r,'o');
  coords = M_X.get_coord_full(idx);
  for i = 1:size(coords,2)
      assert(all(coords(:,i)<=xt+M_X.gridsize/2+r(:,2)+1e-10));
      assert(all(coords(:,i)>=xt-M_X.gridsize/2-r(:,1)-1e-10));
  end
  
end

function bool = cons_fun(coord,ConsConfig)
  bool = false;
  if(norm(coord(1:2)-ConsConfig.xt)<=ConsConfig.radius)
      bool = true;
  end
end

function setupOnce(testCase)
  cd ../lib/GridGener/
end

function teardownOnce(testCase)
  cd ../../test/
end
