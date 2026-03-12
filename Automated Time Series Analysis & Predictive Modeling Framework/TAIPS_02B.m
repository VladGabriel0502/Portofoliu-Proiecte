 % Reading the user s input for the tested time series - Same as TAIPS_01A
% for the moment
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

%% Prima strategie
% Extracting the number of samples
N = length(DATA.y) ;
N_Training = N - k ;

% Dividing the time series into training data and prediction data
y = DATA.y;
S_OM = DATA.y(1:N_Training); % time series on the horizon of measure
S_OE = DATA.y(N_Training+1:N); % time series on the extrapolation horizon

% Emphasizing the training data from S_OM
k_antrenament = round(k/2);
N_antrenament_2 = N_Training - k_antrenament;

S_OM_training = S_OM(1:N_antrenament_2);
S_OM_pred = S_OM(N_antrenament_2 + 1:N_Training);

EQ_val = [];
best_pol = bestPolyDeg(S_OM_training)
for p = 0:best_pol
    % Finding the best trend polynomial
    [ ysta, yT, theta, lambda, p_new ] = trend(S_OM_training', p, 1) ; % 1 ==  not dispaying info for p > 3

    % We calculate Fourier-Schuster Model
    [yS, v, theta_F, P] = seasonal(ysta);
    
    % Deterministic Component
    y_Determinist = yT + yS;

    % Estimation of the last 5 terms - trend
    Phi = [];
    for i = N_antrenament_2 + 1:N_Training
         for j = 1:p + 1
             Phi(i - N_antrenament_2,j) = i ^ ( j - 1 ) ;
         end
    end
    
    % We find the N-k terms both estimated and the ones we took to verify the data
    yT_est = Phi * theta';
    
    if isequal(P, 0) == 0
        % Estimation of the last 5 terms - seasonal
        L = length(P);
        Phi_F = [];
        t_est = N_antrenament_2 + 1:N_Training;
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
        
        % We find the N-k-k/2 terms both estimated and the ones we took to verify the data
        yS_est = Phi_F * theta_F;
        y_Determinist_est = yT_est + yS_est;
    else
        y_Determinist_est = yT_est;
        v = ysta;
    end

    % Transforming the vectors into iddata objects -> EQ function
    DATA_S_OM = iddata;
    DATA_S_OM.y = S_OM_training;

    DATA_S_OE = iddata;
    DATA_S_OE.y = S_OM_pred;

    DATA_DET_OM = iddata;
    DATA_DET_OM.y = y_Determinist;
  
    DATA_DET_OE = iddata;
    DATA_DET_OE.y = y_Determinist_est;

    [ EQ, SNR_N, SNR_k ] = extra_qual( DATA_S_OM, DATA_S_OE, DATA_DET_OM, DATA_DET_OE );
    EQ_val = [EQ_val EQ];
end

% Finding the top 3 optimum values for p 
[top, indici_sortare] = sort(EQ_val,'descend');
if best_pol >= 3
    EQ_top3 = top(1:3);
    p_o = 0:best_pol;
    p_o = p_o(indici_sortare); % sortam vectorul cu ordinele polinoamelor in functie de EQ_val
    p_o = p_o(1:3); % we choose the top 3 values for p
else
    p_o = 0:best_pol;
    p_o = p_o(indici_sortare); % sortam vectorul cu ordinele polinoamelor in functie de EQ_val
    p_o = p_o(1)
    p = p_o;
end

m = 4; % in order to enter in the while loop
while m > 3 && best_pol >= 3
    disp('Tastati ce grad de polinom doriti sa implementati pentru cele N-k date: ');
    disp(['1) Cel mai bun rezultat de la faza de antrenament - ' num2str(p_o(1))]);
    disp(['2) Al doilea cel mai bun rezultat - ' num2str(p_o(2))]);
    disp(['3) Al treilea cel mai bun rezultat - ' num2str(p_o(3))]);
    prompt = 'Alegerea dumneavoastra: ';
    m = input( prompt ) ;
    
    if m == 1
        p = p_o(1);
        disp('Ati ales prima optiune!');
    elseif m == 2
        p = p_o(2);
        disp('Ati ales a doua optiune!');
    elseif m == 3
        p = p_o(3);
        disp('Ati ales a treia optiune!');
    end
end

% Finding the best trend polynomial
[ ysta, yT, theta, lambda, p_new ] = trend(S_OM_training', p, 1) ; % 1 ==  not dispaying info for p > 3

% We calculate Fourier-Schuster Model
[yS, v, theta_F, P] = seasonal(ysta);
    
% Deterministic Component
y_Determinist = yT + yS;

% Estimation of the last 5 terms - trend
Phi = [];
for i = N_antrenament_2 + 1:N_Training
    for j = 1:p + 1
        Phi(i - N_antrenament_2,j) = i ^ ( j - 1 ) ;
    end
end
    
% We find the N-k terms both estimated and the ones we took to verify the data
yT_est = Phi * theta';
    
if isequal(P, 0) == 0
   % Estimation of the last terms - seasonal
   L = length(P);
   Phi_F = [];
   t_est = N_antrenament_2 + 1:N_Training;
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
        
    % We find the N-k-k/2 terms both estimated and the ones we took to verify the data
    yS_est = Phi_F * theta_F;
    y_Determinist_est = yT_est + yS_est;
else
    y_Determinist_est = yT_est;
    v = ysta;
end

N_max = ceil(N/3);
na = randperm(N_max + 1, 12) - 1; % genereaza o permutare random de 12 elemente cu valori intre 0 si ceil[N/3]

v_training = v(1:N_antrenament_2);
PQ_val = [];
for i = 1:12
    [yAR, e_AR, lambda2_AR, theta_AR, ~, ~, ~, ~ ] = stochastic(v_training, na(i));
     % Calculating yAR_pred
     nr = N_Training - N_antrenament_2;
     yAR(N_antrenament_2 + 1:N_Training) = zeros(nr,1);
     for j = 1:nr
         for l = 1:na(i)
             yAR(N_antrenament_2 + j) = yAR(N_antrenament_2 + j) - theta_AR(l + 1) * yAR(N_antrenament_2 + j - l);
         end
     end

     % We calculate also the standard deviation for the 5 predicted
     % values as in the course
     sigma2 = zeros(nr,1); % 6 so that we can use recursion with sigma2(1) = sigma2(0) = 0
     alpha_hat = InfiniteDivisionPoly(1, theta_AR, nr);
     for j = 2:nr + 1
         sigma2(j) = sigma2(j - 1) + lambda2_AR * alpha_hat(j - 1)^2;
     end
     sigma = sqrt(sigma2);

     % Calculating every value of PQ(na)
     Y_OM = iddata;
     Y_OM.y = y(1:N_antrenament_2);

     Y_OP = iddata;
     Y_OP.y = y(N_antrenament_2 + 1:N_Training);

     Y_complet_pred_OM = iddata;
     Y_complet_pred_OM.y = y_Determinist + yAR(1:N_antrenament_2);

     Y_complet_pred_OP = iddata;
     Y_complet_pred_OP.y = y_Determinist_est + yAR(N_antrenament_2 + 1:N_Training);
        
     [PQ, SNR_OM, SNR_OP, out_indice ] = pred_qual( Y_OM, Y_OP, Y_complet_pred_OM, Y_complet_pred_OP, sigma, nr );
     PQ_val = [PQ_val PQ];
end
[value, index] = max(PQ_val);
na_best = na(index);
p_best = p;


%% Grafice Strategie 1
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


%% Figura 1 - Media
% Time series graph with the mean value
t = 1:N;
y = DATA.y ;
avg = mean(y);

figure
plot(t, y, 'b', 'LineWidth', 1.2)   % blue line
hold on

% Red line for mean line
yline(avg, 'r', 'LineWidth', 2) % red line

% Adding text with the same colour as the mean line
text(t(end)*0.99, avg + 0.08 * avg, sprintf('Mean = %.2f', avg), ...
    'Color', 'r', 'FontWeight', 'bold', 'FontSize', 10)

hold off
% Graph details
xlabel([DATA.UserData ' with Sample time: ' num2str(DATA.Ts)])
ylabel(DATA.OutputUnit{1})
title(DATA.ExperimentName{1})
legend('Seria aleasa', 'Media seriei');

%% Figura 2
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

%% Figura 3
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


%% Figura 4
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

 %% Figura 5
% Time series graph over the extrapolation horizon
tub_incredere_sus = y_estimated(N_Training+1:N) + 3 * sigma(2:6);
tub_incredere_jos = y_estimated(N_Training+1:N) - 3 * sigma(2:6);
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

%% Figura 6
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


%% A doua strategie
clc
% Extracting the number of samples
N = length(DATA.y) ;
N_Training = N - k ;

% Dividing the time series into training data and prediction data
y = DATA.y;
S_OM = DATA.y(1:N_Training); % time series on the horizon of measure
S_OP = DATA.y(N_Training+1:N); % time series on the extrapolation horizon

% Emphasizing the training data from S_OM
k_antrenament = round(k/2);
N_antrenament_2 = N_Training - k_antrenament;


p = 0:3;
N_max = ceil(N/3);
na = randperm(N_max + 1, 36) - 1; % genereaza o permutare random de 12 elemente cu valori intre 0 si ceil[N/3]:5
na_axa = na;
matrix_p_na = [];
for i = 1:36
    matrix_p_na = [matrix_p_na ; p' repmat(na(i), 4, 1)]; % we associate every p with every na in order to find the best out of them
end

PQ_val = [];
out = [];
for i = 1:144
    p = matrix_p_na(i,1);
    % Finding the best trend polynomial
    [ ysta, yT, theta, lambda, p_new ] = trend(y(1:N_antrenament_2)', p, 1) ; % 1 ==  not dispaying info for p > 3
    
    % We calculate Fourier-Schuster Model
    [yS, v, theta_F, P] = seasonal(ysta);
        
    % Deterministic Component
    y_Determinist = yT + yS;
    
    % Estimation of the last 5 terms - trend
    Phi = [];
    for j = N_antrenament_2 + 1:N_Training
        for o = 1:p + 1
            Phi(j - N_antrenament_2,o) = j ^ ( o - 1 ) ;
        end
    end
        
    % We find the N-k terms both estimated and the ones we took to verify the data
    yT_est = Phi * theta';
        
    if isequal(P, 0) == 0
       % Estimation of the last terms - seasonal
       L = length(P);
       Phi_F = [];
       t_est = N_antrenament_2 + 1:N_Training;
       t_est = t_est';
            
       l = 1;
       for j = 1:2 * L
           if j <= L
               Phi_F = [ Phi_F sin(2*pi/P(j) * t_est)] ;
           elseif j > L && j <= 2*L
               Phi_F = [ Phi_F cos(2*pi/P(l) * t_est)] ;
               l = l + 1;
           end
        end
            
        % We find the N-k-k/2 terms both estimated and the ones we took to verify the data
        yS_est = Phi_F * theta_F;
        y_Determinist_est = yT_est + yS_est;
    else
        y_Determinist_est = yT_est;
        v = ysta;
    end
    
    na = matrix_p_na(i, 2);
    v_training = v(1:N_antrenament_2);
    [yAR, e_AR, lambda2_AR, theta_AR, ~, ~, ~, ~ ] = stochastic(v_training, na);
     % Calculating yAR_pred
     nr = N_Training - N_antrenament_2;
     yAR(N_antrenament_2 + 1:N_Training) = zeros(nr,1);
     for j = 1:nr
         for l = 1:na
             yAR(N_antrenament_2 + j) = yAR(N_antrenament_2 + j) - theta_AR(l + 1) * yAR(N_antrenament_2 + j - l);
         end
     end

     % We also calculate AR part
     sigma2 = zeros(nr,1); % 6 so that we can use recursion with sigma2(1) = sigma2(0) = 0
     alpha_hat = InfiniteDivisionPoly(1, theta_AR, nr);
     for j = 2:nr + 1
         sigma2(j) = sigma2(j - 1) + lambda2_AR * alpha_hat(j - 1)^2;
     end
     sigma = sqrt(sigma2);

     % Calculating every value of PQ(na)
     Y_OM = iddata;
     Y_OM.y = y(1:N_antrenament_2);

     Y_OP = iddata;
     Y_OP.y = y(N_antrenament_2 + 1:N_Training);

     Y_complet_pred_OM = iddata;
     Y_complet_pred_OM.y = y_Determinist + yAR(1:N_antrenament_2);

     Y_complet_pred_OP = iddata;
     Y_complet_pred_OP.y = y_Determinist_est + yAR(N_antrenament_2 + 1:N_Training);
        
     [PQ, SNR_OM, SNR_OP, out_indice ] = pred_qual( Y_OM, Y_OP, Y_complet_pred_OM, Y_complet_pred_OP, sigma, nr );
     PQ_val = [PQ_val PQ];
     out = [out out_indice];
end
matrix = [matrix_p_na PQ_val' out']
[value, index] = max(PQ_val);
na_best = matrix_p_na(index, 2);
p_best = matrix_p_na(index, 1);

%% Grafice Strategie 2
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

%% Figura 1 - Media
% Time series graph with the mean value
t = 1:N;
y = DATA.y ;
avg = mean(y);
 
figure
plot(t, y, 'b', 'LineWidth', 1.2)   % blue line
hold on

% Red line for mean line
yline(avg, 'r', 'LineWidth', 2) % red line

% Adding text with the same colour as the mean line
text(t(end)*0.9, avg + 0.08 * avg, sprintf('Mean = %.2f', avg), ...
    'Color', 'r', 'FontWeight', 'bold', 'FontSize', 10)

hold off
% Graph details
xlabel([DATA.UserData ' with Sample time: ' num2str(DATA.Ts)])
ylabel(DATA.OutputUnit{1})
title(DATA.ExperimentName{1})
legend('Seria aleasa', 'Media seriei');

%% Figura 2 - Suprafata celor 144 de valori
% We extract the name of the time serie
if n < 10
    name = ['Y0' num2str(n)];
else
    name = ['Y' num2str(n)];
end
na_axa = sort(na_axa)
p_axa = matrix_p_na(1:6,1)'
Z = reshape(PQ_val, 6 , 24);
% După ce ai calculat PQ_val și ai făcut reshape
h = surf(p_axa, na_axa, Z'); 

% Stilul pentru aspect "grunjos"/detaliat
shading interp;       % Netezește culorile pe fețe
view(-30, 30);        % Ajustează unghiul de vizualizare 3D
colormap(jet(256));   % Folosește paleta de culori Jet (albastru -> roșu)
colorbar;

% Adaugă linii de grid pronunțate
grid on;
set(gca, 'GridColor', [0.5 0.5 0.5], 'GridAlpha', 0.8);

% Opțional: adaugă un contur (mesh) deasupra pentru a accentua forma
hold on;
mesh(p_axa, na_axa, Z', 'EdgeColor', [0 0 0], 'FaceAlpha', 0);

% Personalizare axe
title(['Signal ' name ': Prediction Quality surface']);
xlabel('Parametrul p (0:5)');
ylabel('Parametrul na (24 valori)');
zlabel( 'Valoare PQ');
grid on; % Asigură-te că grila de fundal e activă

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
tub_incredere_sus = y_estimated(N_Training+1:N) + 3 * sigma(2:6);
tub_incredere_jos = y_estimated(N_Training+1:N) - 3 * sigma(2:6);
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
