function tests = LibraryTest
  tests = functiontests(localfunctions);
end

function sub2ind2_test(testCase)
  % scalar 
  siz = [1,1];
  X = {[1],[1]};
  idx = sub2ind2(siz,X);
  assert(all(idx == [1;1]));
  % column vector
  siz = [10,1];
  X = {[1;3;5],[1;1;1]};
  idx = sub2ind2(siz,X);
  assert(all(idx == [1;3;5]));
  
  % row vector
  X = {[1;3;5]',[1;1;1]'};
  idx = sub2ind2(siz,X);
  assert(all(idx == [1;3;5]'));
  
  % matrix
  siz = [5,5];
  X = {[1;2;3],[1;2;3]};
  idx1 = sub2ind2(siz,X);
  idx2 = sub2ind(siz,X{1},X{2});
  assert(all(idx1 == idx2));
  
  % tensor
  siz = [5,5,5];
  X = {[1;2;3],[1;2;3],[3;4;3]};
  idx1 = sub2ind2(siz,X);
  idx2 = sub2ind(siz,X{1},X{2},X{3});
  assert(all(idx1 == idx2));
end

function ind2sub2_test(testCase)
  % scalar
  siz = [1,1];
  sub = ind2sub2(siz,[1]);
  assert(all(sub == [1;1]));
  
  % column vector
  siz = [5,1];
  sub = ind2sub2(siz,[1,3,4]);
  [s1,s2] = ind2sub(siz,[1,3,4]);
  assert(all(all(sub == [s1;s2])));
  
  % matrix
  siz = [5,5];
  sub = ind2sub2(siz,[1,3,5]);
  [s1,s2] = ind2sub(siz,[1,3,5]);
  assert(all(all(sub == [s1;s2])));
  
  % tensor
  siz = [5,5,5];
  sub = ind2sub2(siz,[1,3,5,7]);
  [s1,s2,s3] = ind2sub(siz,[1,3,5,7]);
  assert(all(all(sub == [s1;s2;s3])));
end

function ndgrid2_test(testCase)
  SUB = {[1;1],[2;2],[3;3]};
  [Xref,Yref,Zref] = ndgrid(SUB{1},SUB{2},SUB{3});
  X = ndgrid2(SUB);
  assert(all(X{1}(:)==Xref(:)&X{2}(:)==Yref(:)&X{3}(:)==Zref(:)));
  
  
  SUB = {[1;1]',[2;2]',[3;3]'};
  [Xref,Yref,Zref] = ndgrid(SUB{1},SUB{2},SUB{3});
  X = ndgrid2(SUB);
  assert(all(X{1}(:)==Xref(:)&X{2}(:)==Yref(:)&X{3}(:)==Zref(:)));
end

function setupOnce(testCase)
  cd ../lib/GridGener/
end

function teardownOnce(testCase)
  cd ../../test/
end
