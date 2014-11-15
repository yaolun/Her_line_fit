pro extract_spire_slw, test=test

pixelname = ['SLWA1','SLWA2','SLWA3','SLWB1','SLWB2','SLWB3','SLWB4','SLWC1','SLWC2','SLWC3','SLWC4','SLWC5','SLWD1','SLWD2','SLWD3','SLWD4','SLWE1','SLWE2','SLWE3']
obj_name = ['bhr71']
;pixelname = ['Ext_corrected']
;obj_name = ['b1-a_spire','hh46_spire','l1551-irs5_spire','tmc1a_spire','b1-c_spire','iras03245_spire','l483_spire','tmr1_spire','b335_spire','iras03301_spire','l723-mm_spire','v1057cyg_spire','ced110_spire','iras15398_spire','rcra-irs5a_spire','v1331cyg_spire','dkcha_spire','l1014_spire','rcra-irs7b_spire','v1515cyg_spire','fuori_spire','l1157_spire','rcra-irs7c_spire','vla1623_spire','gss30_spire','l1455-irs3','rno91_spire','wl12_spire','hd100546_spire','l1489_spire','tmc1_spire']
ra = [53.3195833,246.8725,67.89208333,69.8958333,53.3245833,51.9129167,274.3745833,69.8070167,294.25375,53.3033333,289.47375,314.72375,166.6958333,235.7554167,285.4504167,315.2883333,$
    193.3216667,321.03125,285.485,305.95,86.343333,309.77625,285.4804167,246.61,246.5891667,52.0016667,248.6220833,246.6841667,173.3557478,61.17875,70.3029167]
dec = [31.132,-24.6544722,18.1346944,25.6959722,31.1588611,30.2175278,-4.6609722,25.8890556,7.5693611,31.2567222,19.2055556,44.2580556,-77.1196389,-34.1541667,-35.9563056,50.3625,$
    -77.1196389,49.9858333,-36.9578611,42.2072222,9.07,68.0377778,-36.9547222,-24.4083333,-24.3845278,30.1336944,-15.7837222,-24.5801111,-70.1947966,26.3156389,25.7766389]
