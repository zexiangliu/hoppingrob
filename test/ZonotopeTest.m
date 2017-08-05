function tests = ZonotopeTest
  tests = functiontests(localfunctions);
end

function zonotope_creation_test(testCase)
    M = [0 1;2 1];
    % create a zonotope
    cv = [1;1];
    gener = [1 0;0 1];
    zt1 = Zonotope(cv,gener);
    
    assertError(testCase,@() Zonotope(1,gener),'some:siz_dismatch:id');
    
    % test mutiplication
    zt_new = M*zt1;
    assert(all(zt_new.cv == M*zt1.cv));
    assert(all(all(zt_new.gener == M*zt1.gener)));
    
    % create a zonotope without gener
    zt2 = Zonotope(cv,[]);
    
    zt_new = M*zt2;
    assert(all(zt_new.cv == M*zt2.cv));
    assert(isempty(zt_new.gener));
    
    % test add
    zt_new = zt1 + zt2;
    assert(all(zt_new.cv == zt1.cv + zt2.cv));
    assert(all(all(zt_new.gener == [zt1.gener, zt2.gener])));
    
    zt_new = zt1 + zt2;
    assert(all(zt_new.cv == zt1.cv + zt2.cv));
    assert(all(all(zt_new.gener == [zt1.gener, zt2.gener])));
   
end

function  zonotope_equal_test(testCase)
    cv = [1;1;1];
    gener = eye(3);
    zt1 = Zonotope(cv,gener);
    
    gener = [0 0 1; 0 1 0; 1 0 0];
    zt2 = Zonotope(cv,gener);
    
    assert(zt1==zt2);
    
    gener = [0 0 1; 1 1 0; 1 0 0];
    zt3 = Zonotope(cv,gener);
    assert(zt1~=zt3);
    
    gener = [];
    zt4 = Zonotope(cv,gener);
    assert(zt4==zt4);
end

function setupOnce(testCase)
  cd ../lib/nonlinear_approx/
end

function teardownOnce(testCase)
  cd ../../test/
end
