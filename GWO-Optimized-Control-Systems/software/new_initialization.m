function Positions = new_initialization(SearchAgents_no, dim, ub, lb)
    Positions = rand(SearchAgents_no, dim) .* (ub - lb) + lb;

    % Lens Imaging Reverse Learning (LIRL)
    reverse_Pos = zeros(SearchAgents_no, dim);
    center = (ub + lb) / 2;

    for i = 1:SearchAgents_no
        k = (1 + sqrt(i / SearchAgents_no))^8;
        reverse_Pos(i,:) = center + (center - Positions(i,:)) / k;
    end

    % Combină originalul cu reversul
    Positions = [Positions; reverse_Pos];

    % Selectează cele mai bune N poziții după fitness
    N = SearchAgents_no;
    fitnesses = zeros(2*N,1);
    for i = 1:2*N
        pos = Positions(i,:);
        % folosește o funcție temporară de fitness, înlocuiește după caz:
        fitnesses(i) = rand(); % trebuie înlocuit cu evaluare reală
    end
    [~, idx] = sort(fitnesses, 'descend');
    Positions = Positions(idx(1:N), :);
end
