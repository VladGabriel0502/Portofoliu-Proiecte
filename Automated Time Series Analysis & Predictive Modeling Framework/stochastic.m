function [yAR, e_AR, lambda2_AR, theta_AR, yARMA, e_ARMA, lambda2_ARMA, theta_ARMA, na, nc ] = stochastic(v, na, nc, nalpha)
    
    % We define nc for calling the function stochastic with 2 parameters
    if nargin < 3
        nc = [];
        nalpha = [];
    elseif nargin < 4 || isempty(nalpha)
        nalpha = min(3 * max(na, nc), floor(length(v)/3) + 1 )
    end

    % Length of v
    N = length(v);
    
    if isempty(nc) || nc == 0
        % The outputs for ARMA model are empty
        yARMA = [];
        e_ARMA = [];
        lambda2_ARMA = [];
        theta_ARMA = [];
        v = reshape(v, [1,N]);

        % AR model estimation
        % Computing cross-covariance of v
        [rv, K] = xcov(v, na, 'unbiased');
        rv = rv(K >= 0);
        
        % Finding the coefficients of AR model using Levinson-Durbin algorithm
        theta_AR = levinson(rv, na);
        
        % We initialize yAR with v from 1 -> na
        V = []; 
        yAR = [];
        yAR(1) = v(1);
        for n = 1:na - 1
            V = [V [v(n:-1:1)'; zeros(na - n,1)]];
        end
        yAR(2:na) = -theta_AR(2:na + 1) * V;

        % We calculate the rest of yAR
        for n = na + 1:N
            yAR(n) = -theta_AR(2:na + 1) * v(n - 1:-1:n - na)';
        end
        yAR = yAR';
        
        % We find the white noise e as the difference between v and yAR
        e_AR = v - yAR;
        lambda2_AR = 1/N * norm(e_AR)^2;
    else
        % The outputs for AR model are empty
        yAR = [];
        e_AR = [];
        lambda2_AR = [];
        
        % ARMA model estimation
        Ts = 1;
        data = iddata(v, [], Ts);

        % We prevent armax error for na + nc > N - max(na, nc)
        i = 1;
        while na + nc >= N - max(na, nc)
            r = rem(i,2);
            if r == 0
                na = na - 1;
            else
                nc = nc - 1;
            end
            i = i + 1;
        end
        
        opt = armaxOptions;
        opt.EnforceStability = true;
        model_valid = false;
        
        i = 0;
        while model_valid == false
            try
                model_arma = armax(data, [na nc], opt);
                model_valid = true;
            catch me
                fprintf('Eroare la [ na = %d nc = %d ]: %s', na, nc, me.message);
            
                r = rem(i,2);
                if r == 0 && na > 0
                    na = na - 1;
                elseif r == 1 && nc > 0
                    nc = nc - 1;
                end
                i = i + 1;

                model_valid = false;
            end
        end
        
        v = reshape(v, [1,N]);
        theta_ARMA = [model_arma.A'; model_arma.C'];
        
        % AR model estimation
        % Computing cross-covariance of v
        [rv, K] = xcov(v, nalpha, 'unbiased');
        rv = rv(K >= 0);
        
        % Findind the coefficients of AR model using Levinson-Durbin algorithm
        theta_nalpha = levinson(rv, nalpha);
       
        % We initialize e with the extrapolated AR model
        for n = 1:N
            if n <= nalpha
                e_AR(n) = theta_nalpha * [v(n:-1:1)'; zeros(nalpha - n + 1,1)];
            else
                e_AR(n) = theta_nalpha * v(n:-1:n - nalpha)';
            end
        end
        
        % Now we calculate yARMA
        yARMA(1) = v(1);
        V = [];
        for n = 1:na - 1
            V = [V [v(n:-1:1)'; zeros(na - n,1)]];
        end
        yARMA(2:na) = -model_arma.A(2:na + 1) * V;

        % We calculate yARMA without the MA component
        for n = na + 1:N
            yARMA(n) = -model_arma.A(2:na + 1) * v(n - 1:-1:n - na)';
        end

        % Now we add the MA component
        V = [];
        for n = 1:nc - 1
            V = [V [e_AR(n:-1:1)'; zeros(nc - n,1)]];
        end
        yARMA(2:nc) = yARMA(2:nc) + model_arma.C(2:nc + 1) * V;

        % We calculate yARMA without the MA component
        for n = nc + 1:N
            yARMA(n) =  yARMA(n) + model_arma.C(2:nc + 1) * e_AR(n - 1:-1:n - nc)';
        end
        yARMA = yARMA';
        
        theta_AR = theta_nalpha;
        e_ARMA = v - yARMA;
        lambda2_ARMA = 1/N * norm(e_ARMA)^2;
    end

end