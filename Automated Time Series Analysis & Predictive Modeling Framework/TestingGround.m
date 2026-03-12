
v = [1 2 3 4 5 6 7 8 9 10]';
N = length(v);
A = [1 2 3 4 ];
C = [1 2 3 4 ];
Alpha = [1 2 3 4 5 6 7 8];
e_ARMA = v;
yARMA = zeros(N, 1)
na = 3
nc = 3
nalpha = 7;
for n = 2:N
    % First we calculate the AR part of yARMA
    if n < na + 1
       for i = 1:n-1
           yARMA(n) = yARMA(n) - A(i + 1) * v(n - i);
       end
    else
       for i = 1:na
           yARMA(n) = yARMA(n) - A(i + 1) * v(n - i);
        end
    end
            
    % Then we calculate the MA part of yARMA
    if n < nc + 1
       for i = 1:n-1
          yARMA(n) = yARMA(n) + C(i + 1) * e_ARMA(n - i);
       end
    else
       for i = 1:nc
          yARMA(n) = yARMA(n) + C(i + 1) * e_ARMA(n - i);
       end
    end

    % And the last part is e
    if n < nalpha + 1
       for i = 1:n-1
           e_ARMA(n) = e_ARMA(n) + Alpha(i + 1) * v(n - i);
       end
    else
       for i = 1:nalpha
           e_ARMA(n) = e_ARMA(n) + Alpha(i + 1) * v(n - i);
       end
    end          
end
yARMA
e_ARMA
%%
%  [P, ys1P, V]= WiRo(ysta,6,0);
% P = 84
% L_P = floor(168/P) 
% Nr = L_P * P
% Y_sta = reshape(ysta(1:Nr), [P, L_P])'
% ys1P = mean(Y_sta)'
% yS = repmat(ys1P, L_P, 1 );
% yS(Nr + 1:N) = ys1P(1:N - Nr);
% V = norm(ysta - yS) ^ 2
% energy = norm(ysta) ^ 2

% plot(ysta)
% hold on
% plot(ys1P)

% figure
% plot(V)

% ----------------------------------------------------
% PASUL 2: Calculul Transformatei Fourier Rapide (FFT)
% ----------------------------------------------------
w = 0:0.01:pi;
Y = freqz(ysta(1:N_Training), 1, w);
L = length(ysta(1:N_Training)); % Asigură-te că L este lungimea corectă

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
[valoare_maxima] = max(P2)

[valori_varfuri, indici_varfuri] = findpeaks(P2);
masca_filtrare = valori_varfuri > 0.15 * valoare_maxima;
valori_varfuri_update = valori_varfuri(masca_filtrare);
indici_varfuri = indici_varfuri(masca_filtrare);

[valori_sortate, indici_sortare] = sort(valori_varfuri_update, 'descend');
indici_varfuri = indici_varfuri(indici_sortare);

moreP = round(2*pi./w(indici_varfuri))
moreP = unique(moreP,'stable')
%%
% 1. Generăm sau încărcăm datele (v)
% Presupunem că v este vectorul tău din V01.mat
load V04.mat;
v = V.y; 
Ts = 1; % Timpul de eșantionare (modifică dacă îl cunoști)

% 2. Transformăm vectorul în obiect iddata
% Pentru ARMA, nu avem intrare 'u', deci lăsăm gol []
data = iddata(v, [], Ts);

% 3. Definirea ordinelor modelului ARMA(p, q)
na = 40 ; % Ordinul părții autoregresive (AR) - p
nc = 20; % Ordinul părții mediei mobile (MA) - q

% 4. Estimarea modelului folosind armax
% Sintaxa: armax(data, [na nc])
model_arma = armax(data, [na nc])
% 6. Validare: Comparăm datele originale cu o predicție a modelului
figure;
compare(data, model_arma);

%%
clc
 % Calculating yAR_pred
yARMA = [ 1 2 3 4 ];
e_ARMA = [ 0 1 2 3];
AR_component = [ 1 -1 2 ];
MA_component = [ 1 -2 4];
theta_AR = [ 1 2 -3 ];
na = 2;
nc = 2;
nalpha = 2;
N = 9;
N_Training = 4;

