function [ Alpha_score, Alpha_pos ] = GWO_PID_Update(SearchAgents_no, Max_iter, lb, ub, dim, Y_ref, U_ini, Y_ini, Ts, bestmodel, Y_max, U_max, Y_min, U_min)

    Alpha_pos = zeros(1, dim);
    Alpha_score = -Inf;

    Beta_pos = zeros(1, dim);
    Beta_score = -Inf;

    Delta_pos = zeros(1, dim);
    Delta_score = -Inf;

    Positions = initialization(SearchAgents_no, dim, ub, lb);

    lc = 0;
    while lc < Max_iter
        for i = 1:SearchAgents_no
            % Corectare limite
            Positions(i,:) = max(min(Positions(i,:), ub), lb);

            fitness = Functia_Fitness_AM(Positions(i,:),Y_ref, U_ini, Y_ini, Ts, bestmodel, Y_max, U_max, Y_min, U_min);

            if fitness > Alpha_score
                Alpha_score = fitness;
                Alpha_pos = Positions(i,:);
            elseif fitness > Beta_score
                Beta_score = fitness;
                Beta_pos = Positions(i,:);
            elseif fitness > Delta_score
                Delta_score = fitness;
                Delta_pos = Positions(i,:);
            end
        end

        % IGWO-style: convergență non-liniară a lui a
        K = 0.3;
        a_initial = 2;
        a_end = 0;
        a = (a_initial - a_end) * exp(-(lc^2) / (K * Max_iter)^2) + a_end;

        for i = 1:SearchAgents_no
            for j = 1:dim
                % Calcul X1 - Alpha
                r1 = rand(); r2 = rand();
                A1 = 2 * a * r1 - a;
                C1 = 2 * r2;
                D_alpha = abs(C1 * Alpha_pos(j) - Positions(i,j));
                X1 = Alpha_pos(j) - A1 * D_alpha;

                % Calcul X2 - Beta
                r1 = rand(); r2 = rand();
                A2 = 2 * a * r1 - a;
                C2 = 2 * r2;
                D_beta = abs(C2 * Beta_pos(j) - Positions(i,j));
                X2 = Beta_pos(j) - A2 * D_beta;

                % Calcul X3 - Delta
                r1 = rand(); r2 = rand();
                A3 = 2 * a * r1 - a;
                C3 = 2 * r2;
                D_delta = abs(C3 * Delta_pos(j) - Positions(i,j));
                X3 = Delta_pos(j) - A3 * D_delta;

                % Adaptive ponderi
                total_score = Alpha_score + Beta_score + Delta_score + 1e-6;
                w1 = Alpha_score / total_score;
                w2 = Beta_score / total_score;
                w3 = Delta_score / total_score;

                % Componente direcționale (PSO-style)
                b1 = 0.5; b2 = 0.5;
                r3 = rand(); r4 = rand();

                % Update poziție
                Positions(i,j) = w1 * X1 + w2 * X2 + w3 * X3 + ...
                                 b1 * r3 * (Alpha_pos(j) - Positions(i,j)) + ...
                                 b2 * r4 * (X1 - Positions(i,j)) / (abs(randn()) + 2);
            end
        end
        disp(['Rulare' num2str(lc)]) ;
        lc = lc + 1;
    end
end
