%
%	File STATIC_ADMISSIBLE_COMMANDS_ASTANK2.M
%
%	Function: STATIC_ADMISSIBLE_COMMANDS_ASTANK2
%
%	Call: [YUa,U1a,U2a,Y1a,Y2a,theta1,theta2] = Static_admissible_commands_ASTANK2(static_map) ;
%
%	Builds the static maps of admissible commands, corresponding to admissible references,
%	based on the static map of insallation ASTANK2.
%
%	Input argument: static_map, a structure with the fields:
%	  . U1 = static control input on channel 1 (column vector);
%	  . U2 = static control input on channel 1 (column vector);
%	  . Y1 = static level on tank 1 (matrix);
%	  . Y1 = static level on tank 2 (matrix).
%
%	Output arguments:
%	  . YUa = matrix of admissible quadruples [y1a ; y2a ; u1a ; u2a] put on columns, 
%	          in increasing order of y1a;
%	  . U1a = surface of admissible commands on channel 1 (matrix);
%	  . U2a = surface of admissible commands on channel 1 (matrix);
%	  . Y1a = vector of all possible references for tank 1 (column);
%	  . Y2a = vector of all possible references for tank 2 (column);
%	  . theta1 = plane parameters for level on tank 1 (vector: [a1 b1 c1]);
%	  . theta2 = plane parameters for level on tank 2 (vector: [a2 b2 c2]).
%
%	See theory for details. 
%
%	If the static map is missing or empty, the outputs are empty. 
%
%	Uses:	 LS_STATIC_PLANES_ASTANK2
%	         WAR_ERR 
%
%	Author:	 Dan STEFANOIU
%	Created: April 24, 2025
%	Revised: April 28, 2025
%

function [YUa,U1a,U2a,Y1a,Y2a,theta1,theta2] = Static_admissible_commands_ASTANK2(static_map) ;

%
% BEGIN
%
% Constants & Messages 
% ~~~~~~~~~~~~~~~~~~~~
	FN = '<STATIC_ADMISSIBLE_COMMANDS_ASTANK2>: ' ;
	E = [FN 'Missing, empty or inconsistent static map => empty outputs. Exit.'] ; 
	Umin = 2 ; 
	Umax = 10 ;
	dy = 0.01 ;
%
% Partial faults preventing (structure of static_map not tested)
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	YUa = [] ;
	[U1a,U2a] = deal([]) ; 
	[Y1a,Y2a] = deal([]) ; 
	if (nargin<1)
	   war_err(E) ;
	   return ;
	end ; 
	if (isempty(static_map))
	   war_err(E) ;
	   return ;
	end ; 
%
% Identify the static planes
% ~~~~~~~~~~~~~~~~~~~~~~~~~~
	[theta1,theta2] = LS_static_planes_ASTANK2(static_map) ;
%
% Generate the references 
% ~~~~~~~~~~~~~~~~~~~~~~~
	Y1a = (min(static_map.Y1(:)):dy:max(static_map.Y1(:)))' ;
	Y2a = (min(static_map.Y2(:)):dy:max(static_map.Y2(:)))' ;
%
% Build the surfaces of raw commands
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	dy = det([theta1(1:2) theta2(1:2)]) ;
	[FN,E] = meshgrid(Y1a,Y2a) ;
	FN = FN - theta1(3) ;
	E = E - theta2(3) ;
	U1a = (theta2(2)*FN-theta1(2)*E)'/dy ;
	U2a = (theta1(1)*E-theta2(1)*FN)'/dy ;
%
% Build the surfaces of admissible commands
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	dy = (U1a<Umin) | (U2a<Umin) | (U1a>Umax) | (U2a>Umax) ;
	U1a(dy) = NaN ;
	U2a(dy) = NaN ;
%
% Build the matrix of admissible quadruples
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	FN = Y1a*ones(1,length(Y2a)) ;
	E = ones(length(Y1a),1)*Y2a' ;
	YUa = [FN(~dy)' ; E(~dy)' ; U1a(~dy)' ; U2a(~dy)'] ;
	[~,n] = sort(YUa(1,:)) ;
	YUa = YUa(:,n) ;
%
% END
%