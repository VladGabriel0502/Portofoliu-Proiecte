% This function initialize the first population of search agents
function Positions = initialization_ARMA(SearchAgents_no, dim, ub)
    for i=1:dim
        if i == 3 || i ==4 
            Positions(:,i)=randi(ub(i),SearchAgents_no,1);
        else
            Positions(:,i)=randi(ub(i),SearchAgents_no,1);
        end
    end
end