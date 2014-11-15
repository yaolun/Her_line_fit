pro test_fitting,i, test=test
readcol, '~/bhr71/data/pacs_coord.txt', format='D,D,D', pix_ind, ra, dec
;pixelname = ['SLWA1','SLWA2','SLWB1','SLWB2','SLWB3','SLWC2','SLWC3','SLWC4','SLWC5','SLWD2','SLWD3','SLWD4','SLWE2','SLWE3']
for j = 20,20 do begin
readcol, '~/bhr71/data/pacs_pixel'+strtrim(string(j+1),1)+'.txt', format = 'D,D,D', wl, flux, flux_stddev
c = 2.998d8
flux = flux*1d-4*c/(wl*1d-6)^2*1d-6*1d-26
;SPIRE
;line_name = ['H2O303','CO87','13CO87','CO76','CI370','13CO76','H2O398','CO65','13CO65','HCOP76','CO54','H2O529','13CO54','CI610','CO43']
;line_center = [303.67,325.26,340.42,371.65,370.3,389.01,398.92,433.56,453.81,480.13,520.23,538.29,544.54,608.95,650.25]
;range = [[303,305],[324,326],[339.5,340.5],[370.5,372.5],[369.5,370.5],[388,389.5],[397,399.5],[432,435],[452,455],[479,482],[516,522],[536,540],[542,546],[607,611],[647,654]]
;cont = [[301,303,304,306],[321,324,326,329],[336,339.5,340.5,343],[355,372,373,388],[355,369,370,388],[380,388,389.5,393],[393,397,401,415],[425,432,435,442],[442,452,455,470],$
;       [465,479,482,499],[503,518,522,531],[525,536,540,542],[540,541,546,563],[590,607,611,628],[628,647,654,662]]

;PACS
line_name=['Hotwater','OI3P1-3P2','OH13-9','o-H2O3_30-2_21','OH8-2','OH9-3','p-H2O3_22-2_11','CO29-28','CO28-27','CO27-26','CO25-24','CO24-23','CO23-22','CO22-21',$
      'OH3-1','OH2-0','NII','CO21-20','CO20-19','CO19-18','CO18-17','OI3P0-3P1','CO17-16','CII2P3_2-2P1_2','CO16-15','CO15-14','o-H2O3_03-2_12','o-H2O2_21-2_12','CO14-13','CO30-29','CO31-30','CO32-31','CO33-32','CO34-33','CO35-34','CO36-35','CO37-36','CO38-37','CO39-38','CO40-39']
      ;,'B2Acont1','B2Acont2','B2Bcont1','B2Bcont2','R1Acont1','R1Acont2','R1Bcont1','R1Bcont2']
line_center = [55.1,63.23,65.17,66.4,84.47,84.65,90.05,90.16,93.34,96.77,104.46,108.76,113.46,118.58,119.31,119.52,122,124.19,130.37,137.196,144.78,145.63,153.27,157.85,162.81,173.63,$
        174.75,180.61,185.999,87.19,84.41,81.81,79.36,77.06,74.89,72.84,70.91,69.07,67.34,65.69]
    ;Range of the line profile
range=[[54.6,55.6],[62.73,63.73],[64.67,65.67],[65.9,66.9],$
    [83.97,84.6],[84.5,85],[89,90.1],[90.1,91],[92.84,93.84],[96.27,97.27],[103.96,104.96],$
    [108.26,109.26],[112.96,113.96],[118.08,119.08],[118.81,119.5],[119.4,120.02],$
    [121.5,122.5],[123.69,124.69],[129.87,130.87],[136.696,137.696],[144.28,145.28],[145.13,146.13],$
    [152.77,153.77],[157.35,158.35],[162.31,163.31],[173.13,174.13],[174.25,175.25],[180.11,181.11],[185.499,186.499],[86.69,87.69],$
    [83.91,84.5],[81.31,82.31],[78.86,79.86],[76.56,77.56],[74.39,75.39],[72.34,73.34],[70.41,71.41],[68.57,69.57],[66.84,67.84],[65.19,66.19]];,[56,57],[68,70],[75,77],[94,96],[110,112],[132,134],[150,152],[176,178]]
    ;Range of the baseline
