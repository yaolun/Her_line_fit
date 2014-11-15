pro extract_spire_slw, indir=indir, outdir=outdir, plotdir=plotdir, pospath=pospath, test=test
;The indir should include every letter except for the pixel name.
pixelname = ['SLWA1','SLWA2','SLWA3','SLWB1','SLWB2','SLWB3','SLWB4','SLWC1','SLWC2','SLWC3','SLWC4','SLWC5','SLWD1','SLWD2','SLWD3','SLWD4','SLWE1','SLWE2','SLWE3']
obj_name = ['bhr71']

ra = [53.3195833,246.8725,67.89208333,69.8958333,53.3245833,51.9129167,274.3745833,69.8070167,294.25375,53.3033333,289.47375,314.72375,166.6958333,235.7554167,285.4504167,315.2883333,$
    193.3216667,321.03125,285.485,305.95,86.343333,309.77625,285.4804167,246.61,246.5891667,52.0016667,248.6220833,246.6841667,173.3557478,61.17875,70.3029167]
dec = [31.132,-24.6544722,18.1346944,25.6959722,31.1588611,30.2175278,-4.6609722,25.8890556,7.5693611,31.2567222,19.2055556,44.2580556,-77.1196389,-34.1541667,-35.9563056,50.3625,$
    -77.1196389,49.9858333,-36.9578611,42.2072222,9.07,68.0377778,-36.9547222,-24.4083333,-24.3845278,30.1336944,-15.7837222,-24.5801111,-70.1947966,26.3156389,25.7766389]
;The following part is for reading the [ra,dec] for each pixel.
;I use a script to read them, but you can create a text file which contain the coordinate information and read them by setting the pospath keyword in this script.
get_radec_slw, coord, plot_coord
for obj = 0, n_elements(obj_name)-1 do begin
for j = 0, n_elements(pixelname)-1 do begin
    ;The path to the data that you want to fit.  wavelength in um and flux in Jy.
    READCOL, indir+PIXELNAME[j]+'.TXT', FORMAT='D,D', WL, FLUX
	flux = flux[where(wl ge 314)] & wl = wl[where(wl ge 314)]
    ;Convert the flux to appropriate unit
    c = 2.998d8
    flux = flux*1d-4*c/(wl*1d-6)^2*1d-6*1d-26
    ;Information about the line that you want to fit including the range for baseline fitting.
    line_name_oh2o = ['o-H2O5_32-4_41','o-H2O1_10-1_01','o-H2O4_23-3_30']
    line_center_oh2o = [483.0021428,538.3023584,669.1946510]
	
	line_name_ph2o = ['p-H2O2_02-1_11','p-H2O5_24-4_31','p-H2O4_22-3_31','p-H2O9_28-8_35','p-H2O2_11-2_02','p-H2O6_24-7_17','p-H2O5_33-4_40','p-H2O6_42-5_51']
	line_center_ph2o = [303.4638096,308.9717523,327.2312598,330.8298372,398.6525967,613.7265992,631.5709820,636.6680083]
	
	line_name_co = ['CO8-7','CO7-6','CO6-5','CO5-4','CO4-3']
	line_center_co = [325.23334516,371.65973939,433.56713410,520.24411585,650.26787364]
	
	line_name_13co = ['13CO9-8','13CO8-7','13CO7-6','13CO6-5','13CO5-4']
	line_center_13co = [302.422210195,340.18977646,388.752815449,453.509061166,544.174435197]
	
	line_name_hco = ['HCO+11-10','HCO+10-9','HCO+9-8','HCO+8-7','HCO+7-6','HCO+6-5']
	line_center_hco = [305.71952487,336.26530802,373.60195435,420.27521465,480.28810368,560.30913387]
	
	line_name_other = ['CI370','CI610']
	line_center_other = [370.424383,609.150689]
	
	line_name = [line_name_oh2o, line_name_ph2o, line_name_co, line_name_13co, line_name_hco, line_name_other]
	line_center = [line_center_oh2o, line_center_ph2o, line_center_co, line_center_13co, line_center_hco, line_center_other]
	
	;fwhm_ins = 1.4472/c*wl^2/2.354
	
	;Define the range of line center by setting the range within 5 times of the resolution elements of the line center
	range = []
	range_factor=4
	for i =0, n_elements(line_center)-1 do begin
		dl = 1.4472/c*1e3*(line_center[i]^2)/2.354
		print, dl
		range = [[range], [[line_center[i]-range_factor*dl, line_center[i]+range_factor*dl]]]
	endfor
	line_name = line_name[sort(line_center)]
	range = range[*,sort(line_center)]
	;cont = cont[*,sort(line_center)]
	line_center = line_center[sort(line_center)]
	;Create a wavelength array that every elements in this array can be selected as a valid point for baseline fitting
	base_mask = 0*wl
	for i = 0, n_elements(wl)-1 do begin
		valid=1
		for j = 0, n_elements(line_name)-1 do begin
			if (wl[i] ge range[0,j]) and (wl[i] le range[1,j]) then valid = valid*0
		endfor
		if valid eq 1 then base_mask[i] = 1
	endfor

	wl_basepool = wl[where(base_mask ne 0)] & flux_basepool = flux[where(base_mask ne 0)]
	;Select different line list for line scan spectrum
