%
%	File U_SAT.M
%
%	Function: U_SAT
%
%	Call: ue = u_sat(u,du,Umin,Umax) ;
%
%	Applies constructive limitations on command to be sent to ASTANK2 installation.  
%	Thus, the current value (u - scalar) and the one-step delayed value (du - scalar) 
%	of command are employed to produce the effective value of command (ue - scalar),
%	as follows:
%	  . ue cannot greater by 3 (V) than du;
%	  . ue cannot be smaller by 3 (V) than du;
%	  . ue must be in range [Umin,Umax] (V); by default, Umin=2 and Umax=10;
%	  . ue=u, if all restrictions above are verified by u. 
%
%	If both input arguments (u and du) are missing or void, a warning message is displayed
%	and ue is set to 2 (V).  
%
%	Uses:	 WAR_ERR 
%
%	Author:	 Dan STEFANOIU
%	Created: April 22, 2025
%	Revised: April 28, 2025
%

function ue = u_sat(u,du,Umin,Umax)

%
% BEGIN
% ~~~~~
	ue = '<U_SAT>: ' ;
	W = [ue 'Missing or empty or inconsistent inputs => command set to minimum value.'] ; 
	if (nargin<3)
	   Umin = 2 ;
	end ; 
	Umin = Umin(1) ;
	if (nargin<4)
	   Umax = 10 ;
	end ; 
	Umax = Umax(1) ;
	ue = Umin ;
	if (nargin<2)
	   war_err(W) ;
	   return ;
	end ; 
	if (isempty(u) || isempty(du))
	   war_err(W) ;
	   return ;
	end ; 
	ue = min(max(max(du(1)-3,min(du(1)+3,u(1))),Umin),Umax) ;
%
% END
% ~~~
