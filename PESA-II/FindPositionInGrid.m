%
% Copyright (c) 2015, Yarpiz (www.yarpiz.com)
% All rights reserved. Please read the "license.txt" for license terms.
%
% Project Code: YPEA123
% Project Title: Pareto Envelope-based Selection Algorithm II (PESA-II)
% Publisher: Yarpiz (www.yarpiz.com)
% 
% Developer: S. Mostapha Kalami Heris (Member of Yarpiz Team)
% 
% Contact Info: sm.kalami@gmail.com, info@yarpiz.com
%

function [pop, grid]=FindPositionInGrid(pop,grid)

    LB=[grid.LB];
    UB=[grid.UB];
    
    for k=1:numel(grid)
        grid(k).N=0;
        grid(k).Memebrs=[];
    end
    
    for i=1:numel(pop)
        k=FindGridIndex(pop(i).Cost,LB,UB);
        pop(i).GridIndex=k;
        grid(k).N=grid(k).N+1;
        grid(k).Members=[grid(k).Members i];
    end

end

function k=FindGridIndex(z,LB,UB)

    nObj=numel(z);
    
    nGrid=size(LB,2);
    f=true(1,nGrid);
    
    for j=1:nObj
        f=f & (z(j)>=LB(j,:)) & (z(j)<UB(j,:));
    end
    
    k=find(f);

end