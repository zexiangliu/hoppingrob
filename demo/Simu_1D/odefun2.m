function dydt=odefun2(t,yt)
% linear system x = Ax + Bu
% u origins from cont.
persistent A B M_X M_U eta u cont idx_u counter tau
if(isempty(A))
%     g = 9.8;
%     h0 = 10;
%     A =[0 1;g/h0 0];
%     B = [0;-1];
    load ts
    counter = 0;
end
if(isempty(u)||counter*tau<=t)
    disp(t);
    idx_y  = mapping(yt,M_X,eta/2);
    u_option = cont.get_input(idx_y)

    if(~ismember(idx_u,u_option))
       idx_u = u_option(round(length(u_option)/2))
       u = get_coord(idx_u,M_U);
    end
    counter = counter+1;
end
dydt = A*yt + B*u;  % x=y(1:2) u = y(3)