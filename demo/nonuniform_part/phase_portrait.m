close all; clc

for j = 1:length(part.dyn_list)

    f = @(t,Y) [part.dyn_list{j}{1}*Y + part.dyn_list{j}{2}];

    y1 = linspace(part.domain.xmin(1),part.domain.xmax(1),30);
    y2 = linspace(part.domain.xmin(2),part.domain.xmax(2),30);

    % creates two matrices one for all the x-values on the grid, and one for
    % all the y-values on the grid. Note that x and y are matrices of the same
    % size and shape, in this case 20 rows and 20 columns
    [x,y] = meshgrid(y1,y2);
    size(x)
    size(y)

    u = zeros(size(x));
    v = zeros(size(x));

    % we can use a single loop over each element to compute the derivatives at
    % each point (y1, y2)
    t=0; % we want the derivatives at each point at t=0, i.e. the starting time

    for i = 1:numel(x)
        Yprime = f(t,[x(i); y(i)]);
        u(i) = Yprime(1);
        v(i) = Yprime(2);
    end
    
    figure;
    quiver(x,y,u,v,'r'); 
    xlabel('y_1')
    ylabel('y_2')
    axis tight equal;
    title(['Linear system with input ',num2str(j)]);
    print(['phase_portrait ',num2str(j)],'-dpng')
end