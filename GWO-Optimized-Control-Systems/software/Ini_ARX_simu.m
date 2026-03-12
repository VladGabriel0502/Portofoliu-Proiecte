%
%	File INI_ARX_SIMU.M
%
%	Function: Ini_ARX_simu
%	Synopsis: ARX_ini = Ini_ARX_simu(ARX_model,y_ini) ;
%
%	Initializes the SIMULINK model associated to the ARX model of ASTANK2 plant. 
%	See theory for more details.
% 
%	Input arguments: 
%	 . ARX_model   = structure of model parameters (cannot miss); 
%	 . y_ini   = initialization (scalar); if missing or empty, null initialization is set.
%
%	Output argument: 
%	 . ARX_ini   = structure of initializations; for each numerator polynomial POL of NARX model, 
%	                ARX.POL or ARX.POL{n} is a row vector of the initialization. 
%
%	Missing, empty or inconsistent inputs returns empty outputs. 
%
%	Uses: VECTORIZE
%	      WAR_ERR 
%
%	Authors: Dan STEFANOIU & JC
%	Created: May 02-05, 2025
%	Revised: May 17, 2025
%

function ARX_ini = Ini_ARX_simu(ARX_model,y_ini)

% BEGIN
%
% Messages
% ~~~~~~~~
	M = '<INI_NARX_SIMU>: ' ;
	na = [M 'Missing, empty or inconsistent inputs => empty outputs. Exit.'] ;
%
%
% Faults preventing
% ~~~~~~~~~~~~~~~~~
   ARX_ini = struct ; 
   if (nargin < 1)
      war_err(na) ;
      return ;
   end ;
   if (isempty(ARX_model)) 
      war_err(na) ;
      return ;
   end ; 
   if (nargin < 2)
      y_ini = 0 ;
   end ;
   y_ini = y_ini(1) ;  		% Scalar.
%
% Determine the number of useful filters into the SIMULINK model
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   M = 2 ; 
%
% Equally allocate the initialization to all filters
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   y_ini = y_ini/M ; 
%
% Building the structure with initial data
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   %
   % Determine the degree of A polynomial
   % ------------------------------------
   na = length(ARX_model.a) - 1 ; 
   %
   % Process B1 polynomial
   % ---------------------
   pol_deg = length(ARX_model.b{1}) -1 ; 				% Determine the degree of B1 polynomial.
   ARX_ini.b1 = [y_ini/ARX_model.b{1}(2) zeros(1,max(na,pol_deg)-1)];	% Perform initialization.
   %
   % Process B2 polynomial
   % ---------------------
   pol_deg = length(ARX_model.b{2}) -1 ;				% Determine the degree of B2 polynomial.
   ARX_ini.b2 = [y_ini/ARX_model.b{2}(2) zeros(1,max(na,pol_deg)-1)];	% Perform initialization.
%
% END
%