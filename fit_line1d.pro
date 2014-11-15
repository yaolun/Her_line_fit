pro fit_line1d, name, wl, flux, status, errmsg, cen_wl, sig_cen_wl, str, sig_str, fwhm, sig_fwhm, base_str, snr, fixed = fixed, plot=plot, text=text, baseline=baseline, msg

  c = 2.998d8
  ;make the unit consist with each other. Change F_nu (Jy) -> F_lambda (W cm-2 um-1)

  flux = flux*1d-4*c/(wl*1d-6)^2*1d-6*1d-26
  if keyword_set(baseline) then begin
  height = str/(2*!PI)^0.5/fwhm*2.354
  gauss = height*exp((-(wl-cen_wl)^2)/2/(fwhm/2.354)^2)
  f = flux
  flux = flux - gauss
  endif

  weight = 1+0*flux
  wl = double(wl)
  flux = double(flux)
  weight = double(weight)
  expo = round(alog10(abs(median(flux))))*(-1)+1
  factor = 10d^expo
  nwl = wl - median(wl)
  fluxx = flux*factor
  nflux = fluxx - median(fluxx)
  
  ;define the initial guess of the line profile
  start = dblarr(5)
  start[0] = max(nflux)
  start[1] = median(nwl)
  ind = where(nflux gt 0.5*(max(nflux) - min(nflux)) + min(nflux))
  start[2] = (max(nwl[ind]) - min(nwl[ind]))
  start[3] = (nflux[n_elements(nwl)-1] - nflux[0])/(nwl[n_elements(nwl)-1] - nwl[0])
  start[4] = nflux[0]
  
  ;Do the fitting
  ;First, construct the structure of the constrain.  Here to constrain that the width of the Gaussian cannot larger than the range of the wavelength put in  to this program
  parinfo = replicate({parname:'', value:0.D, fixed:0, limited:[0,0], limits:[0.D,0.D]}, 5)
  parinfo[*].parname = ['height','center','width','slope','offset']
  parinfo[*].value = start
  parinfo[2].limited = [0,1] & parinfo[2].limits[1] = 2;0.5*(max(nwl)-min(nwl))
  parinfo[0].limited = [1,0] & parinfo[0].limits[0] = 0
  parinfo[1].limited = [1,1] & parinfo[1].limits = [min(nwl), max(nwl)]
  ;If keyword "fixed" is set then fix the gaussian profile fit by the previous fitting and fit the total spectrum
  if keyword_set(fixed) then begin
  parinfo[0].limited  = [1,1] & parinfo[1].limited = [1,1] & parinfo[2].limited = [1,1]
  parinfo[0].limits = [str/(2*!PI)^0.5/fwhm*2.354, str/(2*!PI)^0.5/fwhm*2.354]
  parinfo[1].limits = [cen_wl, cen_wl]
  parinfo[2].limits = [fwhm/2.354, fwhm/2.354]
  endif

  ;FIT it.  And also consider the case of having some error message.
if not keyword_set(baseline) then begin
  print, 'no baseline'
  result = mpfitfun('gauss_1dbase', nwl, nflux, weight, start, /quiet, perror=sigma, status = status, errmsg = errmsg, parinfo=parinfo)
  ;plot the spectrum when the fitting process fails to converge.
  if status le 0 then begin
    return
    end
  P = result
;  print, 'fitted parameters', p
;  print, 'para_sigma       ', sigma
  ;Recover everything since they are changed at first
  rms2 = total((gauss_1dbase(nwl,p)-nflux)^2)/(n_elements(wl)-2-1)
  rms = sqrt(rms2)

  sigma = sigma*rms
;  print, 'simga*RMS        ', sigma
  cen_wl = p[1] + median(wl) & sig_cen_wl = sigma[1]
  height = p[0]/factor & sig_height = sigma[0]/factor
  base_para = P[3:4]/factor & sig_base_para = sigma[3:4]/factor
  base_para[1] = base_para[1] + median(flux)
  fwhm = 2.354*abs(p[2]) & sig_fwhm = 2.354*abs(sigma[2])
  str = (2*!PI)^0.5*height*abs(p[2]) & sig_str = str*((sig_height/height)^2+(abs(sigma[2])/abs(p[2]))^2)^0.5
  base_str = 0.5*base_para[0]*((max(wl)-median(wl))^2-(min(wl)-median(wl))^2) + base_para[1]*((max(wl)-median(wl)) - (min(wl)-median(wl)))
;  print, 'Center', cen_wl, sigma[1]
;  print, 'Height', height, sig_height
;  print, 'FWHM  ', fwhm, sig_fwhm
;  print, 'Baseline_parameter', base_para
;  print, 'Sigma of Base_para', sig_base_para
;  print, 'Line Strength     ', str, sig_str

  ;plot, wl,base_para[0]*(wl-median(wl))^2+base_para[1]*(wl-median(wl))+base_para[2]
  ;Construc the reasonable array of parameter
  a = dblarr(6)
  a[0] = height & a[1] = cen_wl & a[2] = abs(p[2]) & a[3:4] = base_para
  ;rms2 = total((a[0]*exp((-(wl-a[1])^2)/2/a[2]^2)+base_para[0]*(wl-median(wl))^2+base_para[1]*(wl-median(wl))+base_para[2] - flux)^2)/(n_elements(wl)-2-1)
  ;rms = sqrt(rms2)
  ;Calculate the SNR
  d_lambda = 0.29979*wl^2/3*1d-5
  gauss = a[0]*exp((-(wl-a[1])^2)/2/a[2]^2)
  strr = total(transpose(d_lambda)*gauss)/fwhm
  residual = abs(flux - a[0]*exp((-(wl-cen_wl)^2)/2/a[2]^2)-base_para[0]*(wl-median(wl))-base_para[1])
  res = total(transpose(d_lambda)*residual)/(max(wl)-min(wl))
  snr = (strr/res)