get_radec_slw, coord, plot_coord
for obj = 0, n_elements(obj_name)-1 do begin
for j = 0, n_elements(pixelname)-1 do begin
    ;The path to the data that you want to fit.  wavelength in um and flux in Jy.
    READCOL, '~/BHR71/DATA/PIXEL_SPECTRUM/EXTENDED_CORRECTION/'+PIXELNAME[j]+'.TXT', FORMAT='D,D', WL, FLUX
    ;READCOL, '~/bhr71/data/center_ext_corrected', format='D,D', wl, flux
    ;READCOL, '~/Rebecca/L1455-IRS3_spirecube/L1455-IRS3_'+pixelname[j]+'.txt', format='D,D',wl, flux
    ;READCOL, '~/data/spire_corrected_joel/'+obj_name[obj]+'_corrected.txt', format='D,D', wl, flux
    ;Convert the flux to appropriate unit
    c = 2.998d8
    flux = flux*1d-4*c/(wl*1d-6)^2*1d-6*1d-26
    ;Information about the line that you want to fit including the range for baseline fitting.
    line_name = ['p-H2O2_02-1_11','CO8-7','13CO8-7','CO7-6','CI370','13CO7-6','p-H2O2_11-2_02','CO6-5','13CO6-5','HCO+P7-6','CO5-4','o-H2O1_10-1_01','13CO5-4','CI610','CO4-3']
    line_center = [303.67,325.26,340.42,371.65,370.3,389.01,398.92,433.56,453.81,480.13,520.23,538.29,544.54,608.95,650.25]
    ;Range of the line profile
    range = [[303,305],[324,326],[339.5,340.5],[370.5,372.5],[369.5,370.5],[388,389.5],[397,399.5],[432,435],[452,455],[479,482],[516,522],[536,540],[542,546],[607,611],[647,654]]
    ;Range of the baseline
    cont = [[301,303,304,306],[321,324,326,329],[336,339.5,340.5,343],[355,372,373,388],[355,369,370,388],[380,388,389.5,393],[393,397,401,415],[425,432,435,442],[442,452,455,470],$
            [465,479,482,499],[503,518,522,531],[525,536,540,542],[540,541,546,563],[590,607,611,628],[628,647,654,662]]
    ;The path to the output file for print out the fitting result.
    openw, lun, '~/bhr71/data/'+pixelname[j]+'lines.txt', /get_lun
    ;openw, lun, '~/bhr71/data/center_slw.txt', /get_lun
    ;openw, lun, '~/Rebecca/plots/'+pixelname[j]+'_lines.txt', /get_lun
    ;openw, lun, '~/data/spire_corrected_joel/line_fitting/'+obj_name[obj]+'_slw_lines.txt', /get_lun
    printf, lun, format='((a12,2x),13(a16,2x))', 'Line', 'WL (um)', 'Sig_Cen (um)', 'Str(erg/cm2)', 'Sig_str(erg/cm2)', 'FWHM (um)', 'Sig_FWHM (um)', 'Base_str','SNR', 'E_u (K)', 'A (s-1)', 'g', 'RA', 'Dec'
    for i = 0, n_elements(line_name)-1 do begin
        ;select the baseline
        indb = where((wl gt cont[0,i] and wl lt cont[1,i]) or (wl gt cont[2,i] and wl lt cont[3,i]))
        wlb = wl[indb] & fluxb = flux[indb]
        ;fit the baseline and return the baseline parameter in 'base_para'
        fit_line, obj_name[obj]+pixelname[j], line_name[i], wlb, fluxb, status, errmsg, cen_wl, sig_cen_wl, str, sig_str, fwhm, sig_fwhm, base_para, snr, /baseline
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
        if keyword_set(test) then fit_line, obj_name[obj]+pixelname[j], line_name[i], wll, fluxx, status, errmsg, cen_wl, sig_cen_wl, str, sig_str, fwhm, sig_fwhm, base_para, snr, line, /single_gauss, /test
        if not keyword_set(test) then fit_line, obj_name[obj]+pixelname[j], line_name[i], wll, fluxx, status, errmsg, cen_wl, sig_cen_wl, str, sig_str, fwhm, sig_fwhm, base_para, snr, line, /single_gauss
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

pro extract_spire_ssw, test=test
pixelname = ['SSWA1','SSWA2','SSWA3','SSWA4','SSWB1','SSWB2','SSWB3','SSWB4','SSWB5','SSWC1','SSWC2','SSWC3','SSWC4','SSWC5','SSWC6','SSWD1','SSWD2','SSWD3','SSWD4','SSWD6','SSWD7','SSWE1','SSWE2','SSWE3','SSWE4','SSWE5','SSWE6','SSWF1','SSWF2','SSWF3','SSWF5','SSWG1','SSWG2','SSWG3','SSWG4']
obj_name = ['bhr71']
;pixelname = ['Ext_corrected']
;obj_name = ['b1-a_spire','hh46_spire','l1551-irs5_spire','tmc1a_spire','b1-c_spire','iras03245_spire','l483_spire','tmr1_spire','b335_spire','iras03301_spire','l723-mm_spire','v1057cyg_spire','ced110_spire','iras15398_spire','rcra-irs5a_spire','v1331cyg_spire','dkcha_spire','l1014_spire','rcra-irs7b_spire','v1515cyg_spire','fuori_spire','l1157_spire','rcra-irs7c_spire','vla1623_spire','gss30_spire','l1455-irs3','rno91_spire','wl12_spire','hd100546_spire','l1489_spire','tmc1_spire']
ra = [53.3195833,246.8725,67.89208333,69.8958333,53.3245833,51.9129167,274.3745833,69.8070167,294.25375,53.3033333,289.47375,314.72375,166.6958333,235.7554167,285.4504167,315.2883333,$
    193.3216667,321.03125,285.485,305.95,86.343333,309.77625,285.4804167,246.61,246.5891667,52.0016667,248.6220833,246.6841667,173.3557478,61.17875,70.3029167]
dec = [31.132,-24.6544722,18.1346944,25.6959722,31.1588611,30.2175278,-4.6609722,25.8890556,7.5693611,31.2567222,19.2055556,44.2580556,-77.1196389,-34.1541667,-35.9563056,50.3625,$
    -77.1196389,49.9858333,-36.9578611,42.2072222,9.07,68.0377778,-36.9547222,-24.4083333,-24.3845278,30.1336944,-15.7837222,-24.5801111,-70.1947966,26.3156389,25.7766389]
