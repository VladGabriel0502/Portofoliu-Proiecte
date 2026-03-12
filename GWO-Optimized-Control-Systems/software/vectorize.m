%
%	File VECTORIZE.M
%
%	Function: VECTORIZE
%
%	Synopsis: v = vectorize(A) ; 
%
%	Vectorizes the array A, by reshaping into a row vector v, regardless the number of dimensions.
% 
%	If A is a column vector, v is A transposed.
%
%	If A is a matrix, the columns are transposed and enumerated 
%	successively within the row vector. 
%
%	If A is a N-dimensional array, then it consists of matrices stored in order of the other (N-2) dimensions. 
%	For example, A = ones(2,3,4) has four 2-b-3 matrices put on layers (or in a queue): A(:,:,1), followed 
%	by A(:,:,2), then by A(:,:,3), while A(:,:,4) is the last one in queue. In this case, all matrices are read 
%	on columns and matrices succeed according to the queue. All columns are concatenated intyo a vector and then 
%	transposed.
%
%	The output is empty if something is wrong. 
%
%	Uses:	 WAR_ERR
%
%	Author:  Dan STEFANOIU
%	Created: April 19, 2025
%	Revised: 
%

function  v = vectorize(A)

%
% BEGIN
%
% Messages 
% ~~~~~~~~
	FN  = '<VECTORIZE>: ' ; 
	E1  = [FN 'Missing input. Empty output. Exit.'] ; 
%
% Faults preventing 
% ~~~~~~~~~~~~~~~~~
	v = [] ; 
	if (nargin < 1)
	   war_err(E1) ; 
	   return ; 
	end ; 
%
% Vectorizing 
% ~~~~~~~~~~~
	v = size(A) ; 
	if ((length(v)>2) || ((v(1)>1) && (v(2)>1))) 
	   v = reshape(A,1,prod(v)) ; 
	elseif (v(1)>1)
	   v = A.' ; 
	else
	   v = A ;
	end ; 
%
% END 
%

