%
%	File LS_STATIC_PLANES_ASTANK2.M
%
%	Function: LS_STATIC_PLANES_ASTANK2
%
%	Call: [theta1,theta2,lambda12,lambda22] = LS_static_planes_ASTANK2(static_map) ;
%
%	Identifies the two planes corresponding to static map of ASTANK2 installation, 
%	by means of Least Squares Method.
%
%	Input argument: static_map, a structure with the fields:
%	  . U1 = static control input on channel 1 (column vector);
%	  . U2 = static control input on channel 1 (column vector);
%	  . Y1 = static level on tank 1 (matrix);
%	  . Y1 = static level on tank 2 (matrix).
%
%	Output arguments:
%	  . theta1 = plane parameters for level on tank 1 (vector: [a1 b1 c1]);
%	  . theta2 = plane parameters for level on tank 2 (vector: [a2 b2 c2]);
%	  . lambda12 = variance of model error on tank 1 (scalar);
%	  . lambda22 = variance of model error on tank 2 (scalar).
%
%	Any of the two planes has the equation: 
%
%	                        y = a*U1 + b*U2 + c.
%
%	If the static map is missing or empty, the outputs are empty. 
%
%	Uses:	 WAR_ERR 
%
%	Author:	 Dan STEFANOIU
%	Created: April 24, 2025
%	Revised: 
%

function [theta1,theta2,lambda12,lambda22] = LS_static_planes_ASTANK2(static_map)

%
% BEGIN
%
% Constants & Messages 
% ~~~~~~~~~~~~~~~~~~~~
	FN = '<LS_STATIC_PLANES_ASTANK2>: ' ;
	E = [FN 'Missing, empty or inconsistent static map => empty outputs. Exit.'] ; 
%
% Partial faults preventing (structure of static_map not tested)
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	[theta1,theta2] = deal([]) ; 
	[lambda12,lambda22] = deal([]) ; 
	if (nargin<1)
	   war_err(E) ;
	   return ;
	end ; 
%
% Preliminaries
% ~~~~~~~~~~~~~
	U1 = static_map.U1 ; 
	N1 = length(U1) ; 
	U2 = static_map.U2 ; 
	N2 = length(U2) ; 
	R = [U1'*U1/N1 mean(U1)*mean(U2) mean(U1) U2'*U2/N2 mean(U2)] ;
	R = [R(1:3) ; [R(2) R(4:5)] ; [R(3) R(5) 1]] ;
%
% Identification of first plane
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Y1 = static_map.Y1 ;
	r = [mean(Y1')*U1/N1 ; mean(Y1)*U2/N2 ; mean(Y1(:))] ;
	theta1 = R\r ;
%
% Identification of second plane
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Y2 = static_map.Y2 ;
	r = [mean(Y2')*U1/N1 ; mean(Y2)*U2/N2 ; mean(Y2(:))] ;
	theta2 = R\r ;
%
% Estimation of model error variances
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	if (nargout>2)
	   FN = N1*N2 ;
	   [U1,U2] = meshgrid(U1,U2) ;
	   R = theta1(1)*U1 + theta1(2)*U2 + theta1(3) ;
	   R = Y1-R' ;
	   lambda12 = R(:)'*R(:)/FN ;
	end ; 
	if (nargout>3)
	   R = theta2(1)*U1 + theta2(2)*U2 + theta2(3) ;
	   R = Y2-R' ;
	   lambda22 = R(:)'*R(:)/FN ;
	end ; 
%
% END
%