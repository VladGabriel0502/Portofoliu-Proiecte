function fitness = obj_func_pred_AR( p, na, y_training_om, y_training_op )

    % Initializing N_training and N_antrenament_2
    N_antrenament_2 = length(y_training_om);
    N_Training = length(y_training_op) + N_antrenament_2;

    % Finding the best trend polynomial
    [ ysta, yT, theta, lambda, ~ ] = trend(y_training_om', p, 1) ; % 1 ==  not dispaying info for p > 3
    
    % We calculate Fourier-Schuster Model
    [yS, v, theta_F, P] = seasonal(ysta);
        
    % Deterministic Component
    y_Determinist = yT + yS;
    
    % Estimation of the last 5 terms - trend
    Phi = [];
    for j = N_antrenament_2 + 1:N_Training
        for o = 1:p + 1
            Phi(j - N_antrenament_2,o) = j ^ ( o - 1 ) ;
        end
    end
        
    % We find the N-k terms both estimated and the ones we took to verify the data
    yT_est = Phi * theta';
        
    if isequal(P, 0) == 0
       % Estimation of the last terms - seasonal
       L = length(P);
       Phi_F = [];
       t_est = N_antrenament_2 + 1:N_Training;
       t_est = t_est';
            
       l = 1;
       for j = 1:2 * L
           if j <= L
               Phi_F = [ Phi_F sin(2*pi/P(j) * t_est)] ;
           elseif j > L && j <= 2*L
               Phi_F = [ Phi_F cos(2*pi/P(l) * t_est)] ;
               l = l + 1;
           end
        end
            
        % We find the N-k-k/2 terms both estimated and the ones we took to verify the data
        yS_est = Phi_F * theta_F;
        y_Determinist_est = yT_est + yS_est;
    else
        y_Determinist_est = yT_est;
        v = ysta;
    end

    [yAR, e_AR, lambda2_AR, theta_AR, ~, ~, ~, ~ ] = stochastic(v, na);
     % Calculating yAR_pred
     nr = N_Training - N_antrenament_2;
     yAR(N_antrenament_2 + 1:N_Training) = zeros(nr,1);
     for j = 1:nr
         for l = 1:na
             yAR(N_antrenament_2 + j) = yAR(N_antrenament_2 + j) - theta_AR(l + 1) * yAR(N_antrenament_2 + j - l);
         end
     end

     % We also calculate AR part
     sigma2 = zeros(nr,1); % 6 so that we can use recursion with sigma2(1) = sigma2(0) = 0
     alpha_hat = InfiniteDivisionPoly(1, theta_AR, nr);
     for j = 2:nr + 1
         sigma2(j) = sigma2(j - 1) + lambda2_AR * alpha_hat(j - 1)^2;
     end
     sigma = sqrt(sigma2);

     % Calculating every value of PQ(na)
     Y_OM = iddata;
     Y_OM.y = y_training_om;

     Y_OP = iddata;
     Y_OP.y = y_training_op;

     Y_complet_pred_OM = iddata;
     Y_complet_pred_OM.y = y_Determinist + yAR(1:N_antrenament_2);

     Y_complet_pred_OP = iddata;
     Y_complet_pred_OP.y = y_Determinist_est + yAR(N_antrenament_2 + 1:N_Training);
        
     [fitness, ~ , ~, ~ ] = pred_qual( Y_OM, Y_OP, Y_complet_pred_OM, Y_complet_pred_OP, sigma, nr );
end