%
%	File DETECT_TRANSIENT_TIME.M
%
%	Function: DETECT_TRANSIENT_TIME
%
%	Synopsis: [Nr,sigma,AR_sigma] = detect_transient_time(y,y_ref,dw)
%
%	Estimates the transient time Nr for a signal y supposed to follow some constant 
%	reference signal y_ref. The input y is a vector, whereas the input y_ref is considered
%	a scalar. If y has the length N, then Nr is an integer at least equal to 0 and at most 
%	equal to N. It can be null, if the error y-y_ref has small relative variance, comparing 
%	to y_ref (e.g. smaller than 3% of y_ref). Also, it can be maximum if too close to N 
%	(e.g. greater than 90% of N). The dw input argument can be null (default 
%	value) or non null. The warning about not detecting any transient zone is only 
%	displayed if dw in non null. 
%
%	Usually, the signal y is affected by noises. Therefore, detecting the transient time 
%	cannot be performed like in case of deterministic signals. The method implemented 
%	here relies on the backward standard deviation of error signal, while assuming that 
%	the signal y reaches for its steady-state behavior. Thus, the moving std is computed 
%	backwards, from the signal end to the signal start. Its values are stored into the 
%	vector sigma (the second output argument). The std variation sigma is then penalized 
%	by using the Akaike-Rissanen criterion, in order to isolate a sharp minimum. 
%	The result is returned in AR_sigma output argument. If a valid transient zone has been 
%	detected, the minimum point of AR_sigma points to the transient time Nr. 
%
%	Missing, empty or inconsistent inputs returns empty or wrong outputs. 
%
%	Uses:	 WAR_ERR 
%
%	Author:	 Dan STEFANOIU
%	Created: March 05, 2021
%	Revised: March 06-07, 2021
%	         March 10, 2021
%	         March 15, 2021
%	         March 22-23, 2021
%	         June  07, 2021
%

function [Nr,sigma,AR_sigma] = detect_transient_time(y,y_ref,dw)

%
% BEGIN
%
% Constants & Messages 
% ~~~~~~~~~~~~~~~~~~~~
	FN = '<DETECT_TRANSIENT_TIME>: ' ;
	E1 = [FN 'Missing, empty or inconsistent input data => empty output. Exit.'] ; 
	W1 = [FN 'No transient zone detected. Transient time set to null. Exit.'] ; 
	W2 = [FN 'Smooth (noise free) signal detected. Transient time updated. Exit.'] ; 
	W3 = [FN 'No steady-state zone detected. Transient time set to signal length. Exit.'] ; 
	delta = 0.015 ; % Threshold to detect close minima of AR-std.
	eps = 0.015 ; 	% Threshold to detect noise free (smooth) signals.
	mu  = 0.03 ; 	% Threshold to undetect transient zone.
	nu  = 0.9 ;	% Threshold to undetect steady-state zone.
	rho = 0.003 ;  	% Threshold to set minimum number of terms in std computation. 
%
% Faults preventing
% ~~~~~~~~~~~~~~~~~
	Nr = [] ; 
	[sigma,AR_sigma] = deal([]) ;
	if (nargin < 2)
	   war_err(E1) ; 
	   return ;
	end ; 
	if (isempty(y) | isempty(y_ref))
	   war_err(E1) ; 
	   return ;
	end ; 
%	y = y(~isnan(y)) ;
	FN = length(y) ; 
	if (FN<2)
	   war_err(E1) ; 
	   return ;
	end ; 
	y_ref = y_ref(1) ; 
	if (nargin < 3)
	   dw = 0 ; 
	end; 
	if (isempty(dw))
	   dw = 0 ; 
	end ; 
	dw = dw(1) ; 
%
% Detecting the transient time
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	rho = round(rho*FN) ;			% Minimum number of terms to start std computation with. 
	rho = FN - rho ; 
	y = y - y_ref ; 
	for n=rho:-1:1			% Computing the moving backwards std. 
	   sigma = [std(y(n:FN)) sigma] ; 
	end ; 
	sigma(sigma<1e-15) = 1e-15 ; 		% To prevent log(0).
	rho = 1:rho ; 				% Applying the Akaike-Rissanen penalty.
	AR_sigma = log(sigma) + rho*log(FN)/FN/2 ; 
	if (sigma(1) < mu*abs(y_ref))		% If no transient zone detected,
	   Nr = 0 ; 				% set transient time to null...
	   if (dw)
	      war_err(W1) ; 
	   end ;
	   return ; 				% ... and exit. 
	end ; 
	[W1,W2] = min(AR_sigma) ; 		% Estimating the non null transient time.
	W1 = AR_sigma(W2:end) ;  		% If several minima are close to each-other,
	[W1,Nr] = sort(W1) ;			% take the one with maximum index. 
	W1 = sum(W1 < (W1(1)+delta*peak2peak(AR_sigma))) ; 
	Nr = Nr(W1) + W2 -1 ; 
	nu = nu*FN ; 
	if (Nr > nu)				% If no steady-state zone detected,
	   W1 = peak2peak(sigma) ; 		% maybe the signal is noise free.
	   Nr = rho(end) ;			% Check whether the signal is smooth or not. 
	   while (sigma(Nr)<eps*W1)
	      Nr = Nr-1 ; 
	   end ;
	   if (Nr < nu)				% Smooth signal detected, transient time updated.
	      if (dw)
	         war_err(W2) ; 
	      end ;				% Just exit. 
	   else					% Noised signal detected. There is no steady-state zone. 
	      Nr = FN ; 			% Set transient time to signal length...
	      if (dw)
	         war_err(W3) ; 
	      end ;				% ... and exit. 
	   end ;
	end ;
%
% END
%