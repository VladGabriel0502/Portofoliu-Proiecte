function [P, ys1P, V, perioade_Repetitive, k]= WiRo(ysta, perioadaTF, suspiciuneZC, perioade_Repetitive, best_now, k )
    N = length(ysta) ; % we find the length of ysta
    L = floor(N/2) ; % We find the maximum value for P
    min_val = inf ; % we want to find the minimum value of P so we start with the maxim value possible
    miu = 0.75;
    energy_sta = norm(ysta) ^ 2 ;
    period = [] ;
    ysP = [] ;
    V = [];
    yS_Mat = [];
    for P = 2:L
        L_P = floor(N/P) ; % we calculate L_P in order to find the number of lines for Ysta
        Nr = L_P * P;
        Y_sta = reshape(ysta(1:Nr), [P, L_P])' ;  % We don't take into account the last L - Nr + 1 elements 
        ys1P = mean(Y_sta)';  % we find the mean values on columns
        yS = repmat(ys1P, L_P, 1 ) ; % we extend ys1P in order to be the same lenght as ysta
        yS(Nr + 1:N) = ys1P(1:N - Nr) ; % this extension is for the last N - Nr elements
        
        yS_Mat = [yS_Mat yS ];

        V(P-1) = norm(ysta - yS) ^ 2; % we find every value of V
        if norm(yS) > 1e-13 % if yS = zeros(N,1) it means we got the wrong vector so we exclude it
            if V(P-1) < min_val % we find the minimum value
                min_val = V(P-1) ;
                period = P ;
            end
        else
            V(P-1) = Inf;
        end
    end
    
    % We transform V from valley to peak in order to use findpeaks function
    perioadeBrute = 2:L;
    maxV = max(V);
    newV = -V + maxV;
    prag = (newV(1) + max(newV))/2;

    % We go through the same process as TF
    [valori_varfuri, indici_varfuri] = findpeaks(newV);
    masca_filtrare = valori_varfuri > prag;
    indici_varfuri = indici_varfuri(masca_filtrare);
    perioadeBrute = perioadeBrute(indici_varfuri);

    if (min_val <= miu * energy_sta || ~isempty(perioadeBrute)) && suspiciuneZC == 0 % if the miminum value respects the criterion from the course we found our period
        if V(L - 1) <= miu * energy_sta
            perioadeBrute = [perioadeBrute L]; % We take the last value of V because it might me a good alternative for P and not a peak
        end
        perioadeBrute = [perioadeBrute period]; % we add the period corresponding to the min value
        perioadeBrute = unique(perioadeBrute); % minimum might appear twice
        perioade_Repetitive = [ perioade_Repetitive perioadeBrute ];
        perDif = perioadeBrute - perioadaTF; % we take the closest value to the value from TF
        perDif = abs(perDif);
        masca = perDif == min(perDif);
        perioadeBrute = perioadeBrute(masca);
        P = max(perioadeBrute);
        if abs(P - perioadaTF) > 2*perioadaTF*P/(perioadaTF + P)
            nr = round(best_now / perioadaTF);
            if nr == 1 || nr == 0
                P = perioadaTF;
            else
                % we increment k here but k is passed by reference ( output
                % and input alike )
                P = round(best_now/nr);
                k = k + 1;
            end
        end
        ys1P = yS_Mat(:,P - 1);
    else
        P = 0;
        ys1P = zeros(N,1); % in order that the final result will be the noise ( after repeating wiro )
    end
end

%