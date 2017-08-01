hlim = 5;
g = 10;
h0=1;
A =[0 1;g/h0 0];
B = [0
    -g/h0];

r1 = norm(expm(A*0.02),'inf')*eta/2
% r = r1+eta/2;        

