h = 1;
g = 10;

A = [0 1; g/h 0];
B = [0; -g/h];

syms t s u

exp_A = simplify(expm(A*t));


residual = simplify(int(expm(A*(t-s))*B*u,s,0,t));