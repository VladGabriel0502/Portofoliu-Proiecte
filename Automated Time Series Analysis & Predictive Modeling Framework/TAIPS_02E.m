 % Reading the user s input for the tested time series - Same as TAIPS_01A
% for the moment PAR optimal
clc, clear
prompt = 'Tastati numarul seriei de timp pe care doriti sa o testati: ';
n = input( prompt ) ;

if n >= 1 && n <= 15
    DATA = TS2DATA(n) ;
elseif n >= 16 && n <= 20
    [DATA1, DATA2] = TS2DATA_2(n) ;
    disp(['Ce serie de timp din cele doua continute in fisierul Y' num2str(n) ' doriti sa vizualizati? ']);
    disp(['1) ' DATA1.ExperimentName{1} ]);
    disp(['2) ' DATA2.ExperimentName{1} ]);
    prompt = 'Alegerea dumneavoastra: ' ;
    choice = input(prompt) ;
    if choice == 1
        DATA = DATA1;
        clear DATA1 ;
        clear DATA2 ;
    elseif choice == 2
        DATA = DATA2;
        clear DATA1 ;
        clear DATA2 ;
    else
        disp('Nu ati ales o optiune valida!');
    end
else disp('Numarul ales nu corespunde cu nicio serie de timp!');
end

prompt = 'Tastati durata orizontului de extrapolare: ';
k = input( prompt ) ;
if isempty(k) || k > 7
    k = 5;
end

%% A treia strategie - optimizare GWO
clc
% Extracting the number of samples
N = length(DATA.y) ;
N_Training = N - k ;

% Dividing the time series into training data and prediction data
y = DATA.y;
y_om = DATA.y(1:N_Training); % time series on the horizon of measure
y_op = DATA.y(N_Training + 1:N); % time series on the extrapolation horizon

% Emphasizing the training data from S_OM
k_antrenament = round(k/2);
N_antrenament_2 = N_Training - k_antrenament;

y_training_om = DATA.y(1:N_antrenament_2); % time series on the horizon of measure
y_training_op = DATA.y(N_antrenament_2 + 1:N_Training); % time series on the extrapolation horizon

%%
N_max = floor(N_antrenament_2/3) + 1;
PQ_best = -inf;
p_best = -inf;
na_best = -inf;
p_max = bestPolyDeg(y_training_om)
for p = 0:p_max
    for na = 0:N_max
        PQ = obj_func_pred_AR( p, na, y_training_om, y_training_op );
        if PQ > PQ_best
            PQ_best = PQ;
            p_best = p;
            na_best = na;
        end
    end
