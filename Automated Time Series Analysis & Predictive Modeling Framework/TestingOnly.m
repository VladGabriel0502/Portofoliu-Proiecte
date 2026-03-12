 y=[35.3 35.8 35.8 35.8 35.9 36.3 36.4 36.3 36.1 36.1 35.9 36.2 35.1 ...
	   35.3 35.8 35.8 35.7 36.2 36.3 36.2 35.9 35.9 35.8 36.8 35.2 35.4 ...
	   35.7 35.1 35.5 35.9 36.0 36.0 35.8 35.7 35.6 35.9 35.1 35.1 35.2];
	y=[y ...
	   35.0 35.0 35.3 35.3 35.5 35.3 35.3 35.3 35.7 35.1 35.0 35.2 35.2 ...
	   35.2 35.4 35.6 35.6 35.1 35.2 35.1 35.2 33.9 34.8 34.8 34.7 34.8 ...
	   35.0 35.2 35.2 34.8 34.7 34.7 35.0 34.6 34.2 34.7 34.7 34.9 35.2];
	y=[y ...
	   35.4 35.4 35.3 35.3 35.1 35.5 34.9 34.9 35.0 35.2 35.1 35.4 35.5 ...
	   35.4 35.3 35.0 35.0 35.4 34.6 34.5 34.8 34.7 34.9 35.2 35.1 35.2 ...
	   35.0 34.9 34.8 35.2];
    [ ysta, yT, theta, lambda, p_new ] = trend(y, 0, 1);
    [yS, v, theta_F, P] = seasonal(ysta);
    
    figure
    plot(yT + yS)
    hold on
    plot(y)
    hold off
    figure
    plot(ysta-yS)
    hold on 
    plot(yS)


  %%
  % ----------------------------------------------------
w = 0:0.01:pi;
Y = freqz(ysta, 1, w);
L = length(ysta); % Asigură-te că L este lungimea corectă

% ----------------------------------------------------
% PASUL 3: Calibrarea și Spectrul pe o Singură Față
% ----------------------------------------------------
P2 = abs(Y);

% P1 = P2(1:floor(L/2)+1);
% P1(2:end-1) = 2*P1(2:end-1); 

% ----------------------------------------------------
% PASUL 4: Crearea axei de Frecvență
% ----------------------------------------------------
f = (0:floor(L/2))/L;

% ----------------------------------------------------
% PASUL 5: Plotarea
% ----------------------------------------------------
figure;
plot(w/pi, P2)
title('Spectrul de Amplitudine al Semnalului y(t)')
xlabel('Frecvența (Hz)')
ylabel('|Amplitudine|')
grid on

[valori_varfuri, indici_varfuri] = findpeaks(P2);
[valoare_maxima] = max(valori_varfuri)
masca_filtrare = valori_varfuri > 0.15 * valoare_maxima;
valori_varfuri_update = valori_varfuri(masca_filtrare);
indici_varfuri = indici_varfuri(masca_filtrare);

[valori_sortate, indici_sortare] = sort(valori_varfuri_update, 'descend');
indici_varfuri = indici_varfuri(indici_sortare);

moreP = round(2*pi./w(indici_varfuri))
moreP = unique(moreP,'stable')

%%
w = 0:0.01:pi;
r_ysta = xcov(ysta);
Y_neted = freqz(r_ysta, 1, w); % as the definition
L = length(ysta); % Asigură-te că L este lungimea corectă

% ----------------------------------------------------
% PASUL 3: Calibrarea și Spectrul pe o Singură Față
% ----------------------------------------------------
P2 = abs(Y_neted);

% P1 = P2(1:floor(L/2)+1);
% P1(2:end-1) = 2*P1(2:end-1); 

% ----------------------------------------------------
% PASUL 4: Crearea axei de Frecvență
% ----------------------------------------------------
f = (0:floor(L/2))/L;

% ----------------------------------------------------
% PASUL 5: Plotarea
% ----------------------------------------------------
figure;
plot(w/pi, P2)
title('Spectrul de Amplitudine al Semnalului y(t)')
xlabel('Frecvența (Hz)')
ylabel('|Amplitudine|')
grid on

[valori_varfuri, indici_varfuri] = findpeaks(P2);
[valoare_maxima] = max(valori_varfuri)
masca_filtrare = valori_varfuri > 0.035 * valoare_maxima;
valori_varfuri_update = valori_varfuri(masca_filtrare);
indici_varfuri = indici_varfuri(masca_filtrare);

[valori_sortate, indici_sortare] = sort(valori_varfuri_update, 'descend');
indici_varfuri = indici_varfuri(indici_sortare);

moreP = round(2*pi./w(indici_varfuri))
moreP = unique(moreP,'stable')

