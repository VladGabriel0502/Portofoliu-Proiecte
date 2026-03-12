%% Strategie Cautare %%
% ~~~~~~~~~~~~~~~~~~~~~

% Pasul 1 + 2 + 3 ~ Alegerea referintelor %
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
clc,clear
load Static_map_ASTANK2.mat

static_map = Static_ASTANK2;
y1s = 9;
y2s = 10;
[u1s,u2s,y1sr,y2sr] = static_u(static_map,y1s,y2s);

% Alegerea referintelor
% ~~~~~~~~~~~~~~~~~~~~~
y1_ini = y1sr - 2;
y2_ini = y2sr - 3;
% Pregatim datele pentru rularea in GWO
[theta_NARX,theta_ARMA] = extract_NARX_ARMA_model( '2_MISO_NARX_[85.21].mat' ) ;
Y_ref = [ repmat(y1sr, 300, 1) repmat(y2sr, 300, 1) ] ;
Y_ini = [ y1_ini y2_ini ] ;
U_ini = [ u1s u2s ] ;
Ts = 1;
%%
% Pasul 4 ~ Configurare GWO 
% ~~~~~~~~~~~~~~~~~~~~~~~~~ 

dim = 12 ; % Doar Kp prima oara
lb = [ repmat( 0, 4, 1) ; repmat(0.28, 4, 1); repmat( 0, 4, 1)]' ;  
ub = [ repmat( 0.0001, 4, 1) ; repmat(1.85, 4, 1); repmat( 0 , 4, 1) ]' ; 
SearchAgents_no = 30 ; % Standard
Max_iter = 8000  ; % Preluat din functia main ce a venit la pachet cu algoritmul
[Best_score ,Best_pos] = GWO_PID_Update(SearchAgents_no, Max_iter, lb, ub, dim, theta_NARX, theta_ARMA, Y_ref, Y_ini, U_ini, Ts)
disp(['The best score is ' num2str(Best_score)]) ;

%Kp = reshape( Best_pos(1:4), [2, 2] ) 
%Ti = reshape( Best_pos(5:8), [2, 2] )  
%Td = reshape( Best_pos(9:12), [2, 2] ) 
fitness = Functia_Fitness_AM( Best_pos, theta_NARX, theta_ARMA, Y_ref, Y_ini, U_ini, Ts )

%% Grafice y1 si y2 alaturi de referinte
Kp = reshape( Best_pos(1:4), [2, 2] ) 
Ti = reshape( Best_pos(5:8), [2, 2] ) 
Td = reshape( Best_pos(9:12), [2, 2] )  
Nd = 10 * ones(2,2) ;

  Best_of_the_best = Best_pos
  save 'Best_of_the_best' Best_of_the_best

y1_ref = Y_ref(:,1);
y2_ref = Y_ref(:,2);
u1_ref = repmat( U_ini(1), 1, 300) ;
u2_ref = repmat( U_ini(2), 1, 300); 

PID_C.Kp = Kp ; 
PID_C.Ti = Ti ; 
PID_C.Td = Td ;
PID_C.Nd = Nd ;

% Vedem cum merge Sim pentru aceleasi rezultate
[y1, y2, u1, u2, u1r u2r] = Simulate_PID_NARX_ARMA(theta_NARX,theta_ARMA,PID_C,Y_ref,Y_ini,U_ini,Ts) ;
[y11,~,~,~,~,~] = Simulate_PID_NARX_ARMA(theta_NARX,theta_ARMA,PID_C,Y_ref,Y_ini,U_ini,Ts) ;
if ~isequal(y1, y11) 
    disp('Rezultate diferite!');
end
 
 
% while fitness <= 90
%    fitness = Functia_Fitness_AM( Best_pos, theta_NARX, theta_ARMA, Y_ref, Y_ini, U_ini, Ts )
% end

timp = 0:299;
timp = timp * Ts;
Figuri_Comenzi_Iesiri(y1, y1_ref, y2, y2_ref, u1, u1_ref, u2, u2_ref, timp)
%% Test semnal T1
load Test1.mat
T1 = functie_Fitness_Test(y1, Y1s, y2, Y2s, u1, U1s, u2, U2s )

% timp = 0:1999 ;
% timp = timp';
% Y1s = repmat( Y1s, 2000, 1 ) ;
% Y2s = repmat( Y2s, 2000, 1 ) ;
% U1s = repmat( U1s, 2000, 1 ) ;
% U2s = repmat( U2s, 2000, 1 ) ;
% Figuri_Comenzi_Iesiri(y1, Y1s, y2, Y2s, u1, U1s, u2, U2s, timp)
%% Test Semnal T2
load Test2.mat
T2 = functie_Fitness_Test(y1, Y1s, y2, Y2s, u1, U1s, u2, U2s )

