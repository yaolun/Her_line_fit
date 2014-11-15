pro fit_line, name, wl, flux, status, errmsg, cen_wl, sig_cen_wl, str, sig_str, fwhm, sig_fwhm, base_str, snr

  c = 2.998d8
  ;make the unit consist with each other. Change F_nu (Jy) -> F_lambda (W cm-2 um-1)

  flux = flux*1d-4*c/(wl*1d-6)^2*1d-6*1d-26
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
  start = dblarr(6)
  start[0] = max(nflux)
  start[1] = median(nwl)
  ind = where(nflux gt 0.5*(max(nflux) - min(nflux)) + min(nflux))
  start[2] = (max(nwl[ind]) - min(nwl[ind]))
  start[3] = 0
  start[4] = (nflux[n_elements(nwl)-1] - nflux[0])/(nwl[n_elements(nwl)-1] - nwl[0])
  start[5] = nflux[0]
  
  ;Do the fitting
  result = mpfitfun('gauss_2dbase', nwl, nflux, weight, start, /quiet, perror=sigma, status = status, errmsg = errmsg)
  if status le 0 then begin
    return
    end
  P = result
;  print, 'fitted parameters', p
;  print, 'para_sigma       ', sigma

  rms2 = total((gauss_2dbase(nwl,p)-nflux)^2)/(n_elements(wl)-2-1)
  rms = sqrt(rms2)

  sigma = sigma*rms
;  print, 'simga*RMS        ', sigma
  cen_wl = p[1] + median(wl) & sig_cen_wl = sigma[1]
  height = p[0]/factor & sig_height = sigma[0]/factor
  base_para = P[3:5]/factor & sig_base_para = sigma[3:5]/factor
  base_para[2] = base_para[2] + median(flux)
  fwhm = 2.354*abs(p[2]) & sig_fwhm = 2.354*abs(sigma[2])
  str = (2*!PI)^0.5*height*abs(p[2]) & sig_str = str*((sig_height/height)^2+(abs(sigma[2])/abs(p[2]))^2)^0.5
  base_str = 1/3*base_para[0]*((max(wl)-median(wl))^3 - (min(wl)-median(wl))^3) + 0.5*base_para[1]*((max(wl)-median(wl))^2-(min(wl)-median(wl))^2) + base_para[2]*((max(wl)-median(wl)) - (min(wl)-median(wl)))
;  print, 'Center', cen_wl, sigma[1]
;  print, 'Height', height, sig_height
;  print, 'FWHM  ', fwhm, sig_fwhm
;  print, 'Baseline_parameter', base_para
;  print, 'Sigma of Base_para', sig_base_para
;  print, 'Line Strength     ', str, sig_str

  ;plot, wl,base_para[0]*(wl-median(wl))^2+base_para[1]*(wl-median(wl))+base_para[2]
  a = dblarr(6)
  a[0] = height & a[1] = cen_wl & a[2] = abs(p[2]) & a[3:5] = base_para
  rms2 = total((a[0]*exp((-(wl-a[1])^2)/2/a[2]^2)+base_para[0]*(wl-median(wl))^2+base_para[1]*(wl-median(wl))+base_para[2] - flux)^2)/(n_elements(wl)-2-1)
  rms = sqrt(rms2)
  
  d_lambda = 0.29979*wl^2/3*1d-5
  gauss = height*exp(-(wl-cen_wl)^2/2/p[2]^2)
  strr = total(transpose(d_lambda)*gauss)/fwhm
  residual = abs(flux - (a[0]*exp((-(wl-a[1])^2)/2/a[2]^2)+base_para[0]*(wl-median(wl))^2+base_para[1]*(wl-median(wl))+base_para[2]))
  res = total(transpose(d_lambda)*residual)/(max(wl)-min(wl))
  snr = strr/res
;plot the fitted results with the original data
set_plot, 'ps'
!p.font = 0
device, filename = name+'.eps', /helvetica, /portrait, /encapsulated, isolatin = 1, font_size = 14, decomposed = 0, /color
loadct ,13
!p.thick = 1 & !x.thick = 3 & !y.thick = 3
  maxx = max([max(flux), max(a[0]*exp((-(wl-a[1])^2)/2/a[2]^2)), max(base_para[0]*(wl-median(wl))^2+base_para[1]*(wl-median(wl))+base_para[2])])
  minn = min([0,min(base_para[0]*(wl-median(wl))^2+base_para[1]*(wl-median(wl))+base_para[2]), min(flux - (a[0]*exp(-(wl-a[1])^2/2/a[2]^2)+base_para[0]*(wl-median(wl))^2+base_para[1]*(wl-median(wl))+base_para[2]))])
  plot, wl, flux/1d-22, psym = 4, xtitle = '!9m!3m', ytitle = '10!u-22!n W/cm!u2!n/!9m!3m', yrange = [minn/1d-22, maxx*1.1/1d-22]                              ;plot the original data
  oplot, wl, (a[0]*exp((-(wl-a[1])^2)/2/a[2]^2)+base_para[0]*(wl-median(wl))^2+base_para[1]*(wl-median(wl))+base_para[2])/1d-22             ;plot the fitted curve
  oplot, wl, a[0]*exp((-(wl-a[1])^2)/2/a[2]^2)/1d-22, linestyle = 1                                                                       ;plot the Gaussian
  oplot, wl, (base_para[0]*(wl-median(wl))^2+base_para[1]*(wl-median(wl))+base_para[2])/1d-22, color = 40                                   ;plot the baseline
  oplot, wl, (flux-(a[0]*exp((-(wl-a[1])^2)/2/a[2]^2)+base_para[0]*(wl-median(wl))^2+base_para[1]*(wl-median(wl))+base_para[2]))/1d-22, psym = 2, color = 100   ;plot the reidual
  xyouts, 0.2, 0.85, 'SNR='+strtrim(string(snr),1), /normal
  xyouts, 0.2, 0.8, 'Center='+strtrim(string(cen_wl),1), /normal
device, /close_file, decomposed = 1
!p.multi = 0

end

