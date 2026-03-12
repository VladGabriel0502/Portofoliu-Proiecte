%
%	File WAR_ERR.M
%
%	Function: WAR_ERR
%
%	Call: war_err(msg)
%
%	Displays a warning/error message. If msg is 
%	present and non void, then it is displayed. 
%	Otherwise (missing or void), a standard error 
%	message is displayed. 
%
%	Created: June      02, 1999
%	Revised: September 22, 2007
%                January   06, 2024
%	Author:  Dan Stefanoiu
%

function war_err(msg)

%
%	BEGIN
%
	if ((nargin > 0) & (~isempty(msg)))
	   disp(' ') ;
	   disp(msg) ;
	   disp(' ') ;
	else
	   disp(' ') ;
	   disp('<WAR_ERR>: An error occured.') ;
	   disp(' ') ;
	end ;
%
%	END
%

