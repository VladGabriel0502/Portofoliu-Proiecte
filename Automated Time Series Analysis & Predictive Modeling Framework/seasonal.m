function [yS, v, theta_F, P] = seasonal(ysta)
    ys = [];
    v = [];
    ysta_cop = ysta;

    N = length(ysta) ;
    i = 1; % index for period vector
    P = [];

    % We calculate Fourier Transformation in order to obtain better
    % precision for periods
    w = 0:0.001:pi;
    r_ysta = xcov(ysta);
    Y_neted = freqz(r_ysta, 1, w); % as the definition
    modulTF = abs(Y_neted);
    
    % Gasim toate peak-urile din TF si le folosim pentru WiRo mai departe
    [valori_varfuri, indici_varfuri] = findpeaks(modulTF);
    [valoare_maxima] = max(valori_varfuri);
    masca_filtrare = valori_varfuri > 0.035 * valoare_maxima;
    valori_varfuri_update = valori_varfuri(masca_filtrare);
    indici_varfuri = indici_varfuri(masca_filtrare);
    
    [valori_sortate, indici_sortare] = sort(valori_varfuri_update, 'descend');
    indici_varfuri = indici_varfuri(indici_sortare);
    
    % Perioadele obtinute in urma TF ordonate in functie de marimea
    % Peakurilor ~ gradul de importanta al lor in seria de timp
    perioade_TF = round(2*pi./w(indici_varfuri)); % we will consider periods >= N/2 also -> better for prediction
    
    % We take the unique values after we know if the time series resambles
    % a white/coloured noise
    perioade_TF = unique(perioade_TF,'stable');

    % If we suspect that our ysta is similar to a coloured noise
    suspiciuneZC = 0;
    if length(perioade_TF) >= 0.11 * N
        suspiciuneZC = 1;
    end

    perioade_TF_later = perioade_TF( perioade_TF >= floor(N/2) );
    perioade_TF = perioade_TF( perioade_TF < floor(N/2) );
    
    isOk = 1;
    if isempty(perioade_TF) == 0
        k = 0;
        perioade_Repetitive = [];
        best_now = perioade_TF(1);
        [P, ys1P, V, perioade_Repetitive, k]= WiRo(ysta_cop, perioade_TF(1), suspiciuneZC, perioade_Repetitive, best_now, k); % first period and ys1P detected
        if norm(ys1P) ~= 0 % we want to avoid situations where for some arrangement of matrix Y_sta => ys1p = 0
             ysta_cop = ysta_cop - ys1P;
             for i = 2:length(perioade_TF) % we repeat WiRo until we find no period
                 best_now = P(length(P)); % first period from WiRo closest to the peak from TF
                 % i = i + 1;
                 [period, ys1P, V, perioade_Repetitive, k] = WiRo(ysta_cop, perioade_TF(i), suspiciuneZC, perioade_Repetitive, best_now, k);
                 P = [ period P];
                 ysta_cop = ysta_cop - ys1P; % we substract from ysta what seasonal component we found 
             end
        end
    elseif isempty(perioade_TF) == 1 && isempty(perioade_TF_later) == 0
        disp('Seria nu are perioade < N/2!');
        P = perioade_TF_later;
        isOk = 0;
    elseif isempty(perioade_TF) == 0 && isempty(perioade_TF_later) == 0
        disp('Seria nu are perioade deloc!');
        P = [];
    end
 
    if norm(P) ~= 0  % if P is not 0
        
        if isOk == 1
            % First we find how many zeroes are in P
            k = 0;
            while P(k + 1) == 0
                k = k + 1;
            end
            
            % We substitute 0 from P to
            % round(best_now/round(best_now/perioade_TF_no_result) ~ best_now are the first periods
            if k ~= 0
                for i = 1:k
                    nr = round(P(length(P))/perioade_TF(length(perioade_TF) - k + i));
                    if nr <= 1
                        period = perioade_TF(length(perioade_TF) - k + i);
                        j = i - 1;
                        while ismember(period, P) == 1 && j >= 0
                            period = perioade_TF(length(perioade_TF) - k + j);
                            j = j - 1;
                        end
                        P(i) = period;
                    else
                        P(i) = round(P(length(P))/nr);
                    end
                end
            end
            
            % We might get some solid periods from perioade_Repetitive which
            % are obtained from running WiRo function repeatedly
            if length(unique(v)) ~= length(v)
                %We choose the value who appears the most
                repetitia = mode(perioade_Repetitive);
            else
                % We choose the period which is closest to the mean value if
                % all values are unique
                m = mean(perioade_Repetitive);
                diff = abs(perioade_Repetitive - m);
                masc = diff == min(diff);
                repetitia = perioade_Repetitive(masc);
            end
            if isnan(repetitia) == 0
                P = [P repetitia];
            end
            P = [P perioade_TF_later];
        end

        P = unique(P); % it is possible after TF to have same period many times so we exclude it 
        P = sort(P,'descend'); % we sort the period vector in descending order
        LenP = length(P);
        if P(LenP) == 0
            P = P(1:LenP - 1);
            LenP = LenP - 1; 
        end
    
        % Because WiRo cannout detect lower periods when needed i let na
        % and fc equal the values for the lowest P = 2
        na = 35 ;
        fc = 0.5 ;
        % We filter the data in order to reduce the noice that will beinherited by the parameters ai and bi
        [b, a] = cheby2(na, 50, fc) ; % 50 will remain here too ^_^
        ystaf = filter(b, a, ysta);

        % Resynchronization 
        YSTA = fft(ysta) ;
        YSTAF = fft(ystaf) ;
        YSTA_SYNC = abs(YSTAF) .* exp(1i * angle(YSTA));
        ystaf = real(ifft(YSTA_SYNC)) ;
    
        % We find theta_R_L ~ Fourier Coefficients
        t_n = 1:N; % Time interval
        t_n = t_n';
        
        % We find the R_L and r_L as in the course
        BPhi = [];
        k = 1;
        for i = 1:2*LenP
            if i <= LenP
                BPhi = [ BPhi sin(2*pi/P(i) * t_n)] ;
            elseif i > LenP && i <= 2*LenP
                BPhi = [ BPhi cos(2*pi/P(k) * t_n)] ;
                k = k + 1;
            end
        end
        R = BPhi' * BPhi ;
        r = BPhi' * ystaf ;
            
        % We calculate R^-1 * r using QR transformation
        for i = 2:LenP
            for j = 1:i-1
                G = eye(LenP * 2); % We build all the Givens operators acording to the information from the course
                Fact = 1/sqrt(R(i,j)^2 + R(j,j)^2);
                G(j,j) = Fact * R(j,j) ;
                G(i,j) = -Fact * R(i,j) ;
                G(j,i) = Fact * R(i,j) ;
                G(i,i) = Fact * R(j,j) ;
                R =  G * R; % -> new Phi
                r = G * r ;
             end
         end
           
        % We find Theta
        theta_F = Exfoliere(R, r)';
        yS_tilda = BPhi * theta_F;
        yS = yS_tilda;
    
        % We find the amplitude = the difference in energy between the seasonal part and ysta
        ysta_A = reshape(ysta,[N, 1]);
        yS_tilda = reshape(yS_tilda,[1, N]);
        A = yS_tilda * ysta_A / (norm(yS_tilda) ^2);
        yS = A * yS;

        % Schuster periodogram 
        L = length(theta_F)/2;
        Periodograma_Schuster = [];
        for i = 1:L
            Periodograma_Schuster = [Periodograma_Schuster sqrt(theta_F(i)^2 + theta_F(i + L)^2)];
        end
        masca_maxim = Periodograma_Schuster == max(Periodograma_Schuster);
        if P(masca_maxim) == 2
            sort_Periodogram = sort(Periodograma_Schuster);
            maxim_tempo = sort_Periodogram(LenP - 1);
            masca_filtrare = Periodograma_Schuster > 0.08 * maxim_tempo;
        else
            masca_filtrare = Periodograma_Schuster > 0.08 * max(Periodograma_Schuster);
        end
        P_nou = P(masca_filtrare);
        
        % We verify if P and P_nou are the same -> if not we recalculate
        % theta_F
        eq = isequal(P, P_nou);
        if eq == 1
            v = ysta - yS;
        else
            P = P_nou;
            P = sort(P,'descend'); % we sort the period vector in descending order 
            LenP = length(P); % length of P
            P_L = P(LenP); % we use the least period as in the course
        
            % Because WiRo cannout detect lower periods when needed i let na
            % and fc equal the values for the lowest P = 2
            na = 35 ;
            fc = 0.5 ;
            % We filter the data in order to reduce the noice that will beinherited by the parameters ai and bi
            [b, a] = cheby2(na, 50, fc) ; % 50 will remain here ^_^
            ystaf = filter(b, a, ysta);
    
            % Resynchronization 
            YSTA = fft(ysta) ;
            YSTAF = fft(ystaf) ;
            YSTA_SYNC = abs(YSTAF) .* exp(1i * angle(YSTA));
            ystaf = real(ifft(YSTA_SYNC)) ;
        
            % We find theta_R_L ~ Fourier Coefficients
            t_n = 1:N; % Time interval
            t_n = t_n';
            
            % We find the R_L and r_L as in the course
            BPhi = [];
            k = 1;
            for i = 1:2*LenP
                if i <= LenP
                    BPhi = [ BPhi sin(2*pi/P(i) * t_n)] ;
                elseif i > LenP && i <= 2*LenP
                    BPhi = [ BPhi cos(2*pi/P(k) * t_n)] ;
                    k = k + 1;
                end
            end
            R = BPhi' * BPhi ;
            r = BPhi' * ystaf ;
            
            % We calculate R^-1 * r using QR transformation
            for i = 2:LenP
                for j = 1:i-1
                     G = eye(LenP * 2); % We build all the Givens operators acording to the information from the course
                     Fact = 1/sqrt(R(i,j)^2 + R(j,j)^2);
                     G(j,j) = Fact * R(j,j) ;
                     G(i,j) = -Fact * R(i,j) ;
                     G(j,i) = Fact * R(i,j) ;
                     G(i,i) = Fact * R(j,j) ;
                     R =  G * R; % -> new Phi
                     r = G * r ;
                 end
            end
           
            % We find Theta
            theta_F = Exfoliere(R, r)';
            yS_tilda = BPhi * theta_F;
            yS = yS_tilda;
        
            % We find the amplitude = the difference in energy between the seasonal part and ysta
            ysta_A = reshape(ysta,[N, 1]);
            yS_tilda = reshape(yS_tilda,[1, N]);
            A = yS_tilda * ysta_A / (norm(yS_tilda) ^2);
            yS = A * yS;
            v = ysta - yS;
        end

    else
        disp('Seria nu are perioade!');
        v = ysta ;
        theta_F = [];
        yS = zeros(N,1);
    end

end