get_radec_ssw, coord, plot_coord
for obj = 0, n_elements(obj_name)-1 do begin
for j = 0, n_elements(pixelname)-1 do begin
    ;The path to the data that you want to fit.  wavelength in um and flux in Jy.
    readcol, '~/bhr71/data/pixel_spectrum/extended_correction/'+pixelname[j]+'.txt', format='D,D', wl, flux
    ;readcol, '~/bhr71/data/center_ext_corrected', format='D,D', wl, flux
    ;READCOL, '~/Rebecca/L1455-IRS3_spirecube/L1455-IRS3_'+pixelname[j]+'.txt', format='D,D',wl, flux
    ;READCOl, '~/data/spire_corrected_joel/'+obj_name[obj]+'_corrected.txt', format='D,D', wl, flux
    ;Convert the flux to appropriate unit
    c = 2.998d8
    flux = flux*1d-4*c/(wl*1d-6)^2*1d-6*1d-26
    ;Information about the line that you want to fit including the range for baseline fitting.
    line_name = ['CO13-12','NII205','CO12-11','CO11-10','13CO11-10','o-H2O3_21-3_12','CO10-9','p-H2O1_11-0_00','13CO10-9','CO9-8']
    line_center = [200.27,205.178,216.93,236.61,247.66,257.79,260.24,269.46,272.39,289.12]
    ;Range of the line profile
    range = [[199.7,200.7],[204.6,205.8],[216.5,217.2],[236.0,237.2],[247,248],[257,258],[259.6,260.6],[268.8,269.7],[271.9,272.6],[288.5,289.7]]
    ;Range of the baseline
    cont = [[198.7,199.6,200.8,203.5],[203.5,204.5,206,210],[210,216.5,217.5,220],[230,235.5,237.5,245],[245,247,248,255],[254,256,258,259],[255,259.5,260.7,267],[262,268.8,269.7,271],[270,271.3,272.8,280],[280,288.5,289.8,291]]
    ;The path to the output file for print out the fitting result.
    openw, lun, '~/bhr71/data/'+pixelname[j]+'lines.txt', /get_lun
    ;openw, lun, '~/bhr71/data/center_ssw.txt', /get_lun
    ;openw, lun, '~/Rebecca/data/'+pixelname[j]+'lines.txt', /get_lun
    ;openw, lun, '~/data/spire_corrected_joel/line_fitting/'+obj_name[obj]+'_ssw_lines.txt', /get_lun
    printf, lun, format='((a16,2x),13(a16,2x))', 'Line', 'WL (um)', 'Sig_Cen (um)', 'Str(erg/cm2)', 'Sig_str(erg/cm2)', 'FWHM (um)', 'Sig_FWHM (um)', 'Base_str','SNR', 'E_u (K)', 'A (s-1)', 'g', 'RA', 'Dec'
    for i = 0, n_elements(line_name)-1 do begin
        ;select the baseline
        indb = where((wl gt cont[0,i] and wl lt cont[1,i]) or (wl gt cont[2,i] and wl lt cont[3,i]))
        wlb = wl[indb] & fluxb = flux[indb]
        ;fit the baseline and return the baseline parameter in 'base_para'
        fit_line, obj_name[obj]+pixelname[j], line_name[i], wlb, fluxb, status, errmsg, cen_wl, sig_cen_wl, str, sig_str, fwhm, sig_fwhm, base_para, snr, /baseline
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
        if keyword_set(test) then fit_line, obj_name[obj]+pixelname[j], line_name[i], wll, fluxx, status, errmsg, cen_wl, sig_cen_wl, str, sig_str, fwhm, sig_fwhm, base_para, snr, line, /single_gauss, /test
        if not keyword_set(test) then fit_line, obj_name[obj]+pixelname[j], line_name[i], wll, fluxx, status, errmsg, cen_wl, sig_cen_wl, str, sig_str, fwhm, sig_fwhm, base_para, snr, line, /single_gauss
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
  extract_spire_slw, /test
  extract_spire_ssw, /test
end
