% Grey Wolf Optimizer - for both AR and ARMA models

function [Alpha_score, Alpha_pos] = GWO_pred_ARMA( SearchAgents_no, Max_iter, lb, ub, dim, y_training_om, y_training_op )

% Initialize alpha, beta, and delta_pos
Alpha_pos = zeros(1,dim);
Alpha_score = -inf; % we want to maximize PQ so we start with the lowest value possible

Beta_pos = zeros(1,dim);
Beta_score = -inf; 

Delta_pos = zeros(1,dim);
Delta_score = -inf; 

%Initialize the positions of search agents
Positions=initialization_ARMA(SearchAgents_no,dim,ub);

l = 0; % Loop counter
L1 = ub(1) - lb(1);
L2 = ub(2) - lb(2);
L3 = ub(3) - lb(3);
L4 = ub(4) - lb(4);
% Main loop
while l < Max_iter
    l
    for i = 1:size(Positions,1)  

        % Calculate objective function for each search agent - PQ
        p = round(Positions(i, 1));
        na = round(Positions(i, 2));
        nc = round(Positions(i, 3));
        nalpha = round(Positions(i,4));

        % Return back the search agents that go beyond the boundaries of the search space
        if p > ub(1)
            p = rem(p, L1);
        elseif p < lb(1)
            while(p < lb(1))
                p = p + L1;
            end
        end

        if na > ub(2)
            na = rem(na, L2);
        elseif na < lb(2)
            while(na < lb(2))
                na = na + L2;
            end
        end

        if nc > ub(3)
            nc = rem(nc, L3);
        elseif nc < lb(3)
            while(nc < lb(3))
                nc = nc + L3;
            end
        end

        if nc == 0
            nc = 1;
        end

        if nalpha > ub(4)
            nalpha = rem(nalpha, L4);
        elseif nalpha < lb(4)
            while(nalpha < lb(4))
                nalpha = nalpha + L4;
            end
        end
        
        if nalpha == 0
            nalpha = 1;
        end
        
        Positions(i,:) = [p na nc nalpha];

        fitness = obj_func_pred_ARMA( p, na, nc, nalpha, y_training_om, y_training_op );
        
        % Update Alpha, Beta, and Delta
        if fitness > Alpha_score 
            Alpha_score = fitness; % Update alpha
            Alpha_pos = Positions(i,:);
        end
        
        if fitness < Alpha_score && fitness > Beta_score 
            Beta_score = fitness; % Update beta
            Beta_pos = Positions(i,:);
        end
        
        if fitness < Alpha_score && fitness < Beta_score && fitness > Delta_score 
            Delta_score = fitness; % Update delta
            Delta_pos = Positions(i,:);
        end
    end
    
    
    a = 2 - l * ((2)/Max_iter); % a decreases linearly fron 2 to 0
    
    % Update the Position of search agents including omegas
    for i = 1:size(Positions,1)
        for j = 1:size(Positions,2)     
                       
            r1=rand(); % r1 is a random number in [0,1]
            r2=rand(); % r2 is a random number in [0,1]
            
            A1 = 2*a*r1-a; % Equation (3.3)
            C1 = 2*r2; % Equation (3.4)
            
            D_alpha = abs(C1 * Alpha_pos(j) - Positions(i,j)); % Equation (3.5)-part 1
            X1 = Alpha_pos(j) - A1 * D_alpha; % We choose the closest integer from X1
                       
            r1 = rand();
            r2 = rand();
            
            A2 = 2*a*r1-a; % Equation (3.3)
            C2 = 2*r2; % Equation (3.4)
            
            D_beta = abs(C2 * Beta_pos(j) - Positions(i,j) ); % Equation (3.5)-part 2
            X2 = Beta_pos(j) - A2 * D_beta; % Similar to X1       
            
            r1 = rand();
            r2 = rand(); 
            
            A3 = 2 * a * r1 - a; % Equation (3.3)
            C3 = 2 * r2; % Equation (3.4)
            
            D_delta = abs( C3 * Delta_pos(j) - Positions(i,j)); % Equation (3.5)-part 3
            X3 = Delta_pos(j) - A3 * D_delta; % Similar to X1            
            
            Positions(i,j) = (X1 + X2 + X3)/3;% Equation (3.7)
            
        end
    end
    l = l + 1;    
end



