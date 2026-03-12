% OM - Orizontul de Masura
% OP - Orizontul de Extrapolare
function [PQ, SNR_OM, SNR_OP, out_indice ] = pred_qual( Y_OM, Y_OP, Y_complet_pred_OM, Y_complet_pred_OP, sigma, nr )
    % Weighting constants
    w_alpha = 0.45 ;
    w_beta = 0.2 ;
    w_gamma = 0.35;
    
    % Other important values
    N = length(Y_OM.y);
    k = length(Y_complet_pred_OM.y);
    e_om = Y_OM.y - Y_complet_pred_OM.y; % the noise from the horizon of measure
    e_op = Y_OP.y - Y_complet_pred_OP.y; % noise from the prediction horizon

    % SNR_N
    mean_y = mean(Y_OM.y);
    sigma_y_N = sqrt( 1/N * (norm(Y_OM.y - mean_y) ^ 2));
    lambda = 1/N * (norm(e_om) ^ 2);
    SNR_N = sigma_y_N/sqrt(lambda);

    % SNR_k
    mean_y_est = mean(Y_OP.y);
    sigma_k = sqrt( 1/k * (norm(Y_OP.y - mean_y_est) ^ 2));
    lambda_est = 1/k * (norm(e_op) ^ 2);
    SNR_k = sigma_k/sqrt(lambda_est);

    % SNR_N_k
    SNR_N_k = sqrt(( N * sigma_y_N ^ 2 + k * sigma_k ^ 2 ) / ( N * lambda + k * lambda_est ));
    
    % Calculating the value of PQ alpha and beta
    x = SNR_N * SNR_k;
    PQ_alpha = (100 * x)/(x + 1);

    x = SNR_N_k;
    PQ_beta = (100 * x)/(x + 1);

    % Calculating the value of PQ gamma
    y_pred = Y_complet_pred_OP.y;
    y_op = Y_OP.y;
    sigma2 = sigma(2:nr + 1) .^ 2;
    red_flag = 0;
    tub_incredere_sus = y_pred + 3 * sigma(2:nr + 1);
    tub_incredere_jos = y_pred - 3 * sigma(2:nr + 1);
    sigma = sigma(2:nr + 1);
    indice_out = [];
    indice_in = [];
    
    % Differentiating between the values that are contained within the
    % confidence tube and the ones that are not contained in the confidence
    % tube
    out_indice = 0;
    for i = 1:nr
        if y_op(i) > tub_incredere_sus(i) || y_op(i) < tub_incredere_jos(i)
            indice_out = [indice_out i];
        else
            indice_in = [indice_in i];
        end
    end

    if isempty(indice_in) == 0
        x_in = sum( (abs(e_op(indice_in)) .^ 2 ) .* sigma2(indice_in) );
        x_in = x_in / ( sum( abs(e_op(indice_in)) .^ 2 ) * sum( sigma2(indice_in) ) );
        x_in = sqrt(x_in);
    else
        x_in = 0;
    end

    if isempty(indice_out) == 0
        x_out = sum( abs( e_op(indice_out) ) ./ (3 * sigma(indice_out) ) );
        out_indice = 1;
        red_flag = 1;
    else
        x_out = 0;
    end
 
    x = x_in + x_out;
    
    PQ_gamma = 100/(1 + x);

    if red_flag == 0
        PQ = w_alpha * PQ_alpha + w_beta * PQ_beta + w_gamma * PQ_gamma ;
    else
        PQ = PQ_gamma ;
    end
    SNR_OM = SNR_N;
    SNR_OP = SNR_k;

end