end
p_best
na_best
%% Grafice Strategie 2 -PAR
% We display the coefficients of best polynomial and the Schuster
% Coefficients
% Outputs - trend
clc
% Finding the best trend polynomial
y = DATA.y;
[ ysta, yT, theta, lambda, p_new ] = trend(y(1:N_Training)', p_best, 1) ;

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

% Estimation of the last 5 terms - trend
Phi = [];
for i = N_Training + 1:N
    for j = 1:p_best + 1
        Phi(i - N_Training,j) = i ^ ( j - 1 ) ;
    end
end
    
% We find the N-k terms both estimated and the ones we took to verify the data
yT_est = Phi * theta';
    
if isequal(P, 0) == 0
    % Estimation of the last 5 terms - seasonal
    L = length(P);
    Phi_F = [];
    t_est = N_Training + 1:N;
    t_est = t_est';
        
    l = 1;
    for i = 1:2 * L
        if i <= L
           Phi_F = [ Phi_F sin(2*pi/P(i) * t_est)] ;
        elseif i > L && i <= 2*L
           Phi_F = [ Phi_F cos(2*pi/P(l) * t_est)] ;
           l = l + 1;
        end
    end
        
    % We find the N-5 terms both estimated and the ones we took to verify the data
    yS_est = Phi_F * theta_F;
    y_Determinist_est = yT_est + yS_est;
else
    y_Determinist_est = yT_est;
    v = ysta;
end

%% Figura 3
% Time series graph with the trend polynomial curve + seasonal component
t = 1:N;
y = DATA.y ;
figure
plot(t, y, 'b', 'LineWidth', 1.1);   % blue line
hold on

y_estimated = y_Determinist;
y_estimated(N_Training + 1: N) = y_Determinist_est;

plot(t, y_estimated, 'r', 'LineWidth', 1.5) % red line

xline(t(N_Training + 1),'--', 'Color' ,'m', 'LineWidth', 1.5); % separation line

% Graph details
xlabel([DATA.UserData ' with Sample time: ' num2str(DATA.Ts)]) ;
ylabel(DATA.OutputUnit{1}) ;
title(DATA.ExperimentName{1}) ;
legend('Seria aleasa', 'Seria estimata', 'Linie de separare');

hold off

%% Figura 4
% Time series graph with the trend polynomial curve + seasonal component
t = 1:N;
y = DATA.y ;
figure
plot(t, y, 'b', 'LineWidth', 1.1);   % blue line
hold on

v_om = v(1:N_Training);
[yAR, e_AR, lambda2_AR, theta_AR, ~, ~, ~, ~ ] = stochastic(v_om, na_best);
% Calculating yAR_pred
yAR(N_Training + 1:N) = zeros(k,1);
for i = 1:k
    for l = 1:na_best
        yAR(N_Training + i) = yAR(N_Training + i) - theta_AR(l + 1) * yAR(N_Training + i - l);
    end
end

% We calculate also the standard deviation for the 5 predicted
% values as in the course
sigma2 = zeros(k,1); % 6 so that we can use recursion with sigma2(1) = sigma2(0) = 0
alpha_hat = InfiniteDivisionPoly(1, theta_AR, k);
for i = 2:k + 1
    sigma2(i) = sigma2(i - 1) + lambda2_AR * alpha_hat(i - 1)^2;
end
sigma = sqrt(sigma2);

y_estimated = y_Determinist;
y_estimated(N_Training + 1: N) = y_Determinist_est;
y_estimated = y_estimated + yAR;

% Calculating every value of PQ(na)
Y_OM = iddata;
Y_OM.y = y(1:N_Training);

Y_OP = iddata;
Y_OP.y = y(N_Training + 1:N);

Y_complet_pred_OM = iddata;
Y_complet_pred_OM.y = y_estimated(1:N_Training);

Y_complet_pred_OP = iddata;
Y_complet_pred_OP.y = y_estimated(N_Training + 1:N);

[PQ, SNR_OM, SNR_OP, out_indice ] = pred_qual( Y_OM, Y_OP, Y_complet_pred_OM, Y_complet_pred_OP, sigma, k );

plot(t, y_estimated, 'r', 'LineWidth', 1.5) % red line

xline(t(N_Training + 1),'--', 'Color' ,'m', 'LineWidth', 1.5); % separation line

% Graph details
xlabel([DATA.UserData ' with Sample time: ' num2str(DATA.Ts)]) ;
ylabel(DATA.OutputUnit{1}) ;
title(DATA.ExperimentName{1}) ;
legend('Seria aleasa', 'Seria estimata', 'Linie de separare');

hold off

%% Figura 5
% Error graph resulted from y - yT - yS - yAR -> e
t1 = 1:N_Training;
e_om = y(t1) - y_estimated(t1);
figure
plot(t1, e_om, 'b', 'LineWidth', 1.2)   % blue line

% SNR
mean_y_om = mean(y(t1));
sigma_y_N = sqrt( 1/N_Training * (norm(y(t1) - mean_y_om) ^ 2));
lambda2_e = 1/N_Training * (norm(e_om) ^ 2);
SNR = sigma_y_N/sqrt(lambda2_e);

% Graph details
xlabel([DATA.UserData ' with Sample time: ' num2str(DATA.Ts)]) ;
ylabel('\nu_p = y - y_{T,p} - y_{S,p} - y_{AR}') ;
title({['Model error on the measurement horizon with  \lambda^{2}_{\nu_p} = ' num2str(lambda2_e)], ...
       ['and SNR_{N-5}[p] = ' num2str(SNR)]});

 %% Figura 6
% Time series graph over the extrapolation horizon
tub_incredere_sus = y_estimated(N_Training+1:N) + 3 * sigma(2:k+1);
tub_incredere_jos = y_estimated(N_Training+1:N) - 3 * sigma(2:k+1);
figure
graph1 = plot(t(N_Training+1:N), y(N_Training+1:N), 'b', 'LineWidth', 1.2 ) ;
hold on
graph2 = plot(t(N_Training+1:N), y_estimated(N_Training+1:N), 'r', 'LineWidth', 1.4); % same line as before
        
plot(t(N_Training + 1:N), y(N_Training + 1:N), '*', ...
'Color',[1 0.5 0], 'MarkerSize',8,'LineWidth',1.2); % we highlight the last N - 5 terms
        
plot( t(N_Training + 1:N), y_estimated(N_Training + 1:N), 'o', ...
'Color','g', 'MarkerSize', 8, 'LineWidth', 1.2 ); % we highlight the last N - 5 estimated terms
        
graph3 = plot(t(N_Training+1:N), tub_incredere_sus, 'Color', [0 0.5 0], 'LineWidth', 1.1); % same line as before
plot(t(N_Training+1:N), tub_incredere_jos, 'Color', [0 0.5 0], 'LineWidth', 1.1) % same line as before
xlim([ N_Training N+1])
ylim([min(tub_incredere_jos)-1 max(tub_incredere_sus)+1])
grid on
hold off

% Graph details
xlabel([DATA.UserData ' with Sample time: ' num2str(DATA.Ts)]) ;
ylabel(DATA.OutputUnit{1}) ;
title(['Seria de timp pe orizontul de predictie vs Valori predictate cu PQ = ' num2str(PQ)]);
legend([graph1 graph2 graph3], {'Seria continuata', 'Seria extrapolata','Tub de incredere'});

%% Figura 7
% Error graph resulted from v - yAR -> e

t1 = N_Training + 1:N;
e_pred = y(N_Training+1:N) - y_estimated(N_Training+1:N);
lambda2_e_pred = 1/k* norm(e_pred) ^ 2;
figure
plot(t1, e_pred, 'b', 'LineWidth', 1.2)   % blue line
        
% SNR
mean_y_pred = mean(y(N_Training+1:N));
sigma_y_N = sqrt( 1/k * (norm(y(N_Training+1:N) - mean_y_pred) ^ 2));
SNR = sigma_y_N/sqrt(lambda2_e_pred);
        
% Graph details
xlabel([DATA.UserData ' with Sample time: ' num2str(DATA.Ts)]) ;
ylabel(' e_{pred} = y - y_{T,p} - y_{S,p} - y_{ARpred}') ;
title({['Model error on the prediction horizon with  \lambda^{2}_{nabest} = ' num2str(lambda2_e_pred)], ...
['and SNR_{N-5}[' num2str(na_best) '] = ' num2str(SNR)]});