function p = bestPolyDeg(y)
    % We build y_nou - made out of mean of y(1:i) and with some penalties
    % in order to be a little uniform
    N = length(y);
    y_med = y - mean(y);
    y_nou = zeros(1,N);
    for i = 1:N 
        y_nou(i) = mean(y_med(1:i)) * norm(y_med(1:i))/norm(y_med);
    end

    % We use an Akaie criterion in order to find the fittest polynomial
    % degree for this vector
    AIC_val = [];
    for p = 0:10
        % Finding the best trend polynomial
        [ ysta, ~, ~, ~, ~ ] = trend(y_nou, p, 1) ;
        SSE = norm(ysta)^2;
        AIC = log(SSE/N * (p + 1)) + 2 * ( p + 1 )/N * log( sqrt(N));
        AIC_val = [AIC_val AIC];
    end
    [~, index1] = min(AIC_val)

    % We proceed in a similar fashion to ysta ( resulted from y using trend
    % function )
    AIC_val = [];
    for p = 0:10
        % Finding the best trend polynomial
        [ ysta, ~, ~, ~, ~ ] = trend(y', p, 1) ;
        SSE = norm(ysta)^2;
        AIC = log(SSE/N * (p + 1)) + 2 * ( p + 1 )/N * log( sqrt(N));
        AIC_val = [AIC_val AIC];
    end
    [~, index2] = min(AIC_val)
    
    p = round(0.5 * index1 + 0.5 * index2);
    
end