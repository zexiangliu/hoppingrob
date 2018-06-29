function tests = ControllerTest
  tests = functiontests(localfunctions);
end

function control_falseInput_test(testCase)

    ts = TransSyst(2,3);
    s1 = [1,2,2];
    a =  [1,2,3];
    s2 = [1,1,2];

    ts.add_transition(s1,s2,a);
    ts.trans_array_enable();

    B_list = 1;
    [W, ~, cont] = win_primal(ts, [], B_list, [], 'exists', 'forall');

    % 3 shouldn't be a control input for state 2
    assert(~ismember(3, cont(2)));
    

end