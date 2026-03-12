%
%	File BE_DISCRETIZE_PID.M
%
%	Function: BE_discretize_PID
%
%	Call: [R,S] = BE_discretize_PID(Kp,Ti,Td,Nd,Ts) ;
%
%	Performs discretization of 1D or 2D PID controller by using Backward Euler Method. 
%	The continuous time PID controller structure is classical, with the transfer function
%	below: 
%
%	                   C(s) = Kp + 1./(Ti.s) + Td.s./(1+Td.s./Nd) .
%
%	The Backward Euler Method is described by: s = (z-1)/(Ts.z), where Ts is the sampling period. 
%
%	Input arguments:
%	  . Kp = proportional parameter(s) of continuous PID controller (scalar or matrix);
%	  . Ti = proportional parameter(s) of continuous PID controller (scalar or matrix);
%	  . Td = derivative parameter(s) of continuous PID controller (scalar or matrix);
%	  . Nd = physical realizability parameter(s) of continuous PID controller (scalar or matrix);
%	  . Ts = sampling period (scalar, equal to 1, by default).
%
%	If Nd=Inf, the physically non realizable controller is discretized. 
%	If Td=0, the PI controller is discretized. 
%
%	Output arguments:
%	  . R = numerator of discrete transfer function/matrix (vector or 3D array);
%	  . S = denominator of discrete transfer function/matrix (vector or 3D array).
%
%	In general, the transfer function of discrete PID controller is:
%
%	                                   R0.z^2 + R1.z + R2
%	                          Cd(z) = --------------------
%	                                    z^2 + S1.z + S2
%
%	If PID is scalar, then R = [R0 R1 R2] and S = [S1 S2].
%	If PID is 2D, the 3D array of R has matrices R0, R1 and R2 stored on layers. 
%	Similarly, the 3D array of S has matrices S1 and S2 stored on layers.
%
%	If all input arguments are missing or empty, the outputs are empty. 
%
%	Uses:	 WAR_ERR 
%
%	Author:	 Dan STEFANOIU
%	Created: April 22, 2025
%	Revised: April 23, 2025
%	         May 01, 2025
%

function [R,S] = BE_discretize_PID(Kp,Ti,Td,Nd,Ts)

%
% BEGIN
%
% Constants & Messages 
% ~~~~~~~~~~~~~~~~~~~~
	FN = '<BE_DISCRETIZE_PID>: ' ;
	E = [FN 'Missing, empty or inconsistent inputs => empty outputs. Exit.'] ; 