;	if keyword_set(linescan) then begin
;		dl_min = interpol(dl_ins, wl_ins, min(wl))
;		dl_max = interpol(dl_ins, wl_ins, max(wl))
;		seg = where((line_center ge (min(wl)+dl_min)) and (line_center le (max(wl)-dl_max)))
;
;		line_name = line_name[seg]
;		line_center = line_center[seg]
;		range = range[*,seg]
;		cont = cont[*,seg]
;		print, 'Min and Max wl', min(wl), max(wl)
;		print, seg
;		for i = 0, n_elements(seg)-1 do begin
;			if seg[i] eq -1 then begin
;			return
;			end
;		endfor
;	endif

    ;The path to the output file for print out the fitting result.
    openw, lun, outdir+pixelname[j]+'lines.txt', /get_lun

    printf, lun, format='((a12,2x),13(a16,2x))', 'Line', 'WL (um)', 'Sig_Cen (um)', 'Str(erg/cm2)', 'Sig_str(erg/cm2)', 'FWHM (um)', 'Sig_FWHM (um)', 'Base_str','SNR', 'E_u (K)', 'A (s-1)', 'g', 'RA', 'Dec'
    for i = 0, n_elements(line_name)-1 do begin
        ;select the baseline
        indb = where((wl gt cont[0,i] and wl lt cont[1,i]) or (wl gt cont[2,i] and wl lt cont[3,i]))
        wlb = wl[indb] & fluxb = flux[indb]
        ;fit the baseline and return the baseline parameter in 'base_para'
        fit_line, obj_name[obj]+pixelname[j], line_name[i], wlb, fluxb, status, errmsg, cen_wl, sig_cen_wl, str, sig_str, fwhm, sig_fwhm, base_para, snr, /baseline, outdir=plotdir
        ;select the line+baseline
        indl = where(wl gt cont[0,i] and wl lt cont[3,i])
        wll = wl[indl] & fluxl = flux[indl]
        ;Substract the baseline from the spectrum
        ;First, calculate the baseline
        ;base = base_para[0]*wll +base_para[1]                       ;use 1st order polynomial
        base = base_para[0]*wll^2+base_para[1]*wll+base_para[2]      ;use 2nd order polynomial
        ;Substract
        fluxx = fluxl - base
        line = [line_center[i],range[0,i],range[1,i]]                      ;[line_center, line profile lower limit, line profile upper limit]
        ;Fitting part
        if keyword_set(test) then fit_line, obj_name[obj]+pixelname[j], line_name[i], wll, fluxx, status, errmsg, cen_wl, sig_cen_wl, str, sig_str, fwhm, sig_fwhm, base_para, snr, line, /single_gauss, /test, outdir=plotdir, noiselevel=3
        if not keyword_set(test) then fit_line, obj_name[obj]+pixelname[j], line_name[i], wll, fluxx, status, errmsg, cen_wl, sig_cen_wl, str, sig_str, fwhm, sig_fwhm, base_para, snr, line, /single_gauss, outdir=plotdir, noiselevel=3
        ;Print the fittng result into text file
        if status le 0 then begin
            printf, lun, format = '((a16,2X),(a50))', line_name[i], errmsg
        endif else begin
            read_line_ref, line_name[i], E_u, A, g
            base_str = interpol(base, wll, cen_wl)*fwhm
            printf, lun, format = '((a16,2X),8(g16.6,2X),3(g16.4,2X),2(g16,2X))', line_name[i], cen_wl, sig_cen_wl, str, sig_str, fwhm, sig_fwhm, base_str,snr, E_u, A, g, coord[0,j], coord[1,j]
            ;printf, lun, format = '((a16,2X),7(g16.4,2X),3(g16.4,2X),2(g16,2X))', line_name[i], cen_wl, sig_cen_wl, str, sig_str, fwhm, sig_fwhm, snr, E_u, A, g, ra[obj], dec[obj]
        endelse 
    endfor
