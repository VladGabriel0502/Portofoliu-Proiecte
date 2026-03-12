%
%	File INIT_ARX_SIMU_DS.M
%
%	Main file
%	Synopsis: Init_ARX_simu_DS ;
%
%	Initializes the SIMULINK scheme associated to the ARX model of ASTANK2 plant. 
%	The noise sources are activated. 
%	
%	!!! Run the simulation scheme with cancelled noises first !!!
%
%	See theory for more details.
% 
%	Uses: INI_ARX_SIMU
%
%	Authors: Dan STEFANOIU
%	Created: May 17, 2025
%	Revised: 
%
% BEGIN
%
	if (sw)
	   y1id_util = y1_simu ;
	   v1id = y1id_mas - y1id_util ;
	   e1id_est = pe(best_model{1}.ARMA_model1,v1id) ;
	   lambda12 = var(e1id_est) ;
	   y2id_util = y2_simu ;
	   v2id = y2id_mas - y2id_util ;
	   e2id_est = pe(best_model{1}.ARMA_model2,v2id) ;
	   lambda22 = var(e2id_est) ;
	else
	   y1va_util = y1_simu ;
	   v1va = y1va_mas - y1va_util ;
	   e1va_est = pe(best_model{1}.ARMA_model1,v1va) ;
	   lambda12 = var(e1va_est) ;
	   y2va_util = y2_simu ;
	   v2va = y2va_mas - y2va_util ;
	   e2va_est = pe(best_model{1}.ARMA_model2,v2va) ;
	   lambda22 = var(e2va_est) ;
	end ;
%
% END
%