%
%	File TS2DATA.M
%
%	Function: TS2DATA
%
%	Synopsis: DATA = TS2DATA(n) ; 
%
%	Creates the IDDATA object from existing acquired data y. The first column of 
%	y sould be the sampling instants vector. The remaining columns are then
%	understood as measured data on different channels. If y is a vector 
%	(row or column), then it is understood as measured data on one channel. 
%	Once DATA being created, it is saved on disk in the current directory, 
%	by means of MATLAB command SAVE. The DATA object can be loaded in MATLAB 
%	workspace by means of dual command LOAD. 
% 
%
%	   DATA.Name           = name of data block; the same name is used for the  
%	                         file saved on disk; (char string); 
%	   DATA.UserData          = unit - in order to better understand the the interval;  
%	   DATA.ExperimentName = name of the measuring experiment (char string); 
%	   DATA.TimeUnit       = unit of time (e.g. seconds, minutes, hours, days, etc.); 
%	                         (char string);  
%	   DATA.Ts             = sampling period (scalar) ; 
%	   DATA.OutputName     = name of each measuring channel (cell array of char strings);
%	   DATA.OutputUnit     = unit of measured data (cell array of char strings). 
%
%	Example: 
%	   DATA.Name = 'T_Bucharest' ; 
%	   DATA.UserData = 'Time [days]' ; 
%	   DATA.ExperimentName = {'Daily min and max average temperatures in Bucharest'} ; 
%	   DATA.TimeUnit = 'day' ; 
%	   DATA.Ts = 1 ; 
%	   DATA.OutputName = {'Minimum temperature' ; 
%			      'Maximum temperature'} ; 
%	   DATA.OutputUnit = {'ºC' ; 
%			      'ºC'} ; 
%
%	Empty input enforces empty output. 
%
%	Uses:	 VECTORIZE
%		 WAR_ERR
%
%	Author:  Grigore Vlad-Gabriel
%	Created: October    15, 2025
%	Revised: October 15, 2025

function DATA = TS2DATA(n)
    %
%  BEGIN
%
% Messages 
% ~~~~~~~~
        warning('off','MATLAB:dispatcher:InexactMatch') ; 
	FN = '<MAKE_DATA>: ' ; 
	E1 = [FN 'Missing or empty input data. Empty output. Exit.'] ; 
	BL = [blanks(3) '* Insert '] ; 
	EN = ' (ENTER means none): ' ;
% 	I1 = [BL 'the data name block [ENTER means ''DATA'']: '] ; eventually if needed
% 	I2 = [BL 'data notes' EN] ; 
% 	I3 = [BL 'the experiment name' EN] ; 
% 	I4 = [BL 'the time unit' EN] ; 
% 	I5 = [BL 'the starting date in format <dd-mmm-yyyy HH:MM:SS> (ENTER means NOW): '] ; 
% 	I6 = [BL 'user info (such as the starting date) as a string: '] ; 
 	I1 = [BL 'data name on channel %d' EN] ; 
 	I2 = [BL 'unit on channel %d' EN] ; 
    S  = [FN 'Data saved in file <%s.MAT>.'] ;

% Faults preventing 
% ~~~~~~~~~~~~~~~~~
	DATA = iddata ; 
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
% Differenciating between Y0n and Yn
    if( n < 10 ) 
        DATA.Name = ['Y0' num2str(n)] ;  % for the files that are similar to 'Y01' etc...
    else
        DATA.Name = ['Y' num2str(n)] ;  % for the file similar to 'Y12' etc...
    end
    
% Importing the data that we will use in order to make the iddata object
    eval(DATA.Name);

% All of the measured data is stored as a line vector =>
    DATA.y = y' ; % we make it a column vector in order to place it next to the time instants
    Data.Ts = 1; % the sample period is 1 regardless of the value of Ts in the .m files
    DATA.SamplingInstants = ntime ; % as the name of the variable sugests, there are the samplimg instants
    DATA.ExperimentName = label ; 
    DATA.UserData = unit; % we keep this information because in the Y11.m file we have a time interval 
    % which is not included in timeSet
                           
% We search if the TimeUnit is in the set containing {months, weeks, days } 
% The ones that are found in the time series ( 1 - 15 )
    timeSet = {"months","weeks", "days"}; 
    for i = 1:3
        if( contains(unit, timeSet{i}) == 1 ) % if one of the above is found in the unit string we assign it to the TimeUnit atribute
            DATA.TimeUnit = timeSet{i} ; 
        end
    end 
    
% As previously mentioned, DATA.y is a column vector so there is only one iteration for FN and BL
	FN = input(sprintf(I1,1),'s') ; 	% Setting the name of each output channel.
	DATA.OutputName = FN ;
	DATA.OutputUnit = yunit; 
% 
% Saving the iddata object to disk
    Y = DATA ; 
	eval(['save ' DATA.Name '.mat Y']) ;	% Save the DATA object. 
	war_err(sprintf(S, DATA.Name)) ;
end