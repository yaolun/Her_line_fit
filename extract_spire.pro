pro extract_spire, indir=indir, outdir=outdir, plotdir=plotdir, filename=filename, test=test,fixed_width=fixed_width,slw=slw,ssw=ssw,$
				   localbaseline=localbaseline,global_noise=global_noise,ra=ra,dec=dec,noiselevel=noiselevel,brightness=brightness,fx=fx,object=object,current_pix=current_pix,$
				   print_all=print_all,flat=flat,continuum_sub=continuum_sub,plot_subtraction=plot_subtraction,no_plot=no_plot,coordpix=coordpix,double_gauss=double_gauss
	; Test if the target path is valid. If not, create them.
	if file_test(outdir,/directory) eq 0 then file_mkdir, outdir
	if not keyword_set(no_plot) then begin
		if file_test(plotdir+'base',/directory) eq 0 then file_mkdir,plotdir+'base'
	endif
	if file_test(plotdir+'cannot_fit',/directory) eq 0 then file_mkdir,plotdir+'cannot_fit'
	if keyword_set(no_plot) then begin
		no_plot = 1
	endif else begin
		no_plot = 0
	endelse
	; The indir should include every letter except for the pixel name.
	if keyword_set(brightness) then begin
		; suffix = '_b'
		ylabel = '!3Brightness (10!u-22!n W/cm!u2!n/!9m!3m/arcsec!u2!n)'
		unit = '!3/as2'
	endif
	if keyword_set(fx) then begin
		; suffix = '_f'
		ylabel = '!3Flux Density(10!u-22!n W/cm!u2!n/!9m!3m)'
		unit = ''
		brightness=0
	endif
	if not keyword_set(filename) then begin
		if keyword_set(slw) then begin
			pixelname = ['SLWA1','SLWA2','SLWA3','SLWB1','SLWB2','SLWB3','SLWB4','SLWC1','SLWC2','SLWC3','SLWC4','SLWC5','SLWD1','SLWD2','SLWD3','SLWD4','SLWE1','SLWE2','SLWE3']
			ra_dum = [] & dec_dum = []
			for ipix = 0, n_elements(pixelname)-1 do begin
				ra_dum = [ra_dum, ra[where(coordpix eq pixelname[ipix])]]
				dec_dum = [dec_dum, dec[where(coordpix eq pixelname[ipix])]]
			endfor
			ra = ra_dum & dec = dec_dum
			; get_radec_slw, coord, plot_coord & ra = coord[0,*] & dec = coord[1,*]
		endif
		if keyword_set(ssw) then begin
			pixelname = ['SSWA1','SSWA2','SSWA3','SSWA4','SSWB1','SSWB2','SSWB3','SSWB4','SSWB5','SSWC1','SSWC2','SSWC3','SSWC4','SSWC5','SSWC6','SSWD1','SSWD2','SSWD3','SSWD4','SSWD6','SSWD7','SSWE1','SSWE2','SSWE3','SSWE4','SSWE5','SSWE6','SSWF1','SSWF2','SSWF3','SSWF5','SSWG1','SSWG2','SSWG3','SSWG4']
			ra_dum = [] & dec_dum = []
			for ipix = 0, n_elements(pixelname)-1 do begin
				ra_dum = [ra_dum, ra[where(coordpix eq pixelname[ipix])]]
				dec_dum = [dec_dum, dec[where(coordpix eq pixelname[ipix])]]
			endfor
			ra = ra_dum & dec = dec_dum
			; get_radec_ssw, coord, plot_coord & ra = coord[0,*] & dec = coord[1,*]
		endif
	endif else begin
		pixelname = ['spire_corrected']
	endelse
	plot_pixelname = pixelname
	c = 2.998d8
    ; Information about the line that you want to fit including the range for baseline fitting.  SLW and SSW included
    line_name_oh2o = ['o-H2O5_23-5_14','o-H2O6_25-5_32','o-H2O8_45-9_18','o-H2O8_27-7_34','o-H2O7_43-6_52','o-H2O8_54-7_61','o-H2O3_21-3_12','o-H2O6_34-5_41','o-H2O3_12-2_21','o-H2O7_25-8_18',$
    				  'o-H2O3_12-3_03','o-H2O5_32-4_41','o-H2O1_10-1_01'];,'o-H2O4_23-3_30'
    line_center_oh2o = [212.5309344,226.7664669,229.2112944,231.2537873,234.5364534,256.5992833,257.8011350,258.8222114,259.9887495,261.4637873,$
    					273.1998800,483.0021428,538.3023584];,669.1946510
	
	line_name_ph2o = ['p-H2O7_26-6_33','p-H2O9_46-10_19','p-H2O7_44-8_17','p-H2O2_20-2_11','p-H2O4_22-4_13','p-H2O8_53-7_62','p-H2O7_44-6_51','p-H2O1_11-0_00','p-H2O2_02-1_11','p-H2O5_24-4_31',$
					  'p-H2O4_22-3_31','p-H2O9_28-8_35','p-H2O2_11-2_02','p-H2O6_24-7_17','p-H2O5_33-4_40','p-H2O6_42-5_51']
	line_center_ph2o = [208.0814648,208.9186114,222.9532762,243.9800446,248.2530166,251.7573722,255.6872873,269.2790845,303.4638096,308.9717523,$
						327.2312598,330.8298372,398.6525967,613.7265992,631.5709820,636.6680083]
	
	line_name_co = ['CO13-12','CO12-11','CO11-10','CO10-9','CO9-8','CO8-7','CO7-6','CO6-5','CO5-4','CO4-3']
	line_center_co = [200.27751475,216.93275100,236.61923625,260.24634206,289.12760810,325.23334516,371.65973939,433.56713410,520.24411585,650.26787364]
	
	line_name_13co = ['13CO13-12','13CO12-11','13CO11-10','13CO10-9','13CO9-8','13CO8-7','13CO7-6','13CO6-5','13CO5-4']
	line_center_13co = [209.481440501,226.903680083,247.496622503,272.21147644,302.422210195,340.18977646,388.752815449,453.509061166,544.174435197]
	
	line_name_hco = ['HCO+16-15','HCO+15-14','HCO+14-13','HCO+13-12','HCO+12-11','HCO+11-10','HCO+10-9','HCO+9-8','HCO+8-7','HCO+7-6','HCO+6-5']
	line_center_hco = [210.28816791,224.28135601,240.27541266,258.73206751,280.26711943,305.71952487,336.26530802,373.60195435,420.27521465,480.28810368,560.30913387]
	
	line_name_other = ['NII_205','CI3P2-3P0','CI3P2-3P1','CI3P1-3P0'];,'Unknown_221.3','Unknown_225.2']
	line_center_other = [205.178,230.349132,370.424383,609.150689];,221.3,225.2]
	
	line_name = [line_name_oh2o, line_name_ph2o, line_name_co, line_name_13co, line_name_hco, line_name_other]
	line_center = [line_center_oh2o, line_center_ph2o, line_center_co, line_center_13co, line_center_hco, line_center_other]
	
	; Define the range of line center by setting the range within 2 times of the resolution elements of the line center
	range = []
	range_factor=2
	line_name = line_name[sort(line_center)]
	line_center = line_center[sort(line_center)]
	; cont = cont[*,sort(line_center)]
	for i = 0, n_elements(line_center)-1 do begin
		; resolution intead of fwhm here
		dl = 1.5*1.207*(1.2*1e9*(line_center[i]*1e-4)^2/2.998d10*1e4)/2.354d

		; range = [[range], [[line_center[i]-range_factor*dl, line_center[i]+(range_factor+2)*dl]]]
		if i eq 0 then begin
			lower = line_center[i]-range_factor*dl
			if (range_factor)*dl gt 0.5*(line_center[i+1]-line_center[i]) then begin
				upper = line_center[i]+0.5*(line_center[i+1]-line_center[i])
			endif else begin
				upper = line_center[i]+(range_factor)*dl
			endelse
			range = [[range], [[lower, upper]]]
		endif
		if (i ne 0) and (i ne n_elements(line_center)-1) then begin
			if range_factor*dl gt 0.5*(line_center[i]-line_center[i-1]) then begin
				lower = line_center[i]-0.5*(line_center[i]-line_center[i-1])
			endif else begin
				lower = line_center[i]-range_factor*dl
			endelse
			if (range_factor)*dl gt 0.5*(line_center[i+1]-line_center[i]) then begin
				upper = line_center[i]+0.5*(line_center[i+1]-line_center[i])
			endif else begin
				upper = line_center[i]+(range_factor)*dl
			endelse
			range = [[range], [[lower, upper]]]
		endif
		if i eq n_elements(line_center)-1 then begin
			if range_factor*dl gt 0.5*(line_center[i]-line_center[i-1]) then begin
				lower = line_center[i]-0.5*(line_center[i]-line_center[i-1])
			endif else begin
				lower = line_center[i]-range_factor*dl
			endelse
			upper = line_center[i]+(range_factor)*dl
			range = [[range], [[lower, upper]]]
		endif
	endfor
	; Perform double Gaussian fit on blended lines
	; Modified the line list
	line_name_dg = [['o-H2O3_12-2_21','CO10-9'],['CI3P2-3P1','CO7-6'],['CI3P1-3P0','p-H2O6_24-7_17'],['13CO10-9','o-H2O3_12-3_03'],['13CO9-8','p-H2O2_02-1_11']];['p-H2O9_46-10_19','13CO13-12'],['o-H2O3_21-3_12','HCO+13-12'],
	line_center_dg = []
	range_dg = []
	line_dg = []
	excluded_line =[]
	for dg = 0, n_elements(line_name_dg[0,*])-1 do begin
		ind = where(line_name eq line_name_dg[0,dg] or line_name eq line_name_dg[1,dg])
		range_dg = [[range_dg],[min(range[*,ind]), max(range[*,ind])]]
		excluded_line = [excluded_line,line_name_dg[0,dg],line_name_dg[1,dg]]
		line_center_dg = [line_center_dg,line_center[ind]]
		for k = 0, n_elements(ind)-1 do begin
			line_dg = [[line_dg], [line_center[ind[k]], range[0,ind[k]], range[1,ind[k]]]]
		endfor
	endfor
	; After defining the proper line information for each module then go into the part that run the fitting routine at every pixel.
	for j = 0, n_elements(pixelname)-1 do begin
		if j ne 0 then filename = 0