yARMA(N_Training + 1:N) = zeros(5,1);
for i = 1:5
    % Calculating the AR part
    for k = 1:na
        yARMA(N_Training + i) = yARMA(N_Training + i) - AR_component(k + 1) * yARMA(N_Training + i - k);
    end

    % Calculating the MA part
    for k = 1:nc
        yARMA(N_Training + i) = yARMA(N_Training + i) + MA_component(k + 1) * e_ARMA(N_Training + i - k);
    end
             
    % Calculating the predicted noise
    e_ARMA(N_Training + i) = yARMA(N_Training + i);
     for k = 1:nalpha
         e_ARMA(N_Training + i) = e_ARMA(N_Training + i) + theta_AR(k + 1) * yARMA(N_Training + i - k);
     end
end
yARMA
e_ARMA





%%
%yst = repmat(1:3,1,10)' + repmat(1:2,1,15)' + [repmat(1:4,1,7)'; 1; 2]; 
y = [10.85 18.97 14.22 13.63 11.91 14.7 12.58 13.6 10.16 11.34 9.1...
	     6.14 5.99 9.29 6.15 5.16 4.07 2.91 3.93 2.38 2.65] ;
	y = [y 2.78 0.86 0.82 0.02 0.18 0.48 0.7 2.31 1.13 2.67 5.85 7.3...
	     11.07 12.91 15.53 16.5 17.52 18.72 25.38 20.25 19.6] ;
	y = [y 19.14 18.15 21.74 16.33 14.96 11.14 14.43 12.2 12.17 8.28...
	     5.79 6.14 7.02 3.72 3.87 4.64 2.18 3.95 1.98 2.93] ;
	y = [y 1.96 3.53 1.53 0.86 0.31 0.61 1.75 0.68 1.19 2.01 2.82 4.87...
	     5.67 5.72 11.09 6.95 9.15 8.82 12.18 8.12 9.61 10.71] ;
	y = [y 10.44 10.68 9.68 9.57 11.15 10.95 11.25 8.66 9.13 7.18 8.1...
	     5.17 6.15 6.32 7.65 6.13 4.34 5.77 2.31 3.07 2.76] ;
	y = [y 4.03 5.58 4.71 1.89 0.51 2.82 0.91 0.81 1.88 0.19 2.06 1.64...
	     1.29 3.14 4.38 5.19 9.97 7.04 12.51 16.66 10.16 15.9] ;
	y = [y 18.62 15.96 16.41 13.63 16.47 11.4 15.64 14.38 16.24 11.12...
	     12.2 10.61 9.47 8.43 8.07 8.22 5.58 5.7 6.97 3.74 1.2] ;
	y = [y 1.65 1.62 3.07 1.86 0.25 1.85 1.81 3.54 1.04 3.96 3.3 6.06...
	     5.9 8.8 11.38 12.51 16.13 13.06 12.69 15.85] ;

	y = 100*y ;

    N = length(y) ;

N_Training = N - 5;

[ ysta, yT, theta ] = trend(y(1:N_Training), 3); 

[y_pred, ysta_cop, theta_F, P] = seasonal(ysta);
L = length(P)
% Estimation of the last 5 terms - seasonal
    Phi_F = [];
    t_est = N_Training + 1:N;
    t_est = t_est';
    
    k = 1;
    for i = 1:2 * L
         if i <= L
            Phi_F = [ Phi_F sin(2*pi/P(i) * t_est)] ;
         elseif i > L && i <= 2*L
            Phi_F = [ Phi_F cos(2*pi/P(k) * t_est)] ;
            k = k + 1;
         end
    end
    
    % We draw the N-5 terms both estimated and the ones we took to verifythe data
    yS_est = y_pred;
    yS_est(N_Training + 1:N) = Phi_F * theta_F;
% norm(ysta - y_temp)
figure
plot(ysta)
hold on
% plot(y_pred)
hold on
 plot(yS_est)
% plot(yS_normal)
legend('Zgomot', 'Rezultat filtrare', 'Rezultat cu amplif', 'Rezultat fara filtrare');
%%
% 1. Generăm un semnal alb (zgomot) și îl trecem printr-un filtru cunoscut
rng('default');
n_samples = 1000;
real_coeffs = [1, -0.9, 0.4]; % Coeficienții reali pe care vrem să îi recuperăm
x = filter(1, real_coeffs, randn(n_samples, 1));

% 2. Calculăm autocorelația semnalului
r = xcorr(x, 2, 'biased'); % Calculăm autocorelația pentru lag-uri 0, 1, 2
r = r(3:end); % Reținem doar valorile de la lag 0 la 2

% 3. Aplicăm funcția Levinson
[a, e] = levinson(r, 2);

disp('Coeficienții estimați:');
disp(a);
%%
load V04.mat
v = V.y;
na = 2
nc = 2
nalpha = 34
N = length(v)
[yAR, e_AR, lambda2_AR, theta_AR, yARMA, e_ARMA, lambda2_ARMA, theta_ARMA ] = stochastic(v, na, nc, nalpha);

figure
plot(v)
hold on
plot(yARMA)
hold off
legend('V', 'yARMA')
%%
clc
p1 = [1 3 3 1];
p2 = [1 1];
k = 5;
p_rez = InfiniteDivisionPoly( p1, p2, k )

%%
clc
sigma = [ 1 2 3 4 5];
sigma2 = sigma .^ 2;
y_pred = [ 1 3 2 4 5];
y_al_meu = [ 1 10 15 6 21];
tub_incredere_sus = y_pred + 3 * sigma
tub_incredere_jos = y_pred - 3 * sigma
y_out = [];
y_in = [];
indice_out = [];
indice_in = [];
k = 1;
l = 1;

for i = 1:5
    if y_al_meu(i) > tub_incredere_sus(i) || y_al_meu(i) < tub_incredere_jos(i)
        y_out(k) = y_al_meu(i);
        k = k + 1;
        indice_out = [indice_out i];
    else
        y_in(l) = y_al_meu(i);
        l = l + 1;
        indice_in = [indice_in i];
    end
end
y_out
y_in
indice_out
indice_in
x_in = sum( (abs(y_pred(indice_in)) .^ 2 ) .* sigma2(indice_in) )
x_in = x_in / ( sum( abs(y_pred(indice_in)) .^ 2 ) * sum( sigma2(indice_in) ) )
x_out = sum( abs( y_pred(indice_out) ) ./ (3 * sigma(indice_out) ) )

%%
% Definim axele folosind valorile minime și maxime ale tale
x_lin = linspace(min(nc_axa(:,1)), max(nc_axa(:,1)), 36);
y_lin = linspace(min(na_axa(:,1)), max(na_axa(:,1)), 36);
[X, Y] = meshgrid(x_lin, y_lin);

% Interpolarea 'v4' creează cea mai fină suprafață
Z = griddata(nc_axa(:,1), na_axa(:,1), PQ_val(:,1), X, Y);

figure;
surf(X, Y, Z);
shading interp; % Netezește culorile
view(-30, 30);
colormap(jet);
colorbar;
grid on;
title('Signal Y01: Optimized Prediction Quality Surface');

%%

x = 1:10; y = [2.1, 3.9, 8.2, 16.5, 25.2, 36.1, 49.5, 64.2, 81.1, 100.3];
max_grad = 6;
errors = zeros(1, max_grad);

for n = 1:max_grad
    [p, S] = polyfit(x, y, n);
    errors(n) = S.normresid; % Eroarea de aproximare
end

plot(1:max_grad, errors, '-o');
xlabel('Gradul Polinomului'); ylabel('Eroarea (Norm Resid)');

%%
clc,clear
y=[3.83 3.76 4.28 4.01 3.99 4.11 3.83 3.88 ...
	   4.25 4.37 4.25 5.0  4.18 4.0 4.54 4.19 ...
	   4.12 4.37 3.69 3.89 4.0 4.23 3.96 4.84] ;
	y=[y 4.09 3.98 4.48 3.91 4.16 4.31 4.14 4.0 ...
	   3.96 4.55 4.25 4.73 4.43 4.23 4.68 4.54 ...
	   4.56 4.56 4.53 4.64 4.51 5.55 4.95 5.34] ;
	y=[y 5.47 5.60 5.43 6.04 5.19 5.46 5.44 4.57 ...
	   5.15 5.97 4.79 6.21 5.30 5.33 5.98 6.13 ...
	   5.50 5.77 5.87 5.21 5.82 6.11 5.73 7.02] ;
	y=[y 5.66 5.97 6.78 6.58 5.53 6.54 5.99 5.58 ...
	   6.18 6.16 6.17 7.39 6.34 6.38 7.26 6.49 ...
	   6.16 6.55 5.75 6.48 6.27 6.49 6.17 8.13] ;
	y=[y 6.53 6.63 6.65 6.48 6.77 6.24 6.46 6.33...
	   6.05 7.37 6.69 7.32 7.04 6.72 7.33 7.35...
	   7.08 6.55 7.14 6.37 6.78 7.78 6.89 8.64] ;
	y=[y 8.10 7.46 7.51 8.00 6.77 7.52 7.28 6.52 ...
	   7.40 8.07 6.61 8.19 7.20 7.03 7.33 7.80...
	   6.72 7.77 7.74] ;

   v = [  0.823751    0.674022    0.674293    0.574565    0.574836    0.775108    0.875379    0.875651    0.225922    0.076193   -0.023536   -0.223264   -0.322993   -0.372722   -0.522451   -0.672180   -0.771908   -0.671637   -0.421365   -0.471094   -0.670823   -0.720552   -0.820280   -0.920009   -0.869738   -0.869466   -0.919195   -0.968924   -1.018653   -0.668381   -0.418110   -0.267839   -0.517567   -0.467296   -0.317025   -0.266753   -0.216482   -0.116211   -0.115940   -0.165669   -0.065397    0.184874    0.335145    0.435416    0.385687    0.435959    0.286230    0.186501    0.336773    0.337044    0.237315    0.187587    0.237858    0.488129    0.638400    0.838672    0.838943    0.839214    0.589486    0.489757   -0.823751   -0.674023   -0.674293   -0.574566   -0.574836   -0.775108   -0.875379   -0.875651   -0.225922   -0.076193    0.023536    0.223264    0.322994    0.372722    0.522451    0.672180    0.771908    0.671637    0.421366    0.471095    0.670823    0.720551    0.820280    0.920009    0.869738    0.869467    0.919195    0.968924    1.018653    0.668381    0.418110    0.267839    0.517567    0.467296    0.317025    0.266754    0.216482    0.116211    0.115940    0.165669    0.065397   -0.184874   -0.335145   -0.435416   -0.385688   -0.435959   -0.286230   -0.186502   -0.336773   -0.337044   -0.237315   -0.187587   -0.237858   -0.488129   -0.638400   -0.838672   -0.838943   -0.839214   -0.589486   -0.489757   -2.003808   -1.754622   -1.455435   -1.356250   -1.057063   -1.057878   -1.258690   -1.059505   -0.810319   -0.861133   -0.661946   -0.262761   -0.363573   -0.214388    0.034798    0.283985    0.383171    0.582357    0.831543  ] ;



y_Det = y - v;
figure
hold on
plot(y)
plot(y_Det)
%%
[ ysta, yT, theta, lambda, p_new ] = trend(y, 2, 1) ;

% Outputs - trend
disp(['Coeficientii polinomului sunt: ' num2str(theta) ]);

% We calculate Fourier-Schuster Model
[yS, v, theta_F, P] = seasonal(ysta);

% We display the periods alongside the two values ai and bi for each Pi
if isequal(P, 0) == 0
   L = length(P);
   disp('Perioadele obtinute sunt: ');
   for i = 1:L
        disp([num2str(i)  ') ' num2str(P(i)) ' alaturi de coeficientii: a_i = ' num2str(theta_F(i)) ' si b_i = ' num2str(theta_F(i + L))]);
   end
end

% Deterministic Component
y_Determinist = yT + yS;
figure
hold on
plot(y_Determinist)
plot(y_Det)