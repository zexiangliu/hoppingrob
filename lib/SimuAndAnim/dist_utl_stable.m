function dx = dist_utl_stable(v0,u,h0,g)
% used to draw the theoretical winning set of the perfect controller
% input: v0     initial velocity
%        u      maxmium |x_f-x_0|, that is maxmium "net input"
%        h0     height of the LIPM
%        g      gravity acceleration

if(nargin<2)
    error('No enough inputs.');
elseif(nargin == 2)
        h0 = 1;
        g = 0;
end
n = length(v0);
dx = zeros(size(v0));
c = v0/sqrt(g/h0)/u;

idx_exist = 1:n;
idx_out = c<=1;
dx(idx_out) = u*(1-sqrt(1-c(idx_out).^2));
dx(~idx_out) = u;
idx_exist(idx_out) = [];

while(~isempty(idx_exist))
    % update the elements currently greater than 1
    c(idx_exist) = sqrt(c(idx_exist).^2-1);
    % find the elements less than 1 after update
    idx_out = c(idx_exist)<=1;
    
    % update dx for the new out elements
    dx(idx_exist(idx_out))= dx(idx_exist(idx_out))+u*(1-sqrt(1-c(idx_exist(idx_out)).^2));
    dx(idx_exist(~idx_out))= dx(idx_exist(~idx_out))+u;
    idx_exist(idx_out)=[];
end