;		if keyword_set(ssw) or keyword_set(slw) then begin
;			print, 'Fitting',pixelname[j],'...',format='(a7,x,a7,x,a3)'
;		endif else begin
;			print, 'Fitting 1D spectrum...'
;		endelse
    	; The path to the data that you want to fit.  wavelength in um and flux in Jy.
    	if not keyword_set(filename) then readcol, indir+object+'_'+pixelname[j]+'.txt', format='D,D', wl, flux,/silent
    	if keyword_set(filename) then readcol, indir+filename+'.txt', format='D,D', wl, flux, /silent
		flux = flux[sort(wl)] & wl = wl[sort(wl)]
    	; Convert the flux to appropriate unit (W/cm2/um)
		flux = flux*1d-4*c/(wl*1d-6)^2*1d-6*1d-26	
		if keyword_set(slw) then begin
			flux = flux[where(wl ge 314)]
			wl = wl[where(wl ge 314)]
		endif
		; Create a baseline pool
		; Create a wavelength array that every elements in this array can be selected as a valid point for baseline fitting
		base_mask = 0*wl
		for i = 0, n_elements(wl)-1 do begin
			valid=1
			for k = 0, n_elements(line_name)-1 do begin
				if (wl[i] ge range[0,k]) and (wl[i] le range[1,k]) then valid = valid*0
			endfor
			if valid eq 1 then base_mask[i] = 1
		endfor

		wl_basepool = wl[where(base_mask ne 0)] & flux_basepool = flux[where(base_mask ne 0)]
	
		if keyword_set(ssw) then begin
			line_name = line_name[where(line_center ge 195.013 and line_center le 303.959)]
			range = range[*,where(line_center ge 195.013 and line_center le 303.959)]
			line_center = line_center[where(line_center ge 195.013 and line_center le 303.959)]
			flux_basepool = flux_basepool[where(wl_basepool ge 195.013 and wl_basepool le 303.959)]
			wl_basepool = wl_basepool[where(wl_basepool ge 195.013 and wl_basepool le 303.959)]
		endif
		if keyword_set(slw) then begin
			line_name = line_name[where(line_center ge 314.078 and line_center le 670.708)]
			range = range[*,where(line_center ge 314.078 and line_center le 670.708)]
			line_center = line_center[where(line_center ge 314.078 and line_center le 670.708)]
			flux_basepool = flux_basepool[where(wl_basepool ge 314.078 and wl_basepool le 670.708)]
			wl_basepool = wl_basepool[where(wl_basepool ge 314.078 and wl_basepool le 670.708)]
		endif
		; The path to the output file for print out the fitting result.
		if not keyword_set(filename) then name = outdir+object+'_'+pixelname[j]+'_lines'
		if keyword_set(filename) then name = outdir + filename +'_lines'
		; if keyword_set(linescan) then name = name+'_LS'
		; if keyword_set(localbaseline) then name = name+''
		; if keyword_set(fixed_width) then name = name+'_fixwidth'
		openw, firstfit, name+'.txt', /get_lun
		if not keyword_set(current_pix) then begin
    		printf, firstfit, format='(16(a16,2x))',$
    			'Line','LabWL (um)','ObsWL (um)','Sig_Cen (um)','Str(W/cm2'+unit+')','Sig_str(W/cm2'+unit+')','FWHM (um)','Sig_FWHM (um)','Base(W/cm2/um'+unit+')','SNR','E_u (K)','A (s-1)','g','RA(deg)','Dec(deg)','Blend'
    	endif else begin
    		printf, firstfit, format='(17(a16,2x))',$
    			'Line','LabWL (um)','ObsWL (um)','Sig_Cen (um)','Str(W/cm2'+unit+')','Sig_str(W/cm2'+unit+')','FWHM (um)','Sig_FWHM (um)','Base(W/cm2/um'+unit+')','SNR','E_u (K)','A (s-1)','g','RA(deg)','Dec(deg)','Pixel_No.','Blend'
    	endelse
		for i = 0, n_elements(line_name)-1 do begin
			if (keyword_set(double_gauss)) and ((where(excluded_line eq line_name[i]))[0] ne -1) then continue
        	; select the baseline
        	; Using the localbaseline setting as the default
			dlb = localbaseline*dl
			wl_diff = wl[1:-1]-wl[0:-2]
			numb = ceil(dlb/(wl_diff[where(wl ge line_center[i])])[0])
			left = where(wl_basepool lt range[0,i] and wl_basepool ge min(wl)) & right = where(wl_basepool gt range[1,i] and wl_basepool le max(wl))
			if n_elements(left) gt numb then left = left[n_elements(left)-1-numb:n_elements(left)-1]
			if n_elements(right) gt numb then right = right[0:numb-1]
            if left[0] ne -1 and right[0] ne -1 then begin
            	wlb = [wl_basepool[left], wl_basepool[right]] & fluxb = [flux_basepool[left], flux_basepool[right]]
                base_range = [wl_basepool[left[0]], wl_basepool[left[n_elements(left)-1]], wl_basepool[right[0]], wl_basepool[right[n_elements(right)-1]]]
                indl = where(wl gt base_range[0] and wl lt base_range[3])
                wll = wl[indl] & fluxl = flux[indl]
            endif 
            if left[0] eq -1 and right[0] ne -1 then begin
                wlb = [wl_basepool[right]] & fluxb = [flux_basepool[right]]
                base_range = [wl_basepool[right[0]], wl_basepool[right[0]],wl_basepool[right[0]],wl_basepool[right[n_elements(right)-1]]]
                indl = where(wl gt min(wl) and wl lt base_range[2])
                wll = wl[indl] & fluxl = flux[indl]
            endif
            if left[0] ne -1 and right[0] eq -1 then begin
                wlb = [wl_basepool[left]] & fluxb = [flux_basepool[left]]
                base_range = [wl_basepool[left[0]], wl_basepool[left[n_elements(left)-1]],wl_basepool[left[n_elements(left)-1]],wl_basepool[left[n_elements(left)-1]]]
                indl = where(wl gt base_range[0] and wl lt max(wl))
                wll = wl[indl] & fluxl = flux[indl]
            endif

			; fit the baseline and return the baseline parameter in 'base_para'
			; 7 % of flux uncertainty in SPIRE spectrometer (Observer manual 5.3.6)
			; use the plot_base feature to plot the actual spectrum (with line) here
			plot_base = [[wll],[fluxl]]
			fit_line, pixelname[j], line_name[i], wlb, fluxb, std=abs(fluxb)*0.07, status, errmsg, cen_wl, sig_cen_wl, str, sig_str, fwhm, sig_fwhm, base_para, snr, /baseline, outdir=plotdir,no_plot=no_plot, plot_base=plot_base,/spire
			
			; extract the wave and flux for plottng that is for better visualization of the fitting results.
			ind_plot = where(wl gt base_range[0]-5*dl and wl lt base_range[3]+5*dl)
			plot_wl = wl[ind_plot] & plot_flux = flux[ind_plot]
			plot_base = [[wlb],[fluxb]]
			; Subtract the baseline from the spectrum
			; First, calculate the baseline
			; base = base_para[0]*wll +base_para[1]                       ;use 1st order polynomial
			base = base_para[0]*wll^2+base_para[1]*wll+base_para[2]      ;use 2nd order polynomial
			; Subtract
			fluxx = fluxl - base
			line = [line_center[i],range[0,i],range[1,i]]                      ;[line_center, line profile lower limit, line profile upper limit]
			; Fitting part
			; Different fitting keyword for fixed width and test arguement
			if keyword_set(fixed_width) then begin
				if keyword_set(test) then fit_line, pixelname[j], line_name[i], wll, fluxx, std=abs(fluxx)*0.07, status, errmsg, cen_wl, sig_cen_wl, str, sig_str, fwhm, sig_fwhm, base_para, snr, line, plot_base=plot_base,$
        										/single_gauss, /test, outdir=plotdir, noiselevel=noiselevel, /fixed_width, base_range=base_range, brightness=brightness,no_plot=no_plot,/spire
				if not keyword_set(test) then fit_line, pixelname[j], line_name[i], wll, fluxx, std=abs(fluxx)*0.07, status, errmsg, cen_wl, sig_cen_wl, str, sig_str, fwhm, sig_fwhm, base_para, snr, line, plot_base=plot_base,$
										       /single_gauss,outdir=plotdir, noiselevel=noiselevel, /fixed_width, base_range=base_range, brightness=brightness,no_plot=no_plot,/spire
			endif else begin
        		if keyword_set(test) then fit_line, pixelname[j], line_name[i], wll, fluxx, std=abs(fluxx)*0.07, status, errmsg, cen_wl, sig_cen_wl, str, sig_str, fwhm, sig_fwhm, base_para, snr, line, plot_base=plot_base,$
        						      /single_gauss, /test, outdir=plotdir, noiselevel=noiselevel, base_range=base_range, brightness=brightness,no_plot=no_plot,/spire
				if not keyword_set(test) then fit_line, pixelname[j], line_name[i], wll, fluxx, std=abs(fluxx)*0.07, status, errmsg, cen_wl, sig_cen_wl, str, sig_str, fwhm, sig_fwhm, base_para, snr, line, plot_base=plot_base,$
										  /single_gauss,outdir=plotdir, noiselevel=noiselevel, base_range=base_range, brightness=brightness,no_plot=no_plot,/spire
			endelse
			; Print the fittng result into text file
			if status le 0 then begin
            	printf, firstfit, format = '((a16,2X),(a50))', line_name[i], errmsg
			endif else begin
            	read_line_ref, line_name[i], E_u, A, g
				base_str = interpol(base, wll, cen_wl);*fwhm
				; Blended lines classification
				blue_blend = 0 & red_blend = 0
				if i eq 0 then begin
            		if line_center[i+1]-cen_wl lt fwhm then red_blend = 1
				endif
				if i ne 0 and i ne n_elements(line_center)-1 then begin
            		if cen_wl-line_center[i-1] lt fwhm then blue_blend = 2
					if line_center[i+1]-cen_wl lt fwhm then red_blend  = 1
				endif
				if i eq n_elements(line_center)-1 then begin
            		if cen_wl-line_center[i-1] lt fwhm then blue_blend = 2
				endif
				blend_flag = red_blend+blue_blend
				if blend_flag eq 0 then blend_msg = 'x'
				if blend_flag eq 1 then blend_msg = 'Red'
				if blend_flag eq 2 then begin
            		blend_msg = 'Blue'
            		blend_flag = 3
				endif
				if blend_flag eq 3 then begin
            		blend_msg = 'Red/Blue'
            		blend_flag = 2
				endif
				; blend flag = 0: no blend; blend_flag = 1: Red blend; blend_flag = 2: Red/Blue blend; blend_flag = 3: Blue blend.
				;
				if not keyword_set(current_pix) then begin
					printf, firstfit, format = '((a16,2X),9(g16.10,2X),2(g16.10,2X),(i16,2x),2(g16.10,2X),(a16,2x))',$
						line_name[i], line_center[i], cen_wl, sig_cen_wl, str, sig_str, fwhm, sig_fwhm, base_str,snr, E_u, A, g, ra[j], dec[j], blend_msg
				endif else begin
					printf, firstfit, format = '((a16,2X),9(g16.10,2X),2(g16.10,2X),(i16,2x),2(g16.10,2X),2(a16,2x))',$
						line_name[i], line_center[i], cen_wl, sig_cen_wl, str, sig_str, fwhm, sig_fwhm, base_str,snr, E_u, A, g, ra[j], dec[j], pixelname[j], blend_msg
				endelse
			endelse 
		endfor
		; Double Gaussian fit
		if keyword_set(double_gauss) then begin
			for i = 0, n_elements(line_name_dg[0,*])-1 do begin
				mean_wl = (line_center_dg[2*i]+line_center_dg[2*i+1])/2
				if (min(wl) gt mean_wl) or (max(wl) lt mean_wl) then continue
				dlb = localbaseline*dl
				wl_diff = wl[1:-1]-wl[0:-2]
				numb = ceil(dlb/(wl_diff[where(wl ge line_center_dg[2*i])])[0])
				left = where(wl_basepool lt range_dg[0,i] and wl_basepool ge min(wl)) & right = where(wl_basepool gt range_dg[1,i] and wl_basepool le max(wl))
				if n_elements(left) gt numb then left = left[n_elements(left)-1-numb:n_elements(left)-1]
				if n_elements(right) gt numb then right = right[0:numb-1]
				if left[0] ne -1 and right[0] ne -1 then begin
            		wlb = [wl_basepool[left], wl_basepool[right]] & fluxb = [flux_basepool[left], flux_basepool[right]]
					base_range = [wl_basepool[left[0]], wl_basepool[left[n_elements(left)-1]], wl_basepool[right[0]], wl_basepool[right[n_elements(right)-1]]]
					indl = where(wl gt base_range[0] and wl lt base_range[3])
					wll = wl[indl] & fluxl = flux[indl]
				endif 
				if left[0] eq -1 and right[0] ne -1 then begin
                	wlb = [wl_basepool[right]] & fluxb = [flux_basepool[right]]
					base_range = [wl_basepool[right[0]], wl_basepool[right[0]],wl_basepool[right[0]],wl_basepool[right[n_elements(right)-1]]]
					indl = where(wl gt min(wl) and wl lt base_range[2])
					wll = wl[indl] & fluxl = flux[indl]
				endif
				if left[0] ne -1 and right[0] eq -1 then begin
					wlb = [wl_basepool[left]] & fluxb = [flux_basepool[left]]
					base_range = [wl_basepool[left[0]], wl_basepool[left[n_elements(left)-1]],wl_basepool[left[n_elements(left)-1]],wl_basepool[left[n_elements(left)-1]]]
					indl = where(wl gt base_range[0] and wl lt max(wl))
					wll = wl[indl] & fluxl = flux[indl]
				endif
				; use the plot_base feature to plot the actual spectrum (with line) here
				plot_base = [[wll],[fluxl]]
				fit_line, pixelname[j], line_name_dg[2*i]+'+'+line_name_dg[2*i+1], wlb, fluxb, std=abs(fluxb)*0.07, status, errmsg, cen_wl, sig_cen_wl, str, sig_str, fwhm, sig_fwhm, base_para, snr, /baseline, outdir=plotdir,no_plot=no_plot,plot_base=plot_base,/spire
				; extract the wave and flux for plottng that is for better visualization of the fitting results.
				ind_plot = where(wl gt base_range[0]-5*dl and wl lt base_range[3]+5*dl)
				plot_wl = wl[ind_plot] & plot_flux = flux[ind_plot]
				plot_base = [[wlb],[fluxb]]
				; Substract the baseline from the spectrum
				; First, calculate the baseline
				; base = base_para[0]*wll +base_para[1]                       ;use 1st order polynomial
				base = base_para[0]*wll^2+base_para[1]*wll+base_para[2]      ;use 2nd order polynomial
				; Subtract
				fluxx = fluxl - base
				line = [line_dg[*,2*i],line_dg[*,2*i+1]]
				; line = [line_center_dg[0,i],range_dg_4[0,i],range]                      ;[line_center, line profile lower limit, line profile upper limit]
				; Fitting part
				; Different fitting keyword for fixed width and test arguement
				fit_line,pixelname[j],line_name_dg[2*i]+'+'+line_name_dg[2*i+1],wll,fluxx,std=abs(fluxx)*0.07,status,errmsg,cen_wl,sig_cen_wl,str,sig_str,fwhm,sig_fwhm,base_para,snr,line,/double_gauss,outdir=plotdir,$
					 noiselevel=noiselevel,base_range=base_range,plot_base=plot_base,/fix_dg,/spire,/fixed_width,brightness=brightness
				if status eq 0 then begin
					printf, firstfit, format = '((a16,2X),(a50))', line_name_dg[2*i]+'_'+line_name_dg[2*i+1], errmsg
				endif else begin
					; Making sure the line classification is correct
					i1 = where(line_name eq line_name_dg[2*i])
					i2 = where(line_name eq line_name_dg[2*i+1])
					if (abs(line_center[i1]-cen_wl[0]) gt abs(line_center[i1]-cen_wl[1])) and (abs(line_center[i2]-cen_wl[1]) gt abs(line_center[i2]-cen_wl[0])) then begin
						print, 'Line misplacement found in '+line_name_dg[2*i]+'+'+line_name_dg[2*i+1]
						cen_wl = reverse(cen_wl)
						sig_cen_wl = reverse(sig_cen_wl)
						str = reverse(str)
						sig_str = reverse(sig_str)
						fwhm = reverse(fwhm)
						sig_fwhm = reverse(sig_fwhm)
						snr = reverse(snr)
					endif
					read_line_ref, line_name_dg[2*i], E_u1, A1, g1
					read_line_ref, line_name_dg[2*i+1], E_u2, A2, g2
					E_u = [E_u1,E_u2]
					A = [A1,A2]
					g = [g1,g2]
					base_str = [interpol(base, wll, cen_wl[0]), interpol(base, wll, cen_wl[1])]
					blend_msg = 'x'
					if not keyword_set(current_pix) then begin
						printf, firstfit, format = '((a16,2X),9(g16.10,2X),2(g16.10,2X),(i16,2x),2(g16.10,2X),(a16,2x))',$
							line_name_dg[2*i], line[0], cen_wl[0], sig_cen_wl[0], str[0], sig_str[0], fwhm[0], sig_fwhm[0], base_str[0],snr[0], E_u[0], A[0], g[0], ra[j], dec[j], blend_msg
						printf, firstfit, format = '((a16,2X),9(g16.10,2X),2(g16.10,2X),(i16,2x),2(g16.10,2X),(a16,2x))',$
							line_name_dg[2*i+1], line[3], cen_wl[1], sig_cen_wl[1], str[1], sig_str[1], fwhm[1], sig_fwhm[1], base_str[1],snr[1], E_u[1], A[1], g[1], ra[j], dec[j], blend_msg
					endif else begin
						printf, firstfit, format = '((a16,2X),9(g16.10,2X),2(g16.10,2X),(i16,2x),2(g16.10,2X),2(a16,2x))',$
							line_name_dg[2*i], line[0], cen_wl[0], sig_cen_wl[0], str[0], sig_str[0], fwhm[0], sig_fwhm[0], base_str[0],snr[0], E_u[0], A[0], g[0], ra[j], dec[j], pixelname[j], blend_msg
						printf, firstfit, format = '((a16,2X),9(g16.10,2X),2(g16.10,2X),(i16,2x),2(g16.10,2X),2(a16,2x))',$
							line_name_dg[2*i+1], line[3], cen_wl[1], sig_cen_wl[1], str[1], sig_str[1], fwhm[1], sig_fwhm[1], base_str[1],snr[1], E_u[1], A[1], g[1], ra[j], dec[j], pixelname[j], blend_msg
					endelse
				endelse
			endfor
		endif
		free_lun, firstfit
		close, firstfit
		; Blended lines labeling and pick out the most possible line
		; print, '--> Start identifying the blended region by standard criterion and make suggestions if there is only one line present'
		; if not keyword_set(filename) then filename = object+'_'+pixelname[j]
		; name = filename+'_lines'
		; if keyword_set(linescan) then name = name+'_LS'
		; if keyword_set(localbaseline) then name = name+''
		; if keyword_set(fixed_width) then name = name+'_fixwidth'
		if not keyword_set(current_pix) then begin
    		readcol, name+'.txt', format='A,D,D,D,D,D,D,D,D,D,D,D,I,D,D,A', $
    			line_name_n, lab_wl_n, cen_wl_n, sig_cen_wl_n, str_n, sig_str_n, fwhm_n, sig_fwhm_n, base_str_n, snr_n, E_u_n, A_n, g_n, ra_n, dec_n, blend_flag_n, /silent, skipline=1
		endif else begin
    		readcol, name+'.txt', format='A,D,D,D,D,D,D,D,D,D,D,D,I,D,D,A,A', $
    			line_name_n, lab_wl_n, cen_wl_n, sig_cen_wl_n, str_n, sig_str_n, fwhm_n, sig_fwhm_n, base_str_n, snr_n, E_u_n, A_n, g_n, ra_n, dec_n, pix_n, blend_flag_n, /silent, skipline=1
		endelse
		blend_group = []
		blend_subgroup = []
		blend_msg_all = []
		possible_all = []
		for line = 0, n_elements(line_name_n)-1 do begin
			if (keyword_set(double_gauss)) and ((where(line_name_dg eq line_name_n[line]))[0] ne -1) then begin
				blend_msg = 'DoubleGaussian'
				blend_msg_all = [blend_msg_all,blend_msg]
				continue
			endif
			; Blended lines classification
			blue_blend = 0 & red_blend = 0
			if line eq 0 then begin
            	if abs(cen_wl_n[line+1]-cen_wl_n[line]) lt fwhm_n[line] then red_blend = 1
			endif
			if line ne 0 and line ne n_elements(line_name_n)-1 then begin
            	if abs(cen_wl_n[line]-cen_wl_n[line-1]) lt fwhm_n[line] then blue_blend = 2
				if abs(cen_wl_n[line+1]-cen_wl_n[line]) lt fwhm_n[line] then red_blend  = 1
			endif
			if line eq n_elements(line_name_n)-1 then begin
            	if abs(cen_wl_n[line]-cen_wl_n[line-1]) lt fwhm_n[line] then blue_blend = 2
			endif
			blend_flag = red_blend+blue_blend
			if blend_flag eq 0 then blend_msg = 'x'
			if blend_flag eq 1 then blend_msg = 'Red'
			if blend_flag eq 2 then begin
            	blend_msg = 'Blue'
				blend_flag = 3
			endif
			if blend_flag eq 3 then begin
            	blend_msg = 'Red/Blue'
				blend_flag = 2
			endif
			blend_msg_all = [blend_msg_all,blend_msg]			
			if n_elements(blend_subgroup) eq 0 then group_flag = 0
			if blend_flag ge group_flag then begin
				if blend_flag eq 0 then continue
				blend_subgroup = [[blend_subgroup],[line_name_n[line],string(E_u_n[line])]]
				group_flag = blend_flag
			endif else begin
				possible_line = blend_subgroup[0,where(float(blend_subgroup[1,*]) eq min(float(blend_subgroup[1,*])))]
				if n_elements(possible_line) gt 1 then begin
					A_dum = A_n[where(line_name_n eq possible_line)]
					possible_line = possible_line[(where(line_name_n eq possible_line))[where(A_dum eq max(A_dum))]]
				endif
				blend_subgroup = []
				possible_all = [possible_all, possible_line]
				if blend_flag ne 0 then begin
					blend_subgroup = [[blend_subgroup],[line_name_n[line],string(E_u_n[line])]]
					group_flag = blend_flag
				endif
			endelse	
		endfor
		; Artificially remove CI3P2-3P1 from possible line and add CO7-6
		; if (where(possible_all eq 'CO7-6'))[0] eq -1 then possible_all = [possible_all,'CO7-6']
		; if (where(possible_all eq 'CI3P2-3P1'))[0] ne -1 then possible_all = possible_all[where(possible_all ne 'CI3P2-3P1')]
		; 
		openw, firstfit, name+'.txt', /get_lun
		if not keyword_set(current_pix) then begin
			printf, firstfit, format='(17(a16,2x))', $
    			'Line','LabWL(um)','ObsWL(um)','Sig_Cen(um)','Str(W/cm2'+unit+')','Sig_str(W/cm2'+unit+')','FWHM(um)','Sig_FWHM(um)','Base(W/cm2/um'+unit+')','SNR','E_u(K)','A(s-1)','g','RA(deg)','Dec(deg)','Blend','Validity'
    	endif else begin
    		printf, firstfit, format='(18(a16,2x))', $
    			'Line','LabWL(um)','ObsWL(um)','Sig_Cen(um)','Str(W/cm2'+unit+')','Sig_str(W/cm2'+unit+')','FWHM(um)','Sig_FWHM(um)','Base(W/cm2/um'+unit+')','SNR','E_u(K)','A(s-1)','g','RA(deg)','Dec(deg)','Pixel_No.','Blend','Validity'
    	endelse
		for line = 0, n_elements(line_name_n)-1 do begin
    		lowest = '0'
			if (where(possible_all eq line_name_n[line]))[0] ne -1 then lowest = '1'
			if (blend_msg_all[line] eq 'x') or (blend_msg_all[line] eq 'DoubleGaussian') then lowest = '1'
			if finite(snr_n[line],/nan) eq 1 then lowest = '0'
			if (sig_cen_wl_n[line] eq -999) or (sig_fwhm_n[line] eq -999) then lowest = '0'
			if not keyword_set(current_pix) then begin
				printf, firstfit, format = '((a16,2X),9(g16.10,2X),2(g16.10,2X),(i16,2x),2(g16.10,2X),2(a16,2x))',$
            		line_name_n[line], lab_wl_n[line], cen_wl_n[line], sig_cen_wl_n[line], str_n[line], sig_str_n[line], fwhm_n[line], sig_fwhm_n[line], base_str_n[line],snr_n[line],$
					E_u_n[line], A_n[line], g_n[line], ra_n[line], dec_n[line], blend_msg_all[line], lowest
				if keyword_set(print_all) and not keyword_set(global_noise) then begin
					openw, gff, print_all+'.txt',/append,/get_lun
					printf, gff, format = '(2(a16,2X),9(g16.10,2X),2(g16.10,2X),(i16,2x),2(g16.10,2X),2(a16,2x))',$
            			object, line_name_n[line], lab_wl_n[line], cen_wl_n[line], sig_cen_wl_n[line], str_n[line], sig_str_n[line], fwhm_n[line], sig_fwhm_n[line], base_str_n[line],snr_n[line],$
						E_u_n[line], A_n[line], g_n[line], ra_n[line], dec_n[line], blend_msg_all[line], lowest
					free_lun, gff
					close, gff
				endif
			endif else begin
				printf, firstfit, format = '((a16,2X),9(g16.10,2X),2(g16.10,2X),(i16,2x),2(g16.10,2X),3(a16,2x))',$
            		line_name_n[line], lab_wl_n[line], cen_wl_n[line], sig_cen_wl_n[line], str_n[line], sig_str_n[line], fwhm_n[line], sig_fwhm_n[line], base_str_n[line],snr_n[line],$
					E_u_n[line], A_n[line], g_n[line], ra_n[line], dec_n[line], pix_n[line], blend_msg_all[line], lowest
				if keyword_set(print_all) and not keyword_set(global_noise) then begin
					openw, gff, print_all+'.txt',/append,/get_lun
					printf, gff, format = '(2(a16,2X),9(g16.10,2X),2(g16.10,2X),(i16,2x),2(g16.10,2X),3(a16,2x))',$
            			object, line_name_n[line], lab_wl_n[line], cen_wl_n[line], sig_cen_wl_n[line], str_n[line], sig_str_n[line], fwhm_n[line], sig_fwhm_n[line], base_str_n[line],snr_n[line],$
						E_u_n[line], A_n[line], g_n[line], ra_n[line], dec_n[line], pix_n[line], blend_msg_all[line], lowest
					free_lun, gff
					close, gff
				endif
			endelse
		endfor
		free_lun, firstfit
		close, firstfit
		; Plot the line subtracted spectrum
		if not keyword_set(global_noise) then begin
    		; name = filename+'_lines'
			if keyword_set(linescan) then name = name+'_LS'
			; if keyword_set(localbaseline) then name = name+''
			; if keyword_set(fixed_width) then name = name+'_fixwidth'
			if not keyword_set(current_pix) then begin
    			readcol, name+'.txt', format='A,D,D,D,D,D,D,D,D,D,D,D,I,D,D,A,I', $
    				line_name_n, lab_wl_n, cen_wl_n, sig_cen_wl_n, str_n, sig_str_n, fwhm_n, sig_fwhm_n, base_str_n, snr_n, E_u_n, A_n, g_n, ra_n, dec_n, blend_flag_n, lowest_E_n, /silent
			endif else begin
    			readcol, name+'.txt', format='A,D,D,D,D,D,D,D,D,D,D,D,I,D,D,A,A,I', $
    				line_name_n, lab_wl_n, cen_wl_n, sig_cen_wl_n, str_n, sig_str_n, fwhm_n, sig_fwhm_n, base_str_n, snr_n, E_u_n, A_n, g_n, ra_n, dec_n, pix_n, blend_flag_n, lowest_E_n, /silent
			endelse
			flux_sub = flux
			for line = 0, n_elements(line_name_n)-1 do begin
    			if abs(snr_n[line]) ge noiselevel-2.0 then begin
					if (blend_flag_n[line] ne 'x') and (lowest_E_n[line] ne 1) then continue
					ind = where((wl gt cen_wl_n[line]-2*fwhm_n[line]) and (wl lt cen_wl_n[line]+2*fwhm_n[line]))
					wl_n = wl[ind]
					line_profile = gauss(wl_n, [2.354*str_n[line]/fwhm_n[line]/(2*!PI)^0.5, cen_wl_n[line], fwhm_n[line]/2.354]);+base_str[line]
					flux_sub[ind] = flux_sub[ind] - line_profile
					if keyword_set(plot_subtraction) then begin
    					set_plot,'ps'
						!p.font=0
						loadct,12,/silent
						device, filename=plotdir+'line_subtracted_'+line_name[line]+'.eps',/helvetica,/portrait,/encapsulated,isolatin=1,font_size=12,decomposed=0,/color
						!p.thick=3 & !x.thick=3 & !y.thick=3	
						plot, wl_n, flux[ind], xtitle = 'Wavelength (!9m!3m)', ytitle = 'Flux (10!u-22!n W/cm!u2!n/!9m!3m)'
						oplot, wl_n, line_profile+base_str_n[line], color=120 ;purple
						oplot, wl_n, flux_sub[ind], color=200 ;red
						device, /close_file, decomposed=1
						!p.multi=0
					endif
				endif
			endfor
			set_plot, 'ps'
			!p.font = 0
			loadct,12,/silent
			; if keyword_set(fixed_width) then msg = '_fixed_width'
			; if not keyword_set(fixed_width) then msg =''
			msg = ''
			device, filename = plotdir+'spectrum_line_subtracted_'+filename+msg+'.eps', /helvetica, /portrait, /encapsulated, isolatin = 1, font_size = 12, decomposed = 0, /color
			!p.thick=2 & !x.thick=3 & !y.thick=3
			trim1 = where(wl lt 100) & trim2 = where(wl ge 100)
			plot, wl, flux/1e-22, xtitle = '!3Wavelength (!9m!3m)', ytitle = ylabel,/nodata,position=[0.15,0.1,0.95,0.95]
			if trim1[0] ne -1 then begin
				oplot, wl[trim1], flux[trim1]/1e-22
				oplot, wl[trim1], flux_sub[trim1]/1e-22, color=100
			endif
			if trim2[0] ne -1 then begin
				oplot, wl[trim2], flux[trim2]/1e-22
				oplot, wl[trim2], flux_sub[trim2]/1e-22, color=100
			endif
			; oplot, wl, continuum/1e-22, color=50
			; al_legend,['Data','lines_subtracted','Data_smooth','(lines_subtracted)_smooth', 'flat/featureless'],textcolors=[0,200,50,100,10],/right
			al_legend,['Data','lines_subtracted'],textcolors=[0,100],/right
			al_legend,[object],textcolors=[0],/left
			device, /close_file, decomposed = 1
			!p.multi = 0
		endif
		
		
		; Construct the smooth/featureless spectrum to calculate the noise properly
		if keyword_set(global_noise) then begin
			print, '---> Re-calculating the noise level...'
			; name = outdir+object+'_'+pixelname[j]+'_lines'
			; if keyword_set(fixed_width) then name = name+'_fixwidth'
			if not keyword_set(current_pix) then begin
				readcol, name+'.txt', format='A,D,D,D,D,D,D,D,D,D,D,D,I,D,D,A,I',$
					line_name_n, lab_wl_n, cen_wl_n, sig_cen_wl_n, str_n, sig_str_n, fwhm_n, sig_fwhm_n, base_str_n, snr_n, E_u_n, A_n, g_n, ra_n, dec_n, blend_flag_n, lowest_E_n, /silent
			endif else begin
				readcol, name+'.txt', format='A,D,D,D,D,D,D,D,D,D,D,D,I,D,D,A,A,I',$
					line_name_n, lab_wl_n, cen_wl_n, sig_cen_wl_n, str_n, sig_str_n, fwhm_n, sig_fwhm_n, base_str_n, snr_n, E_u_n, A_n, g_n, ra_n, dec_n, pix_n, blend_flag_n, lowest_E_n, /silent
			endelse

			flux_sub = flux
			for line = 0, n_elements(line_name_n)-1 do begin
    			if snr_n[line] ge noiselevel-2.0 then begin
    				if blend_flag_n[line] ne 'x' and lowest_E_n[line] ne 1 then continue
    				ind = where((wl gt cen_wl_n[line]-5*fwhm_n[line]) and (wl lt cen_wl_n[line]+5*fwhm_n[line]))
					wl_n = wl[ind]
					line_profile = gauss(wl_n, [2.354*str_n[line]/fwhm_n[line]/(2*!PI)^0.5, cen_wl_n[line], fwhm_n[line]/2.354]);+base_str[line]
					flux_sub[ind] = flux_sub[ind] - line_profile
					if keyword_set(plot_subtraction) then begin
						set_plot,'ps'
						!p.font=0
						loadct,12,/silent
						device, filename=plotdir+'line_subtracted_'+pixelname[j]+'_'+line_name[line]+'.eps',/helvetica,/portrait,/encapsulated,isolatin=1,font_size=12,decomposed=0,/color
						!p.thick=3 & !x.thick=3 & !y.thick=3
						plot, wl_n, flux[ind]/1e-22, xtitle = 'Wavelength (!9m!3m)', ytitle = ylabel
						oplot, wl_n, (line_profile+base_str_n[line])/1e-22, color=120 ;purple
						oplot, wl_n, flux_sub[ind]/1e-22, color=200 ;red
						device, /close_file, decomposed=1
						!p.multi=0
					endif					
				endif
			endfor

			; Smooth the line subtracted spectrum
			sbin=20
			spec_continuum_smooth,wl,flux_sub,continuum_sub, continuum_sub_error,w1 = min(wl), w2 = max(wl), sbin=sbin,upper=0.9,lower=0.9
			spec_continuum_smooth,wl,flux,continuum, continuum_error,w1 = min(wl), w2 = max(wl), sbin=sbin,upper=0.9, lower=0.9
			flat_noise = flux_sub - continuum_sub
			if keyword_set(continuum_sub) then begin
    			openw, sed, name+'_continuum.txt', /get_lun
    			if keyword_set(fx) then printf, sed, format='(2(a16,2x))','Wave (um)','Flux (Jy)'
    			if keyword_set(brightness) then printf, sed, format='(2(a16,2x))','Wave (um)','I_nu (Jy/as2)'
				print_continuum_sub = continuum_sub*1d26*1d6*(wl*1d-6)^2/c*1d4
				for k =0, n_elements(wl)-1 do printf, sed, format='(2(g16.6,2x))', wl[k],print_continuum_sub[k]
				free_lun, sed
				close, sed
			endif
			if keyword_set(flat) then begin
    			openw, flat_sed, name+'_flat_spectrum.txt',/get_lun
				if keyword_set(fx) then printf, sed, format='(2(a16,2x))','Wave (um)','Flux (Jy)'
    			if keyword_set(brightness) then printf, sed, format='(2(a16,2x))','Wave (um)','I_nu (Jy/as2)'
				flat = (flux - continuum_sub) *1d26*1d6*(wl*1d-6)^2/c*1d4
				for k =0, n_elements(wl)-1 do printf, flat_sed, format='(2(g16.6,2x))',wl[k],flat[k]
				free_lun, flat_sed
				close,flat_sed
			endif
			cleanplot,/silent
			; Plot the results
			set_plot, 'ps'
			!p.font = 0
			loadct,12,/silent
			; if keyword_set(fixed_width) then msg = '_fixed_width'
			; if not keyword_set(fixed_width) then msg =''
			msg = ''
			device, filename = plotdir+'spectrum_line_subtracted_'+pixelname[j]+msg+'.eps', /helvetica, /portrait, /encapsulated, isolatin = 1, font_size = 12, decomposed = 0, /color
			!p.thick=2 & !x.thick=3 & !y.thick=3
			plot, wl, flux/1e-22, xtitle = 'Wavelength (!9m!3m)', ytitle = ylabel, ystyle=2, position=[0.15,0.1,0.95,0.95]
			; oplot, wl, flux_sub/1e-22, color=200
			oplot, wl, continuum_sub/1e-22, color=100
			oplot, wl, flat_noise/1e-22+min(flux)/1e-22, color=10
			; al_legend,['Data','lines_subtracted','(lines_subtracted)_smooth', 'flat/featureless'],textcolors=[0,200,100,10],/right
			al_legend,['data','continuum','flat/featureless'],textcolors=[0,100,10],/right
			al_legend,[object+' '+plot_pixelname[j]],textcolors= [0],/left
			device, /close_file, decomposed = 1
			cleanplot,/silent
			!p.multi = 0
			; The path to the output file for print out the fitting result.
			; name = outdir+object+'_'+pixelname[j]+'_lines'
			; if keyword_set(linescan) then name = name+'_LS'
			; if keyword_set(localbaseline) then name = name+''
			; if keyword_set(fixed_width) then name = name+'_fixwidth'
			; openw, secondfit, name+'_global_noise.txt', /get_lun
			openw, secondfit, name+'.txt', /get_lun
			if not keyword_set(current_pix) then begin
				printf, secondfit, format='(16(a16,2x))',$
    				'Line','LabWL (um)','ObsWL (um)','Sig_Cen (um)','Str(W/cm2'+unit+')','Sig_str(W/cm2'+unit+')','FWHM (um)','Sig_FWHM (um)','Base(W/cm2/um'+unit+')','SNR','E_u (K)','A (s-1)','g','RA(deg)','Dec(deg)','Blend'
			endif else begin
				printf, secondfit, format='(17(a16,2x))',$
    			'Line','LabWL (um)','ObsWL (um)','Sig_Cen (um)','Str(W/cm2'+unit+')','Sig_str(W/cm2'+unit+')','FWHM (um)','Sig_FWHM (um)','Base(W/cm2/um'+unit+')','SNR','E_u (K)','A (s-1)','g','RA(deg)','Dec(deg)','Pixel_No.','Blend'
			endelse
    		
			for i = 0, n_elements(line_name)-1 do begin
				if (keyword_set(double_gauss)) and ((where(excluded_line eq line_name[i]))[0] ne -1) then continue
        		; select the baseline
				; Using the localbaseline setting as the default
				dlb = localbaseline*dl
				wl_diff = wl[1:-1]-wl[0:-2]
				numb = ceil(dlb/(wl_diff[where(wl ge line_center[i])])[0])
			
				left = where(wl_basepool lt range[0,i] and wl_basepool ge min(wl)) & right = where(wl_basepool gt range[1,i] and wl_basepool le max(wl))
				if n_elements(left) gt numb then left = left[n_elements(left)-1-numb:n_elements(left)-1]
				if n_elements(right) gt numb then right = right[0:numb-1]
				if left[0] ne -1 and right[0] ne -1 then begin
            		wlb = [wl_basepool[left], wl_basepool[right]] & fluxb = [flux_basepool[left], flux_basepool[right]]
					base_range = [wl_basepool[left[0]], wl_basepool[left[n_elements(left)-1]], wl_basepool[right[0]], wl_basepool[right[n_elements(right)-1]]]
					indl = where(wl gt base_range[0] and wl lt base_range[3])
					wll = wl[indl] & fluxl = flux[indl]
				endif 
				if left[0] eq -1 and right[0] ne -1 then begin
                	wlb = [wl_basepool[right]] & fluxb = [flux_basepool[right]]
					base_range = [wl_basepool[right[0]], wl_basepool[right[0]],wl_basepool[right[0]],wl_basepool[right[n_elements(right)-1]]]
					indl = where(wl gt min(wl) and wl lt base_range[2])
					wll = wl[indl] & fluxl = flux[indl]
				endif
				if left[0] ne -1 and right[0] eq -1 then begin
                	wlb = [wl_basepool[left]] & fluxb = [flux_basepool[left]]
					base_range = [wl_basepool[left[0]], wl_basepool[left[n_elements(left)-1]],wl_basepool[left[n_elements(left)-1]],wl_basepool[left[n_elements(left)-1]]]
					indl = where(wl gt base_range[0] and wl lt max(wl))
					wll = wl[indl] & fluxl = flux[indl]
				endif
				; use the plot_base feature to plot the actual spectrum (with line) here
				plot_base = [[wll],[fluxl]]
				; fit the baseline and return the baseline parameter in 'base_para'
				fit_line, pixelname[j], line_name[i], wlb, fluxb, std=abs(fluxb)*0.07, status, errmsg, cen_wl, sig_cen_wl, str, sig_str, fwhm, sig_fwhm, base_para, snr, /baseline, outdir=plotdir,no_plot=no_plot,plot_base=plot_base,/spire
				; extract the wave and flux for plottng that is for better visualization of the fitting results.
				ind_plot = where(wl gt base_range[0]-5*dl and wl lt base_range[3]+5*dl)
				plot_wl = wl[ind_plot] & plot_flux = flux[ind_plot]
				plot_base = [[wlb],[fluxb]]
				; Subtract the baseline from the spectrum
				; First, calculate the baseline
				; base = base_para[0]*wll +base_para[1]                       ;use 1st order polynomial
				base = base_para[0]*wll^2+base_para[1]*wll+base_para[2]      ;use 2nd order polynomial
				; Subtract
				fluxx = fluxl - base
				line = [line_center[i],range[0,i],range[1,i]]                      ;[line_center, line profile lower limit, line profile upper limit]
				; Calculate the noise level at the line using the flat noise spectrum
				limit_low = max([min(wl), range[0,i]-global_noise*dl]) & limit_hi = min([max(wl), range[1,i]+global_noise*dl])
				ind_n = where(wl gt limit_low and wl lt limit_hi)
				wl_n = wl[ind_n] & flux_n = flat_noise[ind_n]
				flat_noise_smooth = [[wl_n],[flux_n]]
				; Fitting part
				; Different fitting keyword for fixed width and test arguement
				if keyword_set(fixed_width) then begin
					if keyword_set(test) then fit_line, pixelname[j], line_name[i], wll, fluxx, std=abs(fluxx)*0.07, status, errmsg, cen_wl, sig_cen_wl, str, sig_str, fwhm, sig_fwhm, base_para, snr, line, plot_base=plot_base,$
        										/single_gauss, /test, outdir=plotdir, noiselevel=noiselevel, /fixed_width, global_noise=flat_noise_smooth, base_range=base_range, brightness=brightness,no_plot=no_plot,/spire
					if not keyword_set(test) then fit_line, pixelname[j], line_name[i], wll, fluxx, std=abs(fluxx)*0.07, status, errmsg, cen_wl, sig_cen_wl, str, sig_str, fwhm, sig_fwhm, base_para, snr, line, plot_base=plot_base,$
										       /single_gauss,outdir=plotdir, noiselevel=noiselevel, /fixed_width, global_noise=flat_noise_smooth, base_range=base_range, brightness=brightness,no_plot=no_plot,/spire
				endif else begin
        			if keyword_set(test) then fit_line, pixelname[j], line_name[i], wll, fluxx, std=abs(fluxx)*0.07, status, errmsg, cen_wl, sig_cen_wl, str, sig_str, fwhm, sig_fwhm, base_para, snr, line, plot_base=plot_base,$
        						      /single_gauss, /test, outdir=plotdir, noiselevel=noiselevel, global_noise=flat_noise_smooth, base_range=base_range, brightness=brightness,no_plot=no_plot,/spire
					if not keyword_set(test) then fit_line, pixelname[j], line_name[i], wll, fluxx, std=abs(fluxx)*0.07, status, errmsg, cen_wl, sig_cen_wl, str, sig_str, fwhm, sig_fwhm, base_para, snr, line, plot_base=plot_base,$
										  /single_gauss,outdir=plotdir, noiselevel=noiselevel, global_noise=flat_noise_smooth, base_range=base_range, brightness=brightness,no_plot=no_plot,/spire
				endelse
						
				; Print the fittng result into text file
				if status le 0 then begin
            		printf, secondfit, format = '((a16,2X),(a50))', line_name[i], errmsg
				endif else begin
            		read_line_ref, line_name[i], E_u, A, g
					base_str = interpol(base, wll, cen_wl);*fwhm
					; Blended lines classification
					blue_blend = 0 & red_blend = 0
					if i eq 0 then begin
            			if abs(line_center[i+1]-cen_wl) lt fwhm then red_blend = 1
					endif
					if i ne 0 and i ne n_elements(line_center)-1 then begin
            			if abs(cen_wl-line_center[i-1]) lt fwhm then blue_blend = 2
						if abs(line_center[i+1]-cen_wl) lt fwhm then red_blend  = 1
					endif
					if i eq n_elements(line_center)-1 then begin
            			if abs(cen_wl-line_center[i-1]) lt fwhm then blue_blend = 2
					endif
					blend_flag = red_blend+blue_blend
					if blend_flag eq 0 then blend_msg = 'x'
					if blend_flag eq 1 then blend_msg = 'Red'
					if blend_flag eq 2 then begin
            			blend_msg = 'Blue'
						blend_flag = 3
					endif
					if blend_flag eq 3 then begin
            			blend_msg = 'Red/Blue'
						blend_flag = 2
					endif
					; blend flag = 0: no blend; blend_flag = 1: Red blend; blend_flag = 2: Red/Blue blend; blend_flag = 3: Blue blend.
					;
					if not keyword_set(current_pix) then begin
						printf, secondfit, format = '((a16,2X),9(g16.10,2X),2(g16.10,2X),(i16,2x),2(g16.10,2X),(a16,2x))',$
						line_name[i], line_center[i], cen_wl, sig_cen_wl, str, sig_str, fwhm, sig_fwhm, base_str,snr, E_u, A, g, ra[j], dec[j], blend_msg
					endif else begin
						printf, secondfit, format = '((a16,2X),9(g16.10,2X),2(g16.10,2X),(i16,2x),2(g16.10,2X),2(a16,2x))',$
						line_name[i], line_center[i], cen_wl, sig_cen_wl, str, sig_str, fwhm, sig_fwhm, base_str,snr, E_u, A, g, ra[j], dec[j], pixelname[j], blend_msg
					endelse
					
				endelse 
			endfor
			; Double Gaussian fit
			if keyword_set(double_gauss) then begin
				for i = 0, n_elements(line_name_dg[0,*])-1 do begin
					mean_wl = (line_center_dg[2*i]+line_center_dg[2*i+1])/2
					if (min(wl) gt mean_wl) or (max(wl) lt mean_wl) then continue
					dlb = localbaseline*dl
					wl_diff = wl[1:-1]-wl[0:-2]
					numb = ceil(dlb/(wl_diff[where(wl ge line_center_dg[2*i])])[0])
					left = where(wl_basepool lt range_dg[0,i] and wl_basepool ge min(wl)) & right = where(wl_basepool gt range_dg[1,i] and wl_basepool le max(wl))
					if n_elements(left) gt numb then left = left[n_elements(left)-1-numb:n_elements(left)-1]
					if n_elements(right) gt numb then right = right[0:numb-1]
					if left[0] ne -1 and right[0] ne -1 then begin
            			wlb = [wl_basepool[left], wl_basepool[right]] & fluxb = [flux_basepool[left], flux_basepool[right]]
						base_range = [wl_basepool[left[0]], wl_basepool[left[n_elements(left)-1]], wl_basepool[right[0]], wl_basepool[right[n_elements(right)-1]]]
						indl = where(wl gt base_range[0] and wl lt base_range[3])
						wll = wl[indl] & fluxl = flux[indl]
					endif 
					if left[0] eq -1 and right[0] ne -1 then begin
                		wlb = [wl_basepool[right]] & fluxb = [flux_basepool[right]]
						base_range = [wl_basepool[right[0]], wl_basepool[right[0]],wl_basepool[right[0]],wl_basepool[right[n_elements(right)-1]]]
						indl = where(wl gt min(wl) and wl lt base_range[2])
						wll = wl[indl] & fluxl = flux[indl]
					endif
					if left[0] ne -1 and right[0] eq -1 then begin
                		wlb = [wl_basepool[left]] & fluxb = [flux_basepool[left]]
						base_range = [wl_basepool[left[0]], wl_basepool[left[n_elements(left)-1]],wl_basepool[left[n_elements(left)-1]],wl_basepool[left[n_elements(left)-1]]]
						indl = where(wl gt base_range[0] and wl lt max(wl))
						wll = wl[indl] & fluxl = flux[indl]
					endif
					; use the plot_base feature to plot the actual spectrum (with line) here
					plot_base = [[wll],[fluxl]]
					fit_line, pixelname[j], line_name_dg[2*i]+'+'+line_name_dg[2*i+1], wlb, fluxb, std=abs(fluxb)*0.07, status, errmsg, cen_wl, sig_cen_wl, str, sig_str, fwhm, sig_fwhm, base_para, snr, /baseline, outdir=plotdir,no_plot=no_plot,plot_base=plot_base,/spire
					; extract the wave and flux for plottng that is for better visualization of the fitting results.
					ind_plot = where(wl gt base_range[0]-5*dl and wl lt base_range[3]+5*dl)
					plot_wl = wl[ind_plot] & plot_flux = flux[ind_plot]
					plot_base = [[wlb],[fluxb]]
					flat_noise_smooth = [[wl_n],[flux_n]]
					; Calculate the gloe noise spectrum
					limit_low = max([min(wl), range_dg[0,i]-global_noise*dl]) & limit_hi = min([max(wl), range_dg[1,i]+global_noise*dl])
					ind_n = where(wl gt limit_low and wl lt limit_hi)
					wl_n = wl[ind_n] & flux_n = flat_noise[ind_n]
					flat_noise_smooth = [[wl_n],[flux_n]]
					; Subtract the baseline from the spectrum
					; First, calculate the baseline
					; base = base_para[0]*wll +base_para[1]                       ;use 1st order polynomial
					base = base_para[0]*wll^2+base_para[1]*wll+base_para[2]      ;use 2nd order polynomial
					; Subtract
					fluxx = fluxl - base
					line = [line_dg[*,2*i],line_dg[*,2*i+1]]
					; line = [line_center_dg[0,i],range_dg_4[0,i],range]                      ;[line_center, line profile lower limit, line profile upper limit]
					; Fitting part
					; Different fitting keyword for fixed width and test arguement
					fit_line,pixelname[j],line_name_dg[2*i]+'+'+line_name_dg[2*i+1],wll,fluxx,std=abs(fluxx)*0.07,status,errmsg,cen_wl,sig_cen_wl,str,sig_str,fwhm,sig_fwhm,base_para,snr,line,/double_gauss,outdir=plotdir,$
					 	noiselevel=noiselevel,base_range=base_range,plot_base=plot_base,global_noise=flat_noise_smooth,/fix_dg,/spire,/fixed_width,brightness=brightness
					if status eq 0 then begin
						printf, firstfit, format = '((a16,2X),(a50))', line_name_dg[2*i]+'_'+line_name_dg[2*i+1], errmsg
					endif else begin
						; Making sure the line classification is correct
						i1 = where(line_name eq line_name_dg[2*i])
						i2 = where(line_name eq line_name_dg[2*i+1])
						if (abs(line_center[i1]-cen_wl[0]) gt abs(line_center[i1]-cen_wl[1])) and (abs(line_center[i2]-cen_wl[1]) gt abs(line_center[i2]-cen_wl[0])) then begin
							print, 'Line misplacement found in '+line_name_dg[2*i]+'+'+line_name_dg[2*i+1]
							cen_wl = reverse(cen_wl)
							sig_cen_wl = reverse(sig_cen_wl)
							str = reverse(str)
							sig_str = reverse(sig_str)
							fwhm = reverse(fwhm)
							sig_fwhm = reverse(sig_fwhm)
							snr = reverse(snr)
						endif
						read_line_ref, line_name_dg[2*i], E_u1, A1, g1
						read_line_ref, line_name_dg[2*i+1], E_u2, A2, g2
						E_u = [E_u1,E_u2]
						A = [A1,A2]
						g = [g1,g2]
						base_str = [interpol(base, wll, cen_wl[0]), interpol(base, wll, cen_wl[1])]
						blend_msg = 'x'
						if not keyword_set(current_pix) then begin
							printf, firstfit, format = '((a16,2X),9(g16.10,2X),2(g16.10,2X),(i16,2x),2(g16.10,2X),(a16,2x))',$
								line_name_dg[2*i], line[0], cen_wl[0], sig_cen_wl[0], str[0], sig_str[0], fwhm[0], sig_fwhm[0], base_str[0],snr[0], E_u[0], A[0], g[0], ra[j], dec[j], blend_msg
							printf, firstfit, format = '((a16,2X),9(g16.10,2X),2(g16.10,2X),(i16,2x),2(g16.10,2X),(a16,2x))',$
								line_name_dg[2*i+1], line[3], cen_wl[1], sig_cen_wl[1], str[1], sig_str[1], fwhm[1], sig_fwhm[1], base_str[1],snr[1], E_u[1], A[1], g[1], ra[j], dec[j], blend_msg
						endif else begin
							printf, firstfit, format = '((a16,2X),9(g16.10,2X),2(g16.10,2X),(i16,2x),2(g16.10,2X),2(a16,2x))',$
								line_name_dg[2*i], line[0], cen_wl[0], sig_cen_wl[0], str[0], sig_str[0], fwhm[0], sig_fwhm[0], base_str[0],snr[0], E_u[0], A[0], g[0], ra[j], dec[j], pixelname[j], blend_msg
							printf, firstfit, format = '((a16,2X),9(g16.10,2X),2(g16.10,2X),(i16,2x),2(g16.10,2X),2(a16,2x))',$
								line_name_dg[2*i+1], line[3], cen_wl[1], sig_cen_wl[1], str[1], sig_str[1], fwhm[1], sig_fwhm[1], base_str[1],snr[1], E_u[1], A[1], g[1], ra[j], dec[j], pixelname[j], blend_msg
						endelse
					endelse
				endfor
			endif
			free_lun, secondfit
			close, secondfit
			
			; Identify the blended lines
			; print, '----> Start identifying the blended region by standard criterion and make suggestions if there is only one line present'
			; name = filename+'_lines'
			; if keyword_set(linescan) then name = name+'_LS'
			; if keyword_set(localbaseline) then name = name+''
			; if keyword_set(fixed_width) then name = name+'_fixwidth'
			if not keyword_set(current_pix) then begin
				; readcol, name+'_global_noise.txt', format='A,D,D,D,D,D,D,D,D,D,D,D,D,D,D,A', $
				readcol, name+'.txt', format='A,D,D,D,D,D,D,D,D,D,D,D,I,D,D,A', $
					line_name_n, lab_wl_n, cen_wl_n, sig_cen_wl_n, str_n, sig_str_n, fwhm_n, sig_fwhm_n, base_str_n, snr_n, E_u_n, A_n, g_n, ra_n, dec_n, blend_flag_n, /silent, skipline=1
			endif else begin
				; readcol, name+'_global_noise.txt', format='A,D,D,D,D,D,D,D,D,D,D,D,D,D,D,A,A', $
				readcol, name+'.txt', format='A,D,D,D,D,D,D,D,D,D,D,D,I,D,D,A,A', $
					line_name_n, lab_wl_n, cen_wl_n, sig_cen_wl_n, str_n, sig_str_n, fwhm_n, sig_fwhm_n, base_str_n, snr_n, E_u_n, A_n, g_n, ra_n, dec_n, pix_n, blend_flag_n, /silent, skipline=1
			endelse
			
			blend_subgroup = []
			blend_msg_all = []
			possible_all = []
			for line = 0, n_elements(line_name_n)-1 do begin
				if (keyword_set(double_gauss)) and ((where(line_name_dg eq line_name_n[line]))[0] ne -1) then begin
					blend_msg = 'DoubleGaussian'
					blend_msg_all = [blend_msg_all,blend_msg]
				continue
				endif
				; Blended lines classification
				blue_blend = 0 & red_blend = 0
				if line eq 0 then begin
					if abs(cen_wl_n[line+1]-cen_wl_n[line]) lt fwhm_n[line] then red_blend = 1
				endif
				if line ne 0 and line ne n_elements(line_name_n)-1 then begin
            		if abs(cen_wl_n[line]-cen_wl_n[line-1]) lt fwhm_n[line] then blue_blend = 2
					if abs(cen_wl_n[line+1]-cen_wl_n[line]) lt fwhm_n[line] then red_blend  = 1
				endif
				if line eq n_elements(line_name_n)-1 then begin
					if abs(cen_wl_n[line]-cen_wl_n[line-1]) lt fwhm_n[line] then blue_blend = 2
				endif
				blend_flag = red_blend+blue_blend
				if blend_flag eq 0 then blend_msg = 'x'
				if blend_flag eq 1 then blend_msg = 'Red'
				if blend_flag eq 2 then begin
					blend_msg = 'Blue'
					blend_flag = 3
				endif
				if blend_flag eq 3 then begin
            		blend_msg = 'Red/Blue'
					blend_flag = 2
				endif
				blend_msg_all = [blend_msg_all,blend_msg]			
				if n_elements(blend_subgroup) eq 0 then group_flag = 0
				if blend_flag ge group_flag then begin
					if blend_flag eq 0 then continue
					blend_subgroup = [[blend_subgroup],[line_name_n[line],string(E_u_n[line])]]
					group_flag = blend_flag
				endif else begin
					possible_line = blend_subgroup[0,where(float(blend_subgroup[1,*]) eq min(float(blend_subgroup[1,*])))]
					if n_elements(possible_line) gt 1 then begin
						A_dum = A_n[where(line_name_n eq possible_line)]
						possible_line = possible_line[(where(line_name_n eq possible_line))[where(A_dum eq max(A_dum))]]
					endif
					blend_subgroup = []
					possible_all = [possible_all, possible_line]
					if blend_flag ne 0 then begin
						blend_subgroup = [[blend_subgroup],[line_name_n[line],string(E_u_n[line])]]
						group_flag = blend_flag
					endif
				endelse	
			endfor
			; Artificially remove CI3P2-3P1 from possible line and add CO7-6
			; if (where(possible_all eq 'CO7-6'))[0] eq -1 then possible_all = [possible_all,'CO7-6']
			; if (where(possible_all eq 'CI3P2-3P1'))[0] ne -1 then possible_all = possible_all[where(possible_all ne 'CI3P2-3P1')]
			; 
			; openw, secondfit, name+'_global_noise.txt', /get_lun
			openw, secondfit, name+'.txt', /get_lun
			if not keyword_set(current_pix) then begin
				printf, secondfit, format='(17(a16,2x))', $
    				'Line','LabWL(um)','ObsWL(um)','Sig_Cen(um)','Str(W/cm2'+unit+')','Sig_str(W/cm2'+unit+')','FWHM(um)','Sig_FWHM(um)','Base(W/cm2/um'+unit+')','SNR','E_u(K)','A(s-1)','g','RA(deg)','Dec(deg)','Blend','Validity'
			endif else begin
				printf, secondfit, format='(18(a16,2x))', $
    				'Line','LabWL(um)','ObsWL(um)','Sig_Cen(um)','Str(W/cm2'+unit+')','Sig_str(W/cm2'+unit+')','FWHM(um)','Sig_FWHM(um)','Base(W/cm2/um'+unit+')','SNR','E_u(K)','A(s-1)','g','RA(deg)','Dec(deg)','Pixel_No.','Blend','Validity'
			endelse
			for line = 0, n_elements(line_name_n)-1 do begin
    			lowest = '0'
				if (where(possible_all eq line_name_n[line]))[0] ne -1 then lowest = '1'
				if (blend_msg_all[line] eq 'x') or (blend_msg_all[line] eq 'DoubleGaussian') then lowest = '1'
				if finite(snr_n[line],/nan) eq 1 then lowest = '0'
				if (sig_cen_wl_n[line] eq -999) or (sig_fwhm_n[line] eq -999) then lowest = '0'
				if not keyword_set(current_pix) then begin
					printf, secondfit, format = '((a16,2X),9(g16.10,2X),2(g16.10,2X),(i16,2x),2(g16.10,2X),2(a16,2x))',$
            			line_name_n[line], lab_wl_n[line], cen_wl_n[line], sig_cen_wl_n[line], str_n[line], sig_str_n[line], fwhm_n[line], sig_fwhm_n[line], base_str_n[line],snr_n[line],$
						E_u_n[line], A_n[line], g_n[line], ra_n[line], dec_n[line], blend_msg_all[line], lowest
					if keyword_set(print_all) then begin
						;openw, gff, print_all+'_global_noise.txt',/append,/get_lun
						openw, gff, print_all+'.txt',/append,/get_lun
						printf, gff, format = '(2(a16,2X),9(g16.10,2X),2(g16.10,2X),(i16,2x),2(g16.10,2X),2(a16,2x))',$
            				object, line_name_n[line], lab_wl_n[line], cen_wl_n[line], sig_cen_wl_n[line], str_n[line], sig_str_n[line], fwhm_n[line], sig_fwhm_n[line], base_str_n[line],snr_n[line],$
							E_u_n[line], A_n[line], g_n[line], ra_n[line], dec_n[line], blend_msg_all[line], lowest
						free_lun, gff
						close, gff
					endif
				endif else begin
					printf, secondfit, format = '((a16,2X),9(g16.10,2X),2(g16.10,2X),(i16,2x),2(g16.10,2X),3(a16,2x))',$
            			line_name_n[line], lab_wl_n[line], cen_wl_n[line], sig_cen_wl_n[line], str_n[line], sig_str_n[line], fwhm_n[line], sig_fwhm_n[line], base_str_n[line],snr_n[line],$
						E_u_n[line], A_n[line], g_n[line], ra_n[line], dec_n[line], pix_n[line], blend_msg_all[line], lowest
					if keyword_set(print_all) then begin
						;openw, gff, print_all+'_global_noise.txt',/append,/get_lun
						openw, gff, print_all+'.txt',/append,/get_lun
						printf, gff, format = '(2(a16,2X),9(g16.10,2X),2(g16.10,2X),(i16,2x),2(g16.10,2X),3(a16,2x))',$
            				object, line_name_n[line], lab_wl_n[line], cen_wl_n[line], sig_cen_wl_n[line], str_n[line], sig_str_n[line], fwhm_n[line], sig_fwhm_n[line], base_str_n[line],snr_n[line],$
							E_u_n[line], A_n[line], g_n[line], ra_n[line], dec_n[line], pix_n[line], blend_msg_all[line], lowest
						free_lun, gff
						close, gff
					endif
				endelse
			endfor
			free_lun, secondfit
			close, secondfit
			; Calculate the line subtracted spectrum again
			; name = outdir+object+'_'+pixelname[j]+'_lines'
			; if keyword_set(fixed_width) then name = name+'_fixwidth'
			if not keyword_set(current_pix) then begin
				readcol, name+'.txt', format='A,D,D,D,D,D,D,D,D,D,D,D,I,D,D,A,I',$
					line_name_n, lab_wl_n, cen_wl_n, sig_cen_wl_n, str_n, sig_str_n, fwhm_n, sig_fwhm_n, base_str_n, snr_n, E_u_n, A_n, g_n, ra_n, dec_n, blend_flag_n, lowest_E_n, /silent
			endif else begin
				readcol, name+'.txt', format='A,D,D,D,D,D,D,D,D,D,D,D,I,D,D,A,A,I',$
					line_name_n, lab_wl_n, cen_wl_n, sig_cen_wl_n, str_n, sig_str_n, fwhm_n, sig_fwhm_n, base_str_n, snr_n, E_u_n, A_n, g_n, ra_n, dec_n, pix_n, blend_flag_n, lowest_E_n, /silent
			endelse
			
			flux_sub = flux
			for line = 0, n_elements(line_name_n)-1 do begin
    			if snr_n[line] ge noiselevel then begin
    				if blend_flag_n[line] ne 'x' and lowest_E_n[line] ne 1 then continue
    				ind = where((wl gt cen_wl_n[line]-5*fwhm_n[line]) and (wl lt cen_wl_n[line]+5*fwhm_n[line]))
					wl_n = wl[ind]
					line_profile = gauss(wl_n, [2.354*str_n[line]/fwhm_n[line]/(2*!PI)^0.5, cen_wl_n[line], fwhm_n[line]/2.354]);+base_str[line]
					flux_sub[ind] = flux_sub[ind] - line_profile
					if keyword_set(plot_subtraction) then begin
						set_plot,'ps'
						!p.font=0
						loadct,12,/silent
						device, filename=plotdir+'line_subtracted_'+pixelname[j]+'_'+line_name[line]+'_global_noise.eps',/helvetica,/portrait,/encapsulated,isolatin=1,font_size=12,decomposed=0,/color
						!p.thick=3 & !x.thick=3 & !y.thick=3
						plot, wl_n, flux[ind]/1e-22, xtitle = 'Wavelength (!9m!3m)', ytitle = ylabel
						oplot, wl_n, (line_profile+base_str_n[line])/1e-22, color=120 ;purple
						oplot, wl_n, flux_sub[ind]/1e-22, color=200 ;red
						device, /close_file, decomposed=1
						!p.multi=0
					endif
				endif
			endfor
			; Smooth the line subtracted spectrum
			sbin=20
			spec_continuum_smooth,wl,flux_sub,continuum_sub, continuum_sub_error,w1 = min(wl), w2 = max(wl), sbin=sbin,upper=0.9,lower=0.9
			flat_noise = flux_sub - continuum_sub

			if keyword_set(continuum_sub) then begin
    			openw, sed, name+'_continuum.txt', /get_lun
    			if keyword_set(fx) then printf, sed, format='(2(a16,2x))','Wave (um)','Flux (Jy)'
    			if keyword_set(brightness) then printf, sed, format='(2(a16,2x))','Wave (um)','I_nu (Jy/as2)'
				print_continuum_sub = continuum_sub*1d26*1d6*(wl*1d-6)^2/c*1d4
				for k =0, n_elements(wl)-1 do printf, sed, format='(2(g16.6,2x))', wl[k],print_continuum_sub[k]
				free_lun, sed
				close, sed
			endif
			if keyword_set(flat) then begin
    			openw, flat_sed, name+'_flat_spectrum.txt',/get_lun
				if keyword_set(fx) then printf, sed, format='(2(a16,2x))','Wave (um)','Flux (Jy)'
    			if keyword_set(brightness) then printf, sed, format='(2(a16,2x))','Wave (um)','I_nu (Jy/as2)'
				flat = (flux - continuum_sub) *1d26*1d6*(wl*1d-6)^2/c*1d4
				for k =0, n_elements(wl)-1 do printf, flat_sed, format='(2(g16.6,2x))',wl[k],flat[k]
				free_lun, flat_sed
				close,flat_sed
			endif

			; Plot the results
			set_plot, 'ps'
			!p.font = 0
			loadct,12,/silent
			; if keyword_set(fixed_width) then msg = '_fixed_width'
			; if not keyword_set(fixed_width) then msg =''
			msg = ''
			device, filename = plotdir+'spectrum_line_subtracted_'+pixelname[j]+msg+'.eps', /helvetica, /portrait, /encapsulated, isolatin = 1, font_size = 12, decomposed = 0, /color
			!p.thick=2 & !x.thick=3 & !y.thick=3
			trim1 = where(wl lt 100) & trim2 = where(wl ge 100)
			plot, wl, flux/1e-22, xtitle = 'Wavelength (!9m!3m)', ytitle = ylabel,ystyle=2,/nodata,position=[0.15,0.1,0.95,0.95]
			if trim1[0] ne -1 then begin
				oplot, wl[trim1], flux[trim1]/1e-22
				oplot, wl[trim1], continuum_sub[trim1]/1e-22, color=100
				oplot, wl[trim1], flat_noise[trim1]/1e-22 + min(flux)/1e-22, color=10
			endif
			if trim2[0] ne -1 then begin
				oplot, wl[trim2], flux[trim2]/1e-22
				oplot, wl[trim2], continuum_sub[trim2]/1e-22, color=100
				oplot, wl[trim2], flat_noise[trim2]/1e-22 + min(flux)/1e-22, color=10
			endif
			; al_legend,['Data','lines_subtracted','(lines_subtracted)_smooth', 'flat/featureless'],textcolors=[0,200,100,10],/right
			al_legend,['data','continuum', 'flat/featureless'],textcolors=[0,100,10],/right
			al_legend,[object+' '+plot_pixelname[j]],textcolors= [0],/left
			device, /close_file, decomposed = 1
			!p.multi = 0
			
		endif
	endfor
end
