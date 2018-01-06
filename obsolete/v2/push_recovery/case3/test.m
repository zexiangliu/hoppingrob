hlim = 5;
g = 10;

tmp = linspace(1e-5,100,1000)
for i = 1:1000
h0=tmp(i);
A =[0 1;g/h0 0];
B = [0
    -g/h0];

r1(i) = norm(expm(A*0.01),'inf');
end

loglog(tmp,r1)
% r = r1+eta/2;        

