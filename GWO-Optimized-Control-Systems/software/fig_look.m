%
%	File FIG_LOOK.M
%
%	Function: FIG_LOOK
%
%	Call:	B2R_col_map = fig_look(H,lw,fs,M) ;
%
%	Set some parameters that change the general aspect (look) 
%	of the figure with handle H. If H is missing or empty, the 
%	current figure is affected. The second argument, lw, if specified 
%	and non-empty, stands for the desired line width of graphics. 
%	By default, lw=0.5. Normally, lw should be non-negative. 
%	The third argument, fs, if specified as non empty and positive
%	integer, sets the font size to apply. By default, fs=14. 
% 	The fourth argument, M, if specified as non empty and non null
%	enforces the figure window to extend/maximize to the whole screen. 
%	By default, M=0 (no maximization is performed).
%
%	A nice colormap can be returned to draw 3D surfaces from blue to red
%	(optional output argument B2R_col_map). 
%
%	Uses:	 -
%
%	Author:	 Dan STEFANOIU
%	Created: November 1, 2002
%	Updated: October 27, 2008
%	         March 16, 2021 (added nice colormap)
%	         June 01, 2021 (offered possibility to maximize the window)
%	         February 18, 2022 (removed ANS; don't know where it comes from)
%	         May 28, 2024 (added font size as function argument)
%

function B2R_col_map = fig_look(H,lw,fs,M) 

%
% BEGIN
%
% Faults preventing
% ~~~~~~~~~~~~~~~~~
	if (nargin < 1)
	   H = gcf ; 	   
	end ;
	if (isempty(H))
	   H = gcf ; 
	end ; 
	if (nargin < 2)
	   lw = 0.5 ; 
	end ; 
	if (isempty(lw))
	   lw = 0.5 ; 
	end ; 
	lw = abs(lw) ; 
	if (~lw)
	   lw = 0.5 ; 
	end ; 
	if (nargin < 3)
	   fs = 14 ; 
	end ; 
	if (isempty(fs))
	   fs = 14 ; 
	end ; 
	fs = abs(round(fs)) ; 
	if (~fs)
	   fs = 14 ; 
	end ; 
	if (nargin < 4)
	   M = 0 ; 
	end ; 
	if (isempty(M))
	   M = 0 ; 
	end ;
	M = abs(M(1)) ; 
	if (M)
	   set(H,'WindowState','maximized') ;
	end ; 
%
% Fixing the look
% ~~~~~~~~~~~~~~~
	% Axes : 
	ms = round(4*fs/7) ;				% marker size
	set(H,'DefaultAxesFontName','Verdana') ; 	% or 'Helvetica', 'Arial'
	set(H,'DefaultAxesFontSize',fs) ; 
	set(H,'DefaultAxesFontWeight','bold') ;  	% or 'light', 'normal', 'demi'
	set(H,'DefaultAxesFontAngle','normal') ;	% or 'italic', 'oblique'
	set(H,'DefaultAxesLineWidth',1) ; 

	% Text over figure:
	set(H,'DefaultTextFontName','Verdana') ; 	% or 'Helvetica', 'Arial'
	set(H,'DefaultTextFontSize',fs) ; 
	set(H,'DefaultTextFontWeight','bold') ; 	% or 'light', 'normal', 'demi'
	set(H,'DefaultTextFontAngle','normal') ; 	% or 'italic', 'oblique'
	set(H,'DefaultTextRotation',0) ; 		% Horizontal writing. 
%	set(H,'DefaultTextRotation',90) ; 		% Vertical writing. 
%	set(H,'DefaultTextRotation',????) ; 		% Oblique writing. 
	set(H,'DefaultTextHorizontalAlignment','center') ; % or 'left', 'right' 

	% 2D graphic line: 
	set(H,'DefaultLineLineStyle','-') ;  		% or '-', ':', etc.
	set(H,'DefaultLineLineWidth',lw) ; 
	set(H,'DefaultLineMarkerSize',ms) ; 

	% Use: plot(x,y,'Color',[r g b]/255) ; to set a specific color for the current drawing. 
	% The integers r, g, b vary in the range from 0 to 255. 
	% To find the desired {r,g,b} triplet, MS-Office Word can be used.   

	% 3D graphic lines and surfaces: 
	set(H,'DefaultSurfaceLineStyle','none') ; 	% or '-', ':', etc.
	set(H,'DefaultSurfaceLineWidth',lw) ; 
	set(H,'DefaultSurfaceMarkerSize',ms) ; 
	set(H,'DefaultSurfaceFaceColor','interp') ; 
	set(H,'DefaultSurfaceFaceLighting','phong') ; 

	% Background color outside axes
	set(H,'Color',[87 92 98]/100) ; 		% Light turquoise. 
							% See colormap for more colors or use MS-Office Word. 
	% Colormap between Blue (min value) and Red (max value)
	lw = ones(255,1) ; 
	lw = [lw (1:255)' 255*lw] ;
	B2R_col_map = [lw ; ...
	               [lw(1:254,[1 3]) flipud(lw(1:254,2))] ; ...
	               [lw(2:255,2) lw(2:255,[3 1])] ; ...
	               [lw(1:254,3) flipud(lw(1:254,2)) lw(1:254,1)] ...
	              ]/255 ; 
	set(H,'Colormap',B2R_col_map) ;
        clear ans ;
%
% END
%