cont=[[54.9,55.05,55.2,55.4],[62.9,63.1,63.3,63.6],[63,65.1,65.35,66],[55,63,66.6,69],[80,84.35,84.7,89],[80,84.35,84.7,89],$
      [85.1,89.85,90.25,92],[85,89.85,90.25,92],[90.9,93.2,93.45,96],[92,96.65,96.9,100],$
      [102,104.35,104.6,108],[105.5,108.65,108.9,110],$
      [108,113.4,113.65,118],[113,118.45,118.7,118.95],$
      [118.9,119.1,119.6,121],[118.9,119.1,119.6,121],$
      [119,121.8,122.2,123],[122.2,124.05,124.3,129],$
      [125,130.25,130.5,135],[132,137.1,137.35,139],$
      [140,144,145,145.5],[144.95,145.45,145.65,152],[152.5,153.1,153.4,157],[155,157.5,158.0,162],[158,162.7,162.95,168],$
      [168,173.5,173.75,174.0],[174.0,174.5,174.75,179],[175,180.5,180.8,185],[180,185.9,186.1,186.5],$
      [85,86.69,87.69,89],[70,83.91,84.5,89],[79.8,81.31,82.31,83.91],[77.56,78.86,79.86,81.31],[75.39,76.56,77.56,78.86],[73.34,74.39,75.39,76.56],[71.41,72.34,73.34,74.39],$
      [69.57,70.41,71.41,72.34],[67.84,68.57,69.57,70.41],[66.19,66.84,67.84,68.57],[62,65.19,66.19,66.84]];,[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0]]

indb = where((wl gt cont[0,i] and wl lt cont[1,i]) or (wl gt cont[2,i] and wl lt cont[3,i]))
wlb = wl[indb] & fluxb = flux[indb]
;fit the baseline and return the baseline parameter in 'base_para'
fit_line, 'pacs_pixel'+strtrim(string(j+1),1), line_name[i], wlb, fluxb, status, errmsg, cen_wl, sig_cen_wl, str, sig_str, fwhm, sig_fwhm, base_para, snr, /baseline
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
if keyword_set(test) then fit_line, 'pacs_pixel'+strtrim(string(j+1),1), line_name[i], wll, fluxx, status, errmsg, cen_wl, sig_cen_wl, str, sig_str, fwhm, sig_fwhm, base_para, snr, line, /single_gauss, /test
if not keyword_set(test) then fit_line, 'pacs_pixel'+strtrim(string(j+1),1), line_name[i], wll, fluxx, status, errmsg, cen_wl, sig_cen_wl, str, sig_str, fwhm, sig_fwhm, base_para, snr, line, /single_gauss
print, 'pacs_pixel'+strtrim(string(j+1),1)
print, snr
print, snr eq double(NaN)



;Print the fittng result into text file
if status le 0 then begin
    print, format = '((a16,2X),(a50))', line_name[i], errmsg
endif else begin
    read_line_ref, line_name[i], E_u, A, g
    base_str = interpol(fluxl, wll, cen_wl)
    ;printf, lun, format = '((a16,2X),7(g16.4,2X),3(g16.4,2X),2(g16,2X))', line_name[i], cen_wl, sig_cen_wl, str, sig_str, fwhm, sig_fwhm, snr, E_u, A, g, coord[0,j], coord[1,j]
    ;print, format = '((a16,2X),7(g16.4,2X),3(g16.4,2X),2(g16.10,2X))', line_name[i], cen_wl, sig_cen_wl, str, sig_str, fwhm, sig_fwhm, snr, E_u, A, g, ra[j], dec[j]
endelse 
endfor

end


