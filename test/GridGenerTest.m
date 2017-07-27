function tests = GridGenerTest
  tests = functiontests(localfunctions);
end

function GridGener_noconstraint_test(testCase)
  % 1D (ig. input space)
  gridsize = 0.2;
  bnd = [-1,1];
  U = SetDisConfig(gridsize,bnd);
  M_X = GridGener(U);
  assert(all(M_X.discr_bnd(:,1)>=bnd(:,1)+gridsize/2-1e-10));
  assert(all(M_X.discr_bnd(:,2)<=bnd(:,2)-gridsize/2+1e-10));
  assert(all(abs(M_X.discr_bnd(:,1)-M_X.discr_bnd(:,2))./...
      (M_X.discr_bnd(:,3)-1)<=gridsize+1e-10));
  assert(M_X.numV == prod(M_X.discr_bnd(:,3))+1);
  % 2D (ig. state space for 1D planning)
  gridsize = 0.2;
  bnd = [-1,1;3,5];
  X = SetDisConfig(gridsize,bnd);
  M_X = GridGener(X);
  assert(all(M_X.discr_bnd(:,1)>=bnd(:,1)+gridsize/2-1e-10));
  assert(all(M_X.discr_bnd(:,2)<=bnd(:,2)-gridsize/2+1e-10));
  assert(all(abs(M_X.discr_bnd(:,1)-M_X.discr_bnd(:,2))./...
      (M_X.discr_bnd(:,3)-1)<=gridsize+1e-10));
  assert(M_X.numV == prod(M_X.discr_bnd(:,3))+1);
  % 4D (ig. state space for 2D planning)
  gridsize = 0.2;
  bnd = [-1,1;3,4;1,10;2,5];
  X = SetDisConfig(gridsize,bnd);
  M_X = GridGener(X);
  assert(isempty(M_X.ind2ind));
  assert(all(M_X.discr_bnd(:,1)>=bnd(:,1)+gridsize/2-1e-10));
  assert(all(M_X.discr_bnd(:,2)<=bnd(:,2)-gridsize/2+1e-10));
  assert(all(abs(M_X.discr_bnd(:,1)-M_X.discr_bnd(:,2))./...
      (M_X.discr_bnd(:,3)-1)<=gridsize+1e-10));
  assert(M_X.numV == prod(M_X.discr_bnd(:,3))+1);
end

function GridGener_constraint_test(testCase)
    % 4D (ig. state space for 2D planning)
  gridsize = [0.1;0.2;0.1;0.2];
  bnd = [-1,1;-1,1;1,10;2,5];
  X = SetDisConfig(gridsize,bnd);
  wid = 0.5; len = 0.5; hig = 0.5;
  Consfig = SetConsConfig(@cons_fun,wid,len,hig);
  M_X = GridGener(X,Consfig);
  assert(~isempty(M_X.ind2ind));
  assert(all(M_X.discr_bnd(:,1)>=bnd(:,1)+gridsize/2-1e-10));
  assert(all(M_X.discr_bnd(:,2)<=bnd(:,2)-gridsize/2+1e-10));
  assert(all(abs(M_X.discr_bnd(:,1)-M_X.discr_bnd(:,2))./...
      (M_X.discr_bnd(:,3)-1)<=gridsize+1e-10));
  num = size(M_X.ind2sub,1);
  assert(M_X.numV == num + 1);  
end

function bool = cons_fun(coord,ConsConfig)
  len = ConsConfig.len;
  wid = ConsConfig.wid;
  hig = ConsConfig.hig;
  bool = false;
  if(norm(coord(1:2))<=(len*wid*hig)^(1/3))
      bool = true;
  end
end

function get_coord_test(testCase)
  % 2D (ig. state space for 1D planning)
  gridsize = 0.05;
  bnd = [-1,1;-1,1];
  X = SetDisConfig(gridsize,bnd);
  wid = 0.5; len = 0.5; hig = 0.5;
  Consfig = SetConsConfig(@cons_fun,wid,len,hig);
  M_X = GridGener(X,Consfig);
  figure(1);
  for i = 1:M_X.numV-1
      coord = M_X.get_coord(i);
      plot(coord(1),coord(2),'o');
      hold on;
  end
  title('It should be a circle with radius 0.5')
  figure(2);
  coord = M_X.get_coord(1:(M_X.numV-1));
  plot(coord(1,:),coord(2,:),'o');
  title('It should be a circle with radius 0.5')
end


function Create_B_test(testCase)
  % 4D (ig. state space for 2D planning)
  % no constraints
  gridsize = 0.2;
  bnd = [-1,1;3,4;1,10;2,5];
  X = SetDisConfig(gridsize,bnd);
  M_X = GridGener(X);
  B_bnd = [-0.5,0.5;3.1,3.5;2,3;2,4];
  B_list = Create_B(B_bnd,M_X);
  for i = 1:length(B_list)
      % loose version: the target set is enlarged by gridsize/2 s.t. the B
      % list isn't empty when target set is too 'narrow'.
      assert(all(M_X.get_coord(B_list(i))>=B_bnd(:,1)-M_X.gridsize/2-1e-10));
      assert(all(M_X.get_coord(B_list(i))<=B_bnd(:,2)+M_X.gridsize/2+1e-10));
  end
  
  % constraints
  gridsize = [0.1;0.2;0.1;0.2];
  bnd = [-1,1;-1,1;1,10;2,5];
  X = SetDisConfig(gridsize,bnd);
  wid = 0.5; len = 0.5; hig = 0.5;
  Consfig = SetConsConfig(@cons_fun,wid,len,hig);
  M_X = GridGener(X,Consfig);
  % target set is inside constraints
  B_bnd = [-0.2,0.2;-0.2,0.2;2,3;2,3];
  B_list = Create_B(B_bnd,M_X);
  for i = 1:length(B_list)
      coord = M_X.get_coord(B_list(i));
      assert(all(coord>=B_bnd(:,1)-M_X.gridsize/2-1e-10));
      assert(all(coord<=B_bnd(:,2)+M_X.gridsize/2+1e-10));
      assert(norm(coord(1:2))<=(wid*len*hig)^(1/3));
  end
  
  % target set intersects with constraints
  B_bnd = [-1,1;-1,1;2,3;2,3];
  B_list = Create_B(B_bnd,M_X);
  for i = 1:length(B_list)
      coord = M_X.get_coord(B_list(i));
      assert(all(coord>=B_bnd(:,1)-M_X.gridsize/2-1e-10));
      assert(all(coord<=B_bnd(:,2)+M_X.gridsize/2+1e-10));
      assert(norm(coord(1:2))<=(wid*len*hig)^(1/3));
  end
  
end

function setupOnce(testCase)
  cd ../lib/GridGener/
end

function teardownOnce(testCase)
  cd ../../test/
end