free_lun, lun
close, lun
endfor
endfor
end

pro extract_spire_ssw, indir=indir, outdir=outdir, plotdir=plotdir, pospath=pospath, test=test
pixelname = ['SSWA1','SSWA2','SSWA3','SSWA4','SSWB1','SSWB2','SSWB3','SSWB4','SSWB5','SSWC1','SSWC2','SSWC3','SSWC4','SSWC5','SSWC6','SSWD1','SSWD2','SSWD3','SSWD4','SSWD6','SSWD7','SSWE1','SSWE2','SSWE3','SSWE4','SSWE5','SSWE6','SSWF1','SSWF2','SSWF3','SSWF5','SSWG1','SSWG2','SSWG3','SSWG4']
obj_name = ['bhr71']
ra = [53.3195833,246.8725,67.89208333,69.8958333,53.3245833,51.9129167,274.3745833,69.8070167,294.25375,53.3033333,289.47375,314.72375,166.6958333,235.7554167,285.4504167,315.2883333,$
    193.3216667,321.03125,285.485,305.95,86.343333,309.77625,285.4804167,246.61,246.5891667,52.0016667,248.6220833,246.6841667,173.3557478,61.17875,70.3029167]
dec = [31.132,-24.6544722,18.1346944,25.6959722,31.1588611,30.2175278,-4.6609722,25.8890556,7.5693611,31.2567222,19.2055556,44.2580556,-77.1196389,-34.1541667,-35.9563056,50.3625,$
    -77.1196389,49.9858333,-36.9578611,42.2072222,9.07,68.0377778,-36.9547222,-24.4083333,-24.3845278,30.1336944,-15.7837222,-24.5801111,-70.1947966,26.3156389,25.7766389]
