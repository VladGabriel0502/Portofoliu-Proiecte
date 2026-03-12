function F = Functia_Fitness_AM_Noua( x, theta_NARX, theta_ARMA, Y_ref, Y_ini, U_ini, Ts ) % F - similar cu ce se gaseste in lucrarea de dizertatie Alex Molete (AM)
    miu = 200 ;
    % Variabila noastra care reprezinta componentele PID - ului optimal - x
    Kp = reshape( x(1:4), [2, 2] ) ;
    Ti = reshape( x(5:8), [2, 2] ) ;
    Td = reshape( x(9:12), [2, 2] ) ;
    Nd = 10 * ones(2,2) ;
    
    PID_C.Kp = Kp ;
    PID_C.Ti = Ti ;
    PID_C.Td = Td ;
    PID_C.Nd = Nd ;

    % Aflare y1, y2, y1_ref, y2_ref, u1, u2, u1_ref si u2_ref pentru calcul
    % Functie Fitness
    [y1, y2, u1, u2, ~, ~] = Simulate_PID_NARX_ARMA(theta_NARX,theta_ARMA,PID_C,Y_ref,Y_ini,U_ini,Ts) ;

    if any(abs(y1) > 1000) || any(abs(y2) > 1000) || isnan(any(y1)) || isnan(any(y2))
       % disp(['Una din iesiri a depasit 1000! la iteratia ', num2str(i)]) ;
        F = 0; % penalizare hard
        return;
    end

    y1_ref = Y_ref(1,1) ;
    y2_ref = Y_ref(1,2) ;
    % u1_ref = U_ini(1) ;
    % u2_ref = U_ini(2) ;
    
    N = size(y1,1) ; % Numarul de esantioane ~ N_y1 = N_y2

    % Mai intati vom gasi timpul tranzitoriu pentru a putea separa f_y_2 de
    % f_y_inf:

    dw = 0 ;% Pentru a afisa erorile in caz ca exista
    [t_t_1, ~, ~ ] = detect_transient_time( y1, y1_ref, dw )  ;% Nr1 = t_t_1
    [t_t_2, ~, ~ ] = detect_transient_time( y2, y2_ref, dw )  ;% Nr2 = t_t_2  ~ Timpii tranzitorii
    
    % Verificare dacă timpul tranzitoriu este NaN
    if isnan(t_t_1) || isnan(t_t_2)
        F = 0;
        return;
    end
   
    e_t_1 = ( y1(1:t_t_1) - y1_ref );
    e_t_2 = ( y2(1:t_t_2) - y2_ref );
    e_t = [ e_t_1; e_t_2 ] ;

    % Definitie f_y_2
    f_y_2 = norm(e_t) ;

    % Acum aflu e_st corespunzator cu restul semnalului si folosit in f_y_inf

    e_st_1 = ( y1(t_t_1 + 1:N) - y1_ref ) ;
    e_st_2 = ( y2(t_t_2 + 1:N) - y2_ref ) ;
    %e_st = [ e_st_1; e_st_2 ] ;
    
    % Verificăm dacă avem elemente rămase după tranzitoriu
    if t_t_1 + 1 > N || t_t_2 + 1 > N
        F = 0; % soluție inacceptabilă, nu avem steady-state
        return;
    end
    
    % Definitie f_y_inf
    f_y_inf = max( max(abs(e_st_1)), max(abs(e_st_2)) ) ;
    %f_y_inf = norm(e_st) ;

    % Definitie F_y
    s2 = t_t_1 + t_t_2 ;
    s_inf = 2 * N  - t_t_1 - t_t_2 ;
    sigma_2 = 1 / s2 ;
    sigma_inf = 1 / s_inf ;

    F_y = ( 50 / N ) * ( s2 / ( 1 + miu * sigma_2 * f_y_2 ) + s_inf / ( 1 + miu * sigma_inf * f_y_inf) ) ;

    
    % Analog pentru partea cu u
    
    u_t_1 = u1(1:t_t_1) ;
    u_t_2 = u2(1:t_t_2) ;
    u = [ u_t_1; u_t_2 ] ;

    % Definitie f_u_2
    f_u_2 = norm(u) ;

    e_st_u1 = ( u1(t_t_1 + 1:N) - mean(u1(t_t_1 + 1:N)) ) ;
    e_st_u2 = ( u2(t_t_2 + 1:N) - mean(u2(t_t_2 + 1:N)) ) ;
    e_st_u = [ e_st_u1; e_st_u2 ] ;

    % Definitie f_u_inf
%     f_u_inf =  max( max(abs(e_st_u1)), max(abs(e_st_u2)) ) 
    f_u_inf = norm(e_st_u) ;

    % Definitie F_u
    F_u = ( 50 / N ) * ( s2 / ( 1 + miu * sigma_2 * f_u_2 ) + s_inf / ( 1 + miu * sigma_inf * f_u_inf) ) ;

    F = ( F_y + F_u ) / 2 ;

end