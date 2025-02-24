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

function pop=DetermineDomination(pop)

    n=numel(pop);

    for i=1:n
        pop(i).IsDominated=false;
    end

    for i=1:n
        if pop(i).IsDominated
            continue;
        end
        
        for j=1:n
            if Dominates(pop(j),pop(i))
                pop(i).IsDominated=true;
                break;
            end
        end
    end

end