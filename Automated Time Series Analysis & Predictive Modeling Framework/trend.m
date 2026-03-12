function [ ysta, yT, theta, lambda, p_new ] = trend(y, p, option)
    % Warning for the user
    p_new = p;
    if option == 0
        while p > 3
           disp('Atentie! Gradul polinomului este prea mare si rezultatele de predictie s-ar putea sa nu fie la fel de precise!');
           prompt = 'Doriti sa micsorati gradul? ( Y/N ): ' ;
           txt = input(prompt,"s");
           if isempty(txt)
               txt = 'Y';
           end
           if( txt == 'Y' || txt == 'y' )
               prompt = 'Tastati alta valoare pentru p ( <= 3 ): ' ;
               p = input(prompt);
               p_new = p;
           end
        end
    end

    [theta, lambda] = MCMMP_QR( y, p ) ; % We find theta
    [~, N] = size(y); % The number of samples
    % Updated the former way of building Phi
    if p == 0 
        Phi = ones(N,1);
    elseif p == 1
        colMain = (1:N)';
        Phi = [ ones(N,1) colMain];
    else
        colMain = (1:N)';
        Phi = [ ones(N,1) colMain];
        for i = 3:p + 1
            Phi(:,i) = Phi(:,i - 1) .* colMain;
        end
    end

    yT = Phi * theta' ;
    y = y' ;

    ysta = y - yT ; % We calculate ysta - stationary for future purposes
    ysta_med = mean(ysta); % Nu mai stiu exact, tb asked
    ysta = ysta - ysta_med ;
    theta(1) = theta(1) + ysta_med ;

end % end function