% EQ - the value of the extrapolation quaility criterion
% SNR_N - the value of the SNR of the horizon of measure
% SNR_k - the value of the SNR of the extrapolation horizon
% S_OM - iddata object with y without the last 5 samples
% S_OE - iddata object with the last 5 samples of y
% DET_OM - iddata object with y_determinist without the last 5 samples
% DET_OE - iddata object with the last 5 samples of y_determinist

function [ EQ, SNR_N, SNR_k ] = extra_qual( S_OM, S_OE, DET_OM, DET_OE )

    % Weighting constants
    w_alpha = 0.75 ;
    w_beta = 0.25 ;
    
    % Other important values
    N = length(S_OM.y);
    k = length(DET_OM.y);
    v = S_OM.y - DET_OM.y; % the noise from the horizon of measure
    e = S_OE.y - DET_OE.y; % noise from the extrapolation horizon

    % SNR_N
    mean_y = mean(S_OM.y);
    sigma_y_N = sqrt( 1/N * (norm(S_OM.y - mean_y) ^ 2));
    lambda = 1/N * (norm(v) ^ 2);
    SNR_N = sigma_y_N/sqrt(lambda);

    % SNR_k
    mean_y_est = mean(S_OE.y);
    sigma_k = sqrt( 1/k * (norm(S_OE.y - mean_y_est) ^ 2));
    lambda_est = 1/k * (norm(e) ^ 2);
    SNR_k = sigma_k/sqrt(lambda_est);

    % SNR_N_k
    SNR_N_k = sqrt(( N * sigma_y_N ^ 2 + k * sigma_k ^ 2 ) / ( N * lambda + k * lambda_est ));
    
    % Calculating the value of EQ
    x = SNR_N * SNR_k;
    EQ_alpha = (100 * x)/(x + 1);

    x = SNR_N_k;
    EQ_beta = (100 * x)/(x + 1);
    
    EQ = w_alpha * EQ_alpha + w_beta * EQ_beta ;
end