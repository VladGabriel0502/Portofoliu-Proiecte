%
%	File Exfoliere.m
%
%	Function: Exfoliere
%
%	Synopsis: x = Exfoliere( A, r ) ; 
%
%	Returns the x vector from A * x = r , where A is an n by n superior triungular matrix and r
%	is an n by 1 vector x = A^-1 * r 

%	Author:  Grigore Vlad-Gabriel
%	Created: October    17, 2025
%	Revised: October 24, 2025


function x = Exfoliere( A, r )
    [~, n] = size(A) ;
    for i = n:-1:1
        x(i) = r(i) ;
        for j = n:-1:i + 1
            x(i) = x(i) - A(i,j) * x(j);
        end
        x(i) = x(i) / A(i, i);
    end
end