;plot the fitted results with the original data
if keyword_set(plot) then begin
set_plot, 'ps'
!p.font = 0
device, filename = name+'.eps', /helvetica, /portrait, /encapsulated, isolatin = 1, font_size = 14, decomposed = 0, /color
loadct ,13
!p.thick = 1 & !x.thick = 3 & !y.thick = 3
  m = ''
  if keyword_set(text) then m = msg & print, 'text'
  maxx = max([max(flux), max(a[0]*exp((-(wl-a[1])^2)/2/a[2]^2)), max(base_para[0]*(wl-median(wl))+base_para[1])])
  minn = min([0,min(base_para[0]*(wl-median(wl))+base_para[1]), min(flux - (a[0]*exp(-(wl-a[1])^2/2/a[2]^2)+base_para[0]*(wl-median(wl))+base_para[1]))])
  plot, wl, flux/1d-22, psym = 4, xtitle = '!9m!3m', ytitle = '10!u-22!n W/cm!u2!n/!9m!3m', yrange = [minn/1d-22, maxx*1.1/1d-22]                              ;plot the original data
  oplot, wl, (a[0]*exp((-(wl-a[1])^2)/2/a[2]^2)+base_para[0]*(wl-median(wl))+base_para[1])/1d-22             ;plot the fitted curve
  oplot, wl, a[0]*exp((-(wl-a[1])^2)/2/a[2]^2)/1d-22, linestyle = 1                                                                       ;plot the Gaussian
  oplot, wl, (base_para[0]*(wl-median(wl))+base_para[1])/1d-22, color = 40                                   ;plot the baseline
  oplot, wl, (flux-(a[0]*exp((-(wl-a[1])^2)/2/a[2]^2)+base_para[0]*(wl-median(wl))+base_para[1]))/1d-22, color = 110   ;plot the reidual
  xyouts, 0.2, 0.85, 'SNR='+strtrim(string(snr),1), /normal
  xyouts, 0.2, 0.8, 'Center='+strtrim(string(cen_wl),1), /normal
  xyouts, 0.2, 0.75, 'FWHM='+strtrim(string(a[2]),1), /normal
  if keyword_set(text) then  xyouts, 0.2, 0.7, m, /normal
device, /close_file, decomposed = 1
!p.multi = 0
endif

endif

if keyword_set(baseline) then begin
  print, 'plot'
  result = mpfitfun('base1d', nwl, nflux, weight, start[3:4], /quiet, perror=sigma, status=status, errmsg=errmsg)
  p = result
  base_para = P/factor & sig_base_para = sigma/factor
  base_para[1] = base_para[1] + median(flux)
  base_str = 0.5*base_para[0]*((max(wl)-median(wl))^2-(min(wl)-median(wl))^2) + base_para[1]*((max(wl)-median(wl)) - (min(wl)-median(wl)))
  d_lambda = 0.29979*wl^2/3*1d-5
  gauss = height*exp((-(wl-cen_wl)^2)/2/(fwhm/2.354)^2)
  strr = total(transpose(d_lambda)*gauss)/fwhm
  residual = abs(flux - base_para[0]*(wl-median(wl))-base_para[1])
  res = total(transpose(d_lambda)*residual)/(max(wl)-min(wl))
  snr = (strr/res)

  ;plot the fit baseline and the Gaussain profile from the previous fit
  set_plot, 'ps'
  !p.font = 0
  device, filename = name+'.eps', /helvetica, /portrait, /encapsulated, isolatin = 1, font_size = 14, decomposed = 0, /color
  loadct ,13
  !p.thick = 1 & !x.thick = 3 & !y.thick = 3
  maxx = max([max(f), max(base_para[0]*(wl-median(wl))+base_para[1])])
  minn = min([0,min(base_para[0]*(wl-median(wl))+base_para[1]), min(f - (gauss+base_para[0]*(wl-median(wl))+base_para[1]))])
  plot, wl, f/1d-22, psym = 4, xtitle = '!9m!3m2', ytitle = '10!u-22!n W/cm!u2!n/!9m!3m';, yrange = [minn/1d-22, maxx*1.1/1d-22]                              ;plot the original data
  oplot, wl, (gauss+base_para[0]*(wl-median(wl))+base_para[1])/1d-22                       ;plot the fitted curve
  oplot, wl, gauss/1d-22, linestyle = 1                                                    ;plot the Gaussian
  oplot, wl, (base_para[0]*(wl-median(wl))+base_para[1])/1d-22, color = 40                 ;plot the baseline
  oplot, wl, (f-(gauss+base_para[0]*(wl-median(wl))+base_para[1]))/1d-22, color = 110   ;plot the reidual
  xyouts, 0.2, 0.85, 'SNR='+strtrim(string(snr),1), /normal
  xyouts, 0.2, 0.8, 'Center='+strtrim(string(cen_wl),1), /normal
  xyouts, 0.2, 0.75, 'FWHM='+strtrim(string(fwhm),1), /normal
device, /close_file, decomposed = 1
!p.multi = 0
  endif


end
pro find_peak, name, wl, flux, peak, range, str, status, fwhm
fit_line1d, name, wl, flux, status, errmsg, cen_wl, sig_cen_wl, str, sig_str, fwhm, sig_fwhm, base_str, snr
if status le 0 then  begin
  range = [min(wl), max(wl)]
endif else begin
peak = cen_wl
r = -500*(cen_wl-303)/367+900
dl = cen_wl/r
range = [cen_wl-5*dl, cen_wl+5*dl]
endelse
end

