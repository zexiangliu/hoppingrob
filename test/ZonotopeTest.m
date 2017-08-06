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
    
    zt_new = 5*zt1;
    assert(all(zt_new.cv == 5*zt1.cv));
    assert(all(all(zt_new.gener == 5*zt1.gener)));
    
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
    
    zt_new = zt1 + zt1.cv + zt2;
    assert(all(zt_new.cv == zt1.cv*2+zt2.cv));
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

function zonoBox_test(testCase)
    % create a box
    c = [1;1];
    r = [1;0.5];
    box = zonoBox(c,r);
    assert(all(box.cv == c));
    assert(all(all(box.gener==diag(r))));
    
    % special case
    box = zonoBox([],r);
    assert(all(box.cv == [0;0]));
    assert(all(all(box.gener==diag(r))));
end

function zonotope_in_test(testCase)
    c = [1;1];
    r = [2;1];
    box = zonoBox(c,r);
    assert(box.in(c));
    assert(box.in([1.5;2]));
    
    zt = Zonotope(c,[box.gener,box.gener]);
    assert(zt.in(c));
    assert(zt.in([1.5;2]));
    
end

function setupOnce(testCase)
  cd ../lib/nonlinear_approx/
end

function teardownOnce(testCase)
  cd ../../test/
end
