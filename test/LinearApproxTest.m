function tests = LinearApproxTest
  tests = functiontests(localfunctions);
end

function reachability_m1_test(testCase)
  X.gridsize = [0.2;0.2];
  X.bnd = [-10,10;-10,10];
  U.gridsize = [0.2];
  U.bnd = [-4,4];
  M_X = GridGener(X);
  M_U = GridGener(U);
 
  q = [1;1];
  u = 1; % when changing u, remember to change the u in method odefun
  tau = 0.07;
  
%   r = 1*[0.15;0.29];
  L =  max(1,u) + 3*6*q(2)^2;
  r = max(X.gridsize/2)*exp(L*tau)*[1;1];
   
  X0 = zonoBox(q,X.gridsize/2);
  A = Aq(q,u);
  f = fq(q,u);
  D = Dq(q,u,r);
  
  
  [Rq,Rq_tube] = reachTube(M_X,M_U,q,tau,X0,A,f,D);
  
  fig = figure(1);
  hold on;
  plot_Rq(fig,Rq_tube,'c');
  plot_Rq(fig,Rq,'b');
  rectangle('Position',[q'-r' 2*r']);
  for i = 1:1e3
    q_rand = 2*(rand(2,1)-0.5).*(X.gridsize/2) + q;
    [t,y]=ode45(@odefun,[0,tau],q_rand);
    plot(y(:,1),y(:,2),'-r');
    plot(y(end,1),y(end,2),'oy');
  end
%   fig = figure(2);
  axis equal
end

function fig = plot_Rq(fig,Rq,c,idx)    
% plot zonotope using random method
  if(nargin == 3)
      dim = size(Rq.cv,1);
      idx = 1:2;
  end
  figure(fig);
  numG = size(Rq.gener,2);
  numMC = 1e6;
  coord = 2*(rand(numG,numMC)-0.5);
  point = Rq.cv*ones(1,numMC) + Rq.gener*coord;
  plt = plot(point(idx(1),:),point(idx(2),:),['.',c]);
end

function reachability_m2_test(testCase)
% test using the model in demo 'nonlinear_model1'
    g = 10;
    eta = [0.2;0.2;0.2;0.2];
    mu = [0.2;1];
    dlim = 2.5;
    vlim = 4;
    h0 = 1;
    hlim = 0.5;
    hvlim = 2;
    lmax = 1; % define how much input space is larger than state space
    dumax = 5; 
    X.gridsize = eta;   % eta
    U.gridsize = mu;   % miu

    x1min= -dlim;
    x1max= dlim;
    X.bnd = [           
        -dlim,dlim;
        h0-hlim,h0+hlim;
        -vlim,vlim;
        -hvlim,hvlim
        ];
    U.bnd = [x1min-lmax,x1max+lmax
             g/h0-dumax,g/h0+dumax];
    M_X = GridGener(X);
    M_U = GridGener(U);

    q = [1;1;1;1];
    u = [1;10]; % when changing u, remember to change the u in method odefun2
    tau = 0.08;

    %   r = 1*[0.15;0.29];
    L =  norm([0 0 1 0;0 0 0 1;u(2) 0 0 0;0 u(2) 0 0],'inf');
    r = max(X.gridsize/2)*exp(L*tau)*[1;1;1;1];

    X0 = zonoBox(q,X.gridsize/2);
    A = Aq2(q,u);
    f = fq2(q,u);
    D = Dq2(q,u,r);


    [Rq,Rq_tube] = reachTube(M_X,M_U,q,tau,X0,A,f,D);

    fig = figure(2);
    hold on;
    
    idx = [1;2];
    plot_Rq(fig,Rq_tube,'c',idx);
    plot_Rq(fig,Rq,'b',idx);
    rectangle('Position',[q(idx)'-r(idx)' 2*r(idx)']);
    for i = 1:1e3
    q_rand = 2*(rand(4,1)-0.5).*(X.gridsize/2) + q;
    [t,y]=ode45(@odefun2,[0,tau],q_rand);
    plot(y(:,idx(1)),y(:,idx(2)),'-r');
    plot(y(end,idx(1)),y(end,idx(2)),'oy');
    end
    %   fig = figure(2);
    axis equal
end

function setupOnce(testCase)
  addpath('./linear_approx/');
  addpath('../lib/nonlinear_approx/');
  addpath('../lib/GridGener/');
  addpath('../lib/');
end

function teardownOnce(testCase)
  resetpath
end