;The following part is for reading the [ra,dec] for each pixel.
;I use a script to read them, but you can create a text file which contain the coordinate information and read them by setting the pospath keyword in this script.
get_radec_ssw, coord, plot_coord
for obj = 0, n_elements(obj_name)-1 do begin
for j = 0, n_elements(pixelname)-1 do begin
    ;The path to the data that you want to fit.  wavelength in um and flux in Jy.
    readcol, indir+pixelname[j]+'.txt', format='D,D', wl, flux

    ;Convert the flux to appropriate unit
    c = 2.998d8
    flux = flux*1d-4*c/(wl*1d-6)^2*1d-6*1d-26
    ;Information about the line that you want to fit including the range for baseline fitting.
    line_name_oh2o = ['o-H2O5_23-5_14','o-H2O6_25-5_32','o-H2O8_45-9_18','o-H2O8_27-7_34','o-H2O7_43-6_52','o-H2O8_54-7_61','o-H2O3_21-3_12','o-H2O7_25-8_18','o-H2O3_12-3_03']
    
    
    
    
    line_name = ['CO13-12','NII205','CO12-11','CO11-10','13CO11-10','o-H2O3_21-3_12','CO10-9','p-H2O1_11-0_00','13CO10-9','CO9-8']
    line_center = [200.27,205.178,216.93,236.61,247.66,257.79,260.24,269.46,272.39,289.12]
    ;Range of the line profile
    range = [[199.7,200.7],[204.6,205.8],[216.5,217.2],[236.0,237.2],[247,248],[257,258],[259.6,260.6],[268.8,269.7],[271.9,272.6],[288.5,289.7]]
    ;Range of the baseline
    cont = [[198.7,199.6,200.8,203.5],[203.5,204.5,206,210],[210,216.5,217.5,220],[230,235.5,237.5,245],[245,247,248,255],[254,256,258,259],[255,259.5,260.7,267],[262,268.8,269.7,271],[270,271.3,272.8,280],[280,288.5,289.8,291]]
    ;The path to the output file for print out the fitting result.
    openw, lun, outdir+pixelname[j]+'lines.txt', /get_lun

    printf, lun, format='((a16,2x),13(a16,2x))', 'Line', 'WL (um)', 'Sig_Cen (um)', 'Str(erg/cm2)', 'Sig_str(erg/cm2)', 'FWHM (um)', 'Sig_FWHM (um)', 'Base_str','SNR', 'E_u (K)', 'A (s-1)', 'g', 'RA', 'Dec'
    for i = 0, n_elements(line_name)-1 do begin
        ;select the baseline
        indb = where((wl gt cont[0,i] and wl lt cont[1,i]) or (wl gt cont[2,i] and wl lt cont[3,i]))
        wlb = wl[indb] & fluxb = flux[indb]
        ;fit the baseline and return the baseline parameter in 'base_para'
        fit_line, obj_name[obj]+pixelname[j], line_name[i], wlb, fluxb, status, errmsg, cen_wl, sig_cen_wl, str, sig_str, fwhm, sig_fwhm, base_para, snr, /baseline, outdir=plotdir
        ;select the line+baseline
        indl = where(wl gt cont[0,i] and wl lt cont[3,i])
        wll = wl[indl] & fluxl = flux[indl]
        ;Substract the baseline from the spectrum
        ;First, calculate the baseline
        ;base = base_para[0]*wll +base_para[1]                       ;use 1st order polynomial
        base = base_para[0]*wll^2+base_para[1]*wll+base_para[2]      ;use 2nd order polynomial
        ;Substract
        fluxx = fluxl - base
        line = [line_center[i],range[0,i],range[1,i]]                ;[line_center, line profile lower limit, line profile upper limit]
        ;Fitting part
        if keyword_set(test) then fit_line, obj_name[obj]+pixelname[j], line_name[i], wll, fluxx, status, errmsg, cen_wl, sig_cen_wl, str, sig_str, fwhm, sig_fwhm, base_para, snr, line, /single_gauss, /test, outdir=plotdir, noiselevel=3
        if not keyword_set(test) then fit_line, obj_name[obj]+pixelname[j], line_name[i], wll, fluxx, status, errmsg, cen_wl, sig_cen_wl, str, sig_str, fwhm, sig_fwhm, base_para, snr, line, /single_gauss,outdir=plotdir, noiselevel=3
        ;Print the fitting result into text file
        if status le 0 then begin
            printf, lun, format = '((a16,2X),(a50))', line_name[i], errmsg
        endif else begin
            read_line_ref, line_name[i], E_u, A, g
            base_str = interpol(base, wll, cen_wl)*fwhm
            printf, lun, format = '((a16,2X),8(g16.6,2X),3(g16.4,2X),2(g16,2X))', line_name[i], cen_wl, sig_cen_wl, str, sig_str, fwhm, sig_fwhm, base_str,snr, E_u, A, g, coord[0,j], coord[1,j]
            ;printf, lun, format = '((a16,2X),7(g16.4,2X),3(g16.4,2X),2(g16,2X))', line_name[i], cen_wl, sig_cen_wl, str, sig_str, fwhm, sig_fwhm, snr, E_u, A, g, ra[obj],dec[obj]
        endelse
    endfor
free_lun, lun
close, lun
endfor
endfor
end

pro extract_spire
  extract_spire_slw, indir='~/bhr71/data/pixel_spectrum/extended_correction/', outdir='~/bhr71/data/', plotdir='~/bhr71/plots/', /test
  extract_spire_ssw, indir='~/bhr71/data/pixel_spectrum/extended_correction/', outdir='~/bhr71/data/', plotdir='~/bhr71/plots/', /test
end
