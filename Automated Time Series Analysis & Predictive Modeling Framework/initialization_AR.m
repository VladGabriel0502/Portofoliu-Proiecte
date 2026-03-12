% This function initialize the first population of search agents
function Positions = initialization_AR(SearchAgents_no, dim, ub)
    for i=1:dim
        Positions(:,i)=randi(ub(i),SearchAgents_no,1) - 1;
    end
end