function p_rez = InfiniteDivisionPoly( p1, p2, k )
    % We find the first k + 1 terms of the calculated polynomial
    r = p1; % remainder polynomial
    p2_help = p2;
    l1 = length(p1);
    l2 = length(p2);
    if l1 == l2 && l1 == 1
        p_rez = zeros(1,k + 1);
        p_rez(1) = p1/p2;
    else
        for i = 1:k + 1
            % We calculate every coefficient
            p_rez(i) = r(i)/p2(1);
    
            % We need to extrapolate p2 in another vector for calculating new r
            p2_help = p2;
            if length(p1) <= length(p2) % if order of A is greater than the order of C
                for j = 1: i - 1
                    p2_help = [0 p2_help];
                end
                
                while length(r) < length(p2_help)
                    r = [r 0];
                end
            else
                while length(p2_help) < length(p1) % if order of C > order of A
                    p2_help = [p2_help 0];
                end
    
                for j = 1: i - 1
                    p2_help = [0 p2_help];
                end
                
                while length(r) < length(p2_help)
                    r = [r 0];
                end
            end
            r = r - p_rez(i) * p2_help;
            
        end
    end
end