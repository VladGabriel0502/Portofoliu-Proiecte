function [ DATA1, DATA2 ] = TS2DATA_2(n)
    % Messages 
% ~~~~~~~~
        warning('off','MATLAB:dispatcher:InexactMatch') ; 
	FN = '<MAKE_DATA>: ' ; 
	E1 = [FN 'Missing or empty input data. Empty output. Exit.'] ; 
	BL = [blanks(3) '* Insert '] ; 
	EN = ' (ENTER means none): ' ;
    S  = [FN 'Data saved in file <%s.MAT>.'] ;
%
% Faults preventing 
% ~~~~~~~~~~~~~~~~~
	DATA1 = iddata ;
    DATA2 = iddata ;
	if (nargin < 1)
	   war_err(E1) ; 
	   return ; 
	end ; 
	if (isempty(n))
	   war_err(E1) ; 
	   return ; 
	end ; 
%
%
% Building the DATA object
% ~~~~~~~~~~~~~~~~~~~~~~~~
% Importing the data that we will use in order to make the iddata objects -
% the two y channels from Ynn will become along with the corresponding
% information 2 different iddata objects
    eval(['load Y' num2str(n)]);
    DATA1.Name = ['Y' num2str(n) '_1'] ;
    DATA2.Name = ['Y' num2str(n) '_2'] ;

% First 3 iddata objects have only temperature measurements on both channels, but the last 2 are different 
    if( n >= 16 && n <= 18 )
        DATA1.y = Y.y(:,1) ; % copying the outputs and the information corresponding to each channel
        DATA2.y = Y.y(:,2) ;

        Data1.Ts = Y.Ts ;
        Data2.Ts = Y.Ts ;

        DATA1.SamplingInstants = Y.SamplingInstants ; 
        DATA2.SamplingInstants = Y.SamplingInstants ; 
        
        txt1 = Y.ExperimentName ;
        txt2 = txt1 ;

        txt1 = replace(txt1, " and max", "") ; % From Dayly min and max ... => Daily min ... 
        % txt1 = strtrim(txt1) ;
        DATA1.ExperimentName = txt1 ;
        
        txt2 = replace(txt2, "min and ", ""); % Analogous to the previous lines of code
        % txt2 = strtrim(txt2) ;
        DATA2.ExperimentName = txt2 ;

        DATA1.TimeUnit = Y.TimeUnit ;
        DATA2.TimeUnit = Y.TimeUnit ;

        DATA1.OutputName = Y.OutputName{1} ;
        DATA2.OutputName = Y.OutputName{2} ;

        DATA1.OutputUnit = 'ºC' ;
        DATA2.OutputUnit = 'ºC' ;

    elseif ( n == 19 )
        DATA1.y = Y.y(:,1) ; % copying the outputs and the information corresponding to each channel
        DATA2.y = Y.y(:,2) ;

        Data1.Ts = Y.Ts ;
        Data2.Ts = Y.Ts ;

        DATA1.SamplingInstants = Y.SamplingInstants ; 
        DATA2.SamplingInstants = Y.SamplingInstants ; 
        
        txt1 = Y.ExperimentName ;
        txt2 = txt1 ;

        txt1 = replace(txt1, " and sodium", "") ; % From Glycemia and sodium conce... -> Glycemia conce...
        txt1 = replace(txt1, "and a male", "") ; % from ... a female and a male -> ... a female
        txt1 = strtrim(txt1) ;
        DATA1.ExperimentName = txt1 ;
        
        txt2 = replace(txt2, "Glycemia and", "") ; % From Glycemia and sodium conce... -> Glycemia conce...
        txt2 = replace(txt2, "and a male", "") ; % from ... a female and a male -> ... a female
        txt2 = strtrim(txt2) ;
        % Convert to char vector
        c = char(txt2);
        
        % Make only first character uppercase
        c(1) = upper(c(1));
        
        % Convert back to string
        txt2 = string(c);
        DATA2.ExperimentName = txt2 ;

        DATA1.TimeUnit = Y.TimeUnit ;
        DATA2.TimeUnit = Y.TimeUnit ;

        DATA1.OutputName = Y.OutputName{1} ;
        DATA2.OutputName = Y.OutputName{2} ;

        DATA1.OutputUnit = '[mg/dl]' ;
        DATA2.OutputUnit = '[mmol/L]' ;
    elseif( n == 20 )
        DATA1.y = Y.y(:,1) ; % copying the outputs and the information corresponding to each channel
        DATA2.y = Y.y(:,2) ;

        Data1.Ts = Y.Ts ;
        Data2.Ts = Y.Ts ;

        DATA1.SamplingInstants = Y.SamplingInstants ; 
        DATA2.SamplingInstants = Y.SamplingInstants ; 
        
        txt1 = Y.ExperimentName ;
        txt2 = txt1 ;

        txt1 = replace(txt1, " and sodium", "") ; % From Glycemia and sodium conce... -> Glycemia conce...
        txt1 = replace(txt1, "a female and ", "") ; % from ... a female and a male -> ... a female
        txt1 = strtrim(txt1) ;
        DATA1.ExperimentName = txt1 ;
        
        txt2 = replace(txt2, "Glycemia and ", "") ; % From Glycemia and sodium conce... -> Glycemia conce...
        txt2 = replace(txt2, "a female and ", "") ; % from ... a female and a male -> ... a female
        txt2 = strtrim(txt2) ;
        % Convert to char vector
        c = char(txt2);
        
        % Make only first character uppercase
        c(1) = upper(c(1));
        
        % Convert back to string
        txt2 = string(c);
        DATA2.ExperimentName = txt2 ;

        DATA1.TimeUnit = Y.TimeUnit ;
        DATA2.TimeUnit = Y.TimeUnit ;

        DATA1.OutputName = Y.OutputName{1} ;
        DATA2.OutputName = Y.OutputName{2} ;

        DATA1.OutputUnit = '[mg/dl]' ;
        DATA2.OutputUnit = '[mmol/L]' ;
    end

% Saving the iddata object to disk
    Y = DATA1 ;
	eval(['save ' DATA1.Name '.mat Y']) ;	% Save the DATA objects.
    war_err(sprintf(S,DATA1.Name)) ;

    Y = DATA2 ;
    eval(['save ' DATA2.Name '.mat Y']) ;	% Save the DATA objects.
	war_err(sprintf(S,DATA2.Name)) ;
end