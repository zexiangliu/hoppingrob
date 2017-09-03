function tests = PatchContTest
  tests = functiontests(localfunctions);
end

function  patch_cont_test(testCase)
    [ts,~,cont_ref] = abstr_cont([]);
    
    cont1 = copy(cont_ref);
    u_res = [5,6,7,8];
    patch_cont_md(cont1,ts,u_res);
    
    [~,W1_ref,cont1_ref] = abstr_cont(u_res);
    
    
    assert(cmp_winning_set(W1_ref,cont1.sets{end}));
    assert(cmp_conts(cont1,cont1_ref));
    
    [~,~,cont_ref] = abstr_cont([]);
    cont2 = copy(cont_ref);
    u_res2 = [5,6,7,8]+20;
    patch_cont_md(cont2,ts,u_res2);
    
    [~,W2_ref,cont2_ref] = abstr_cont(u_res2);
    
    
    assert(cmp_winning_set(W2_ref,cont2.sets{end}));
    assert(cmp_conts(cont2,cont2_ref));
    
end

function bool = cmp_winning_set(W1,W2)
    if(length(W1)~=length(W2))
        bool = false;
        return;
    end
    bool = all(sort(W1)==sort(W2));
end

function bool = cmp_conts(cont1,cont2)
    
    bool = true;
    if(length(cont1.sets)~=length(cont2.sets))
        bool=false;
        return;
    end
    
    num = length(cont2.sets);
    
    for i = 1:num
        if(~cmp_winning_set(cont1.sets{i},cont2.sets{i}))
            bool = false;
            return;
        end
    end
    
end

function [ts,W,cont] = abstr_cont(u_res)
    %% Generate abstraction transient system
    disp('Start generating transient system...')
    %====== Define the system ======
    g = 10;
    h0 = 1;
    A =[0 1;g/h0 0];
    B = [0
        -g/h0];
    
    save system.mat A B
    %======= Test Parameter ========
    tau = 0.08;     % time interval
    eta = 0.1;
    mu = 0.2;
    lmax = 1;
    dlim = 2.5;
    vlim = 4;

    r1 = expm(A*tau)*[eta;eta]/2; % the upper bnd of ||x_0(tau)-x_1(tau)||
    r = r1;         % radius of norm ball when mapping xt to discr. state space

    % ==============================


    % === Discretization Config ===
    % state space grid size
    X.gridsize = eta;   % eta
    U.gridsize = mu;   % miu

    x1min= -dlim;
    x1max= dlim;

    % boundaries: i^th row -->  i^th dimension
    X.bnd = [           
        -dlim,dlim;
        -vlim,vlim
        ];
    U.bnd = [x1min-lmax,x1max+lmax];

    % ================================

    % 2 grid generation

    % Generating Grid
    M_X = GridGener(X);
    M_U = GridGener(U);
    
    % TransSyst
    ts = ArrayGener_parallel(M_X,M_U,tau,r,lmax,u_res);
    
    disp('Create target set B_list...')
    bnd_B = [X.bnd(1,:);
             -0.4,  0.4];
    B_list = Create_B(bnd_B,M_X);
    
    disp('Compute winning set and controller...')
    ts.create_fast();
    [W, C, cont]=ts.win_eventually_or_persistence([],{B_list'},1);

end

function setupOnce(testCase)
    clear all;
    addpath(genpath('../lib/abstr-ref/'));
    addpath('../lib/GridGener/');
    addpath('../lib/ArrayGener_2D/');
    addpath('../lib/SimuAndAnim/');
    addpath('../lib/console/');
    addpath('../lib/GroundGener/');
    addpath('../lib/PatchCont/');
end

function teardownOnce(testCase)
    clear all;
    addpath('../lib/');
    resetpath
    delete('system.mat');
end
