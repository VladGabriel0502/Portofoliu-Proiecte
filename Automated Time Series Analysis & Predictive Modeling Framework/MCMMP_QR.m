function [theta, lambda] = MCMMP_QR( y, nTheta )
    % QR Decomposition off-line
    Phi = [];
    for i = 1:nTheta + 1
        for j = 1:nTheta + 1
            Phi(i,j) = i ^ ( j - 1 ) ;
        end
    end
    % Q = eye(nTheta + 1) ;
    y_nt = y(1:nTheta + 1)' ; 
    for i = 2:nTheta + 1
        for j = 1:i-1
                G = eye(nTheta + 1); % We build all the Givens operators acording to the information from the course
                Fact = 1/sqrt(Phi(i,j)^2 + Phi(j,j)^2);
                G(j,j) = Fact * Phi(j,j) ;
                G(i,j) = -Fact * Phi(i,j) ;
                G(j,i) = -G(i,j) ;
                G(i,i) = G(j,j) ;
                Phi =  G * Phi; % -> new Phi
                y_nt = G * y_nt ;
                %Q = G * Q; % the Q matrix that will be used further in the recursion
        end
    end
    
    theta = Exfoliere( Phi, y_nt ) ; % theta that will be used in the next part of the algorithm
    lambda = 0 ;
    r_1 = [];
    r_2 = [];
    [~, N] = size(y); % The number of samples

    % QR Decomposition on-line
    for k = nTheta + 2:N
        % Extension of Phi matrix and y vector
        for j = 1:nTheta + 1
            Phi(k,j) = k ^ ( j - 1 ) ; % Doesn't work to do this at the same time with G_k_j
            % We can't update Phi in G_k_j * Phi
        end
        y_nt = [ y_nt; y(k) ] ;

        for j = 1:nTheta + 1
            % We calculate the correspinding G_k_j 
            G_k_j = eye(k) ;
            Fact = 1/sqrt(Phi(k,j)^2 + Phi(j,j)^2);
            G_k_j(j,j) = Fact * Phi(j,j) ;
            G_k_j(k,j) = -Fact * Phi(k,j) ;
            G_k_j(j,k) = -G_k_j(k,j) ;
            G_k_j(k,k) = G_k_j(j,j) ;
            Phi =  G_k_j * Phi ; % -> new Phi
            y_nt = G_k_j * y_nt ; % We update [ r_1_k ; r_2_k ] <- Qk * Yk
        end
        R = Phi(1:nTheta + 1,1:nTheta + 1) ; % R dimensions = (nTheta + 1) * (nTheta + 1)
        r_1 = y_nt(1:nTheta + 1) ;% r1 - first nTheta + 1 terms
        r_2 = y_nt(nTheta + 2:k) ; % rest of y_nt terms
        theta = Exfoliere( R, r_1 ) ; % as it is presented in course
        lambda = 1/(k - nTheta - 1) * norm(r_2) ^ 2 ;
    end
end