%%
ystaf = [1;2;3;4;5]
t_n = 1:5; % Time interval
        t_n = t_n';
        LenP = 2;
        P = [ 5 10];
        
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
        R1 = R;
        r1 = r; 
        
        % We calculate R^-1 * r using QR transformation
        for i = 2:LenP
            for j = 1:i-1
                 G = eye(LenP * 2); % We build all the Givens operators acording to the information from the course
                 Fact = 1/sqrt(R(i,j)^2 + R(j,j)^2);
                 G(j,j) = Fact * R(j,j) ;
                 G(i,j) = -Fact * R(i,j) ;
                 G(j,i) = Fact * R(i,j) ;
                 G(i,i) = Fact * R(j,j) ;
                 R1 =  G * R1; % -> new Phi
                 r1 = G * r1 ;
             end
        end
       
        % We find Theta
        theta_F = Exfoliere(R1, r1)'
        theta_F_int = R \ r

%%
v = [ 1 2 3 4 5 6 7 8 9 10 11 12 12 9 ]
na = 4
 [rv, K] = xcov(v, 'unbiased')
        rv = rv(K >= 0)
        rv = rv(1:na + 1)
%%
v = [ 1 2 3 4 5 6 7 8 9 10 11 12  ];
N = 12;
theta_AR = [ 1 2 3 4];
na = 3;
yAR(1:na) = v(1:na);
        yAR(na + 1:N) = zeros(N - na, 1);
        for n = na + 1:N
            for i = 1:na
                yAR(n) = yAR(n) - theta_AR(i + 1) * v(n - i);
            end
        end
        yAR = yAR'
        disp('Prima varianta');
 %%
yAR(1:na) = v(1:na);
yAR(na + 1:N) = zeros(N - na, 1); 
for n = na + 1:N
    yAR(n) = -theta_AR(2:na + 1) * v(n - 1:-1:n - na)';
end
yAR = yAR'
disp('A doua varianta')
%%
V = []
na = 3;
for i = 1:na
    if i <= na
        V = [V [v(i:-1:1)'; zeros(na - i,1)]];
    end
end
V
-theta_AR(2:na + 1) * V
%%
V = []
yAR = []
yAR(1) = v(1);
for i = 1:na-1
    V = [V [v(i:-1:1)'; zeros(na - i,1)]];
end
yAR(2:na) = -theta_AR(2:na + 1) * V
%%
e_ARMA = v;
        yARMA = zeros(N,1);
        for n = 2:N
            % First we calculate the AR part of yARMA
            if n < na + 1
                for i = 1:n-1
                    yARMA(n) = yARMA(n) - model_arma.A(i + 1) * v(n - i);
                end
            else
                for i = 1:na
                    yARMA(n) = yARMA(n) - model_arma.A(i + 1) * v(n - i);
                end
            end
            
            % Then we calculate the MA part of yARMA
            if n < nc + 1
                for i = 1:n-1
                    yARMA(n) = yARMA(n) + model_arma.C(i + 1) * e_ARMA(n - i);
                end
            else
                for i = 1:nc
                    yARMA(n) = yARMA(n) + model_arma.C(i + 1) * e_ARMA(n - i);
                end
            end

            % And the last part is e
            if n < nalpha + 1
                for i = 1:n-1
                    e_ARMA(n) = e_ARMA(n) + theta_nalpha(i + 1) * v(n - i);
                end
            else
                for i = 1:nalpha
                    e_ARMA(n) = e_ARMA(n) + theta_nalpha(i + 1) * v(n - i);
                end
            end
            
        end
%%
v = [ 9 8 10 2 3 1 12 7 6 1 ]
theta_nalpha = [ 1 1 1 1 1 1]
A = [1 2 3 4 5];
C = [1 2 3];
V = []
na = 4;
nc = 2;
nalpha = 5;
N = length(v)
% We initialize e with the extrapolated AR model
        for n = 1:N
            if n <= nalpha
                e_AR(n) = theta_nalpha * [v(n:-1:1)'; zeros(nalpha - n + 1,1)];
            else
                e_AR(n) = theta_nalpha * v(n:-1:n - nalpha)';
            end
        end
        e_AR
        
        % Now we calculate yARMA
        V = [];
        yARMA(1) = v(1);
        for n = 1:na - 1
            V = [V [v(n:-1:1)'; zeros(na - n,1)]];
        end
        yARMA(2:na) = -A(2:na + 1) * V;

        % We calculate yARMA without the MA component
        for n = na + 1:N
            yARMA(n) = -A(2:na + 1) * v(n - 1:-1:n - na)';
        end
        yARMA

        % Now we add the MA component
        V = [];
        for n = 1:nc - 1
            V = [V [e_AR(n:-1:1)'; zeros(nc - n,1)]];
        end
        yARMA(2:nc) = yARMA(2:nc) + C(2:nc + 1) * V;

        % We calculate yARMA without the MA component
        for n = nc + 1:N
            yARMA(n) =  yARMA(n) + C(2:nc + 1) * e_AR(n - 1:-1:n - nc)';
        end
        yARMA = yARMA'