%
% Partial faults preventing (size of input arguments not tested)
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	[R,S] = deal([]) ; 
	FN = zeros(1,3) ;
	switch nargin
	   case 0 
	      war_err(E) ; 
	      return ;
	   case 1			% P controller.
	      if (~isempty(Kp) && (norm(Kp,'fro')>=eps))
	         FN(1) = 1 ; 
	      end ; 
	   case 2			% P or PI or I controllers.
	      if (~isempty(Kp) && (norm(Kp,'fro')>=eps))
	         FN(1) = 1 ; 
	      end ; 
	      if (~isempty(Ti) && (norm(Ti,'fro')>=eps) && norm(Ti,'fro')<Inf)
	         FN(2) = 1 ;
	      end ;
	   otherwise			% The remaining controllers.
	      if (~isempty(Kp) && (norm(Kp,'fro')>=eps))
	         FN(1) = 1 ; 
	      end ; 
	      if (~isempty(Ti) && (norm(Ti,'fro')>=eps) && norm(Ti,'fro')<Inf)
	         FN(2) = 1 ;
	      end  ;
	      if (~isempty(Td) && (norm(Td,'fro')>=eps))
	         FN(3) = 1 ;
	      end ; 
	end ; 
	if (~sum(FN))
	   war_err(E) ; 
	   return ;
	end ; 
	FN = FN*[4 ; 2 ; 1] ; 	% FN varies in range 1:7.
	switch FN
	   case 1			% D controller
	      if (nargin > 3)
	         if (isempty(Nd))
	            Nd = Inf*ones(size(Kp)) ; 
	         elseif (norm(Nd,'fro')<eps)
	            war_err(E) ;
	            return ; 
	         end ; 
	      else 
	         Nd = Inf*ones(size(Kp)) ;
	      end ; 
	      [Kp,Ti] = deal(zeros(size(Td))) ;
	   case 2			% I controller
	      [Kp,Td] = deal(zeros(size(Ti))) ;
	      Nd = Inf*ones(size(Ti)) ; 
	   case 3			% ID controller
	      if (nargin > 3)
	         if (isempty(Nd))
	            Nd = Inf*ones(size(Kp)) ;
	         elseif (norm(Nd,'fro')<eps)
	            war_err(E) ;
	            return ; 
	         end ; 
	      else 
	         Nd = Inf*ones(size(Kp)) ;
	      end ; 
	      Kp = zeros(size(Ti)) ; 
	   case 4			% P controller.
	      if isscalar(Kp)
	         R = [Kp 0 0] ;
	         S = [1 0 0] ;
	      else
	         FN  = zeros(2,2) ;
	         R = cat(3,Kp,FN,FN) ;
	         S = cat(3,ones(2,2),FN,FN) ; 
	      end ; 
	      return ;
	   case 5			% PD controller.
	      if (nargin > 3)
	         if (isempty(Nd))
	            Nd = Inf*ones(size(Kp)) ;
	         elseif (norm(Nd,'fro')<eps)
	            war_err(E) ;
	            return ; 
	         end ; 
	      else 
	         Nd = Inf*ones(size(Kp)) ;
	      end ; 
	      Ti = Inf*ones(size(Kp)) ; 
	   case 6			% PI controller.
	      Td = zeros(size(Kp)) ; 
	      Nd = Inf*ones(size(Kp)) ;
	   otherwise			% PID controller.
	      if (nargin > 3)
	         if (isempty(Nd))
	            Nd = Inf*ones(size(Kp)) ;
	         elseif (norm(Nd,'fro')<eps)
	            war_err(E) ;
	            return ; 
	         end ; 
	      else 
	         Nd = Inf*ones(size(Kp)) ;
	      end ; 
	end ; 
	if (nargin < 6)
	   Ts = 1 ;
	end ; 
	if (isempty(Ts))
	   Ts = 1 ; 
	end ; 
	Ts = abs(Ts(1)) ;
	if (Ts < eps)
	   Ts = 1 ;
	end ; 
%
% Discretizing the PID controller
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Ti = Ts./Ti ;			% Normalizing the time constants by the sampling period Ts. 
	Td = Td/Ts ; 
	E  = zeros(2,2) ;
	S = Td./Nd ; 
	R = Td + Kp.*S ;
	Ts = 1 + S ;
  %
  % Case: D controller
  % ------------------
	if (~(FN-1))
	   if isscalar(Td)
	      R = [[Td -Td]/Ts 0] ;
	      S = [1 -S/Ts 0] ;
	   else
	      R = cat(3,Td./Ts,-Td./Ts,E) ;
	      S = cat(3,ones(2,2),-S./Ts,E) ; 
	   end ; 
	   return ;
	end ; 
  %
  % Case: PD controller
  % -------------------
	if (~(FN-5))
	   if isscalar(Td)
	      R = [[Kp+R -R]/Ts 0] ;
	      S = [1  -S/Ts 0] ;
	   else
	      R = cat(3,(Kp+R)./Ts,-R./Ts,E) ;
	      S = cat(3,ones(2,2),-S./Ts,E) ; 
	   end ; 
	   return ;
	end ; 
  %
  % Case: PID controller and all remaining particular cases
  % -------------------------------------------------------
	FN = Kp+Ti ;
	S = S./Ts ; 
	if isscalar(Kp)
	   R = [(Td/Ts+FN) -((Kp+Td+Td)/Ts+S*(FN+Kp)) (Td/Ts+Kp*S)] ;
	   S = [1 -(1+S) S] ;
	else
	   R = cat(3,Td./Ts+FN,-((Kp+Td+Td)./Ts+S.*(FN+Kp)),(Td./Ts+Kp*S)) ;
	   S = cat(3,ones(2,2),-(1+S),S) ; 
	end ; 	
%
% END
%