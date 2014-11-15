pro fit_line, pixelname, linename, wl, flux, status, errmsg, cen_wl, sig_cen_wl, str, sig_str, fwhm, sig_fwhm, base_para, snr, line, $
baseline=baseline, test=test, single_gauss=single_gauss, double_gauss=double_gauss
;---------------------------------
A = FINDGEN(17) * (!PI*2/16.)
; Define the symbol to be a unit circle with 16 points, 
; and set the filled flag:
USERSYM, 0.5*COS(A), 0.5*SIN(A), /FILL
;---------------------------------
  c = 2.998d8
  ;make the unit consist with each other. Change F_nu (Jy) -> F_lambda (W cm-2 um-1)
  ;flux = flux*1d-4*c/(wl*1d-6)^2*1d-6*1d-26

  weight = 1+0*flux
  wl = double(wl)
  flux = double(flux)
  weight = double(weight)
  expo = round(alog10(abs(median(flux))))*(-1)+1
  factor = 10d^expo
  nwl = wl - median(wl)
  fluxx = flux*factor
  nflux = fluxx - median(fluxx)
  
  ;baseline part
if keyword_set(baseline) then begin
;    start = dblarr(2)
;    start[0] = (nflux[n_elements(nwl)-1] - nflux[0])/(nwl[n_elements(nwl)-1] - nwl[0])
;    start[1] = nflux(0)
;    ;Fit the baseline with 1st order polynomial
;    result = mpfitfun('base1d', nwl, nflux, weight, start, /quiet, perror=sigma, status = status, errmsg = errmsg)
;    p = result/factor & p_sig = sigma/factor
;    p[1] = p[1]+median(flux)
;    base = p[0]*(wl-median(wl)) + p[1]
;    base_para = [p[0],p[1]-p[0]*median(wl)]
;    mid_base = median(base)
;    residual = flux -base
    
    ;Fit the baseline with 2nd order polynomial
    start = dblarr(3)
    start[0] = 0
    start[1] = (nflux[n_elements(nwl)-1] - nflux[0])/(nwl[n_elements(nwl)-1] - nwl[0])
    start[2] = nflux(0)
    result = mpfitfun('base2d', nwl, nflux, weight, start, /quiet, perror=sigma, status=status, errmsg=errmsg)
    p = result/factor & p_sig = sigma/factor
    p[2] = p[2] + median(flux)
    base = p[0]*(wl-median(wl))^2 + p[1]*(wl-median(wl)) + p[2]
    base_para = [p[0], p[1]-2*p[0]*median(wl), p[2]-p[1]*median(wl)+p[0]*median(wl)^2]
    mid_base = median(base)
    residual = flux-base
    ;-------------------------------------------
    set_plot, 'ps'
    !p.font = 0
    device, filename = '/Users/yaolun/bhr71/plots/base/'+pixelname+'_'+linename+'base.eps', /helvetica, /portrait, /encapsulated, isolatin = 1, font_size = 14, decomposed = 0, /color
    loadct ,13
    !p.thick = 3 & !x.thick = 3 & !y.thick = 3
    plot, wl, flux/1d-22, psym = 10, xtitle = '!9m!3m', ytitle = '10!u-22!n W/cm!u2!n/!9m!3m'                   ;plot the original data
    oplot, wl, base/1d-22, color = 40                                                                           ;plot the fitted curve
    oplot, wl, residual/1d-22, psym = 10, color = 250                                                           ;plot the reidual
    device, /close_file, decomposed = 1
endif
  
  ;fit the baseline substracted spectrum with single Gaussian 
if not keyword_set(baseline) then begin
  ;define the initial guess of the line profile
  ;--------------------------------------------
  ;First, construct the structure of the constrain.  Here to constrain that the width of the Gaussian cannot larger than the range of the wavelength put into this program
  r = -700*(median(wl)-200)/470+1000
  dl = median(wl)/r
  ;--------------------------------------------
  ;For single Gaussian fit
  if keyword_set(single_gauss) then begin
    start = dblarr(3)
    start[0] = max(nflux)
    start[1] = line[0] - median(wl);nwl[where(nflux eq max(nflux))]
    ind = where(nflux gt 0.5*(max(nflux) - min(nflux)) + min(nflux))
    start[2] = dl;(max(nwl[ind]) - min(nwl[ind]))
  endif
  ;For double Gaussian fit
  if keyword_set(double_gauss) then begin
    start = dblarr(6) & nflux_sort = sort(reverse(nflux))
    start[0] = nflux_sort[0] & start[3] = nflux_sort[1]
    start[1] = nwl[where(nflux eq nflux_sort[0])] & start[4] = nwl[where(nflux eq nflux_sort[1])]
    start[2] = dl & start[5] = dl
  endif

  if keyword_set(single_gauss) then begin
    parinfo = replicate({parname:'', value:0.D, fixed:0, limited:[0,0], limits:[0.D,0.D]}, 3)
    parinfo[*].parname = ['height','center','width']
    parinfo[*].value = start
    parinfo[0].limited = [1,0] & parinfo[0].limits[0] = 0
    parinfo[1].limited = [1,1] & parinfo[1].limits = line[1:2]-median(wl);[min(nwl), max(nwl)]
    parinfo[2].limited = [0,1] & parinfo[2].limits[1] = 4.5*dl
  endif
  if keyword_set(double_gauss) then begin
    parinfo = replicate({parname:'', value:0.D, fixed:0, limited:[0,0], limits:[0.D,0.D]}, 6)
    parinfo[*].parname = ['height_1','center_1','width_1','height_2','center_2','width_2']
    parinfo[*].value = start
    parinfo[0].limited = [1,0] & parinfo[0].limits[0] = 0
    parinfo[3].limited = [1,0] & parinfo[3].limits[0] = 0
    parinfo[1].limited = [1,1] & parinfo[1].limits = line[2:3]-median(wl)
    parinfo[4].limited = [1,1] & parinfo[4].limits = line[4:5]-median(wl)
    parinfo[2].limited = [0,1] & parinfo[2].limits[1] = 4.5*dl
    parinfo[4].limited = [0,1] & parinfo[4].limits[1] = 4.5*dl
  endif
  ;-------------------------------------------
  ;Fit it!
  if keyword_set(single_gauss) then func = 'gauss'
  if keyword_set(double_gauss) then func = 'double_gauss'
  result = mpfitfun(func, nwl, nflux, weight, start, /quiet, perror=sigma, status = status, errmsg = errmsg, parinfo=parinfo)
  p = result
    if status gt 0 then begin
    ;Recover everything since they are changed at first.  And calculate the physical quantities
      ;----------------------------------------------------------------
      if keyword_set(single_gauss) then begin
        rms2 = total((gauss(nwl,p)-nflux)^2)/(n_elements(wl)-2-1)
        rms = sqrt(rms2)
        sigma = sigma*rms
        cen_wl = p[1] + median(wl) & sig_cen_wl = sigma[1]
        height = p[0]/factor & sig_height = sigma[0]/factor
        fwhm = 2.354*abs(p[2]) & sig_fwhm = 2.354*abs(sigma[2])
        str = (2*!PI)^0.5*height*abs(p[2]) & sig_str = str*((sig_height/height)^2+(abs(sigma[2])/abs(p[2]))^2)^0.5
        gauss = height*exp(-(wl-cen_wl)^2/2/p[2]^2)
        residual = flux - gauss
        noise = stddev(residual)
        snr = height/noise
      endif
      if keyword_set(double_gauss) then begin
	 print, 'double'
         rms2 = total((double_gauss(nwl,p)-nflux)^2)/(n_elements(wl)-2-1)
         rms = sqrt(rms2)
         sigma = sigma*rms
         cen_wl = [p[1]+median(wl), p[4]+median(wl)] & sig_cen_wl = [sigma[1],sigma[4]]
         height = [p[0],p[3]]/factor & sig_height = [sigma[0],sigma[1]]/factor
         fwhm = 2.354*[abs(p[2]), abs(p[5])] & sig_fwhm = 2.354*[abs(sigma[2]), abs(sigma[5])]
         str = (2*!PI)^0.5*[height[0]*abs(p[2]), height[1]*abs(p[5])] & sig_str = [str[0]*((sig_height[0]/height[0])^2+(abs(sigma[2])/abs(p[2]))^2)^0.5,str[1]*((sig_height[1]/height[1])^2+(abs(sigma[5])/abs(p[5]))^2)^0.5]
         gauss = height[0]*exp(-(wl-cen_wl[0])^2/2/p[2]^2) + height[1]*exp(-(wl-cen_wl[1])^2/2/p[5]^2)
         residual = flux - gauss
         noise = stddev(residual)
         snr = height/noise
      endif
      ;----------------------------------------------------------------
      if keyword_set(test) then begin
        if snr le 5 then begin
          set_plot, 'ps'
          !p.font = 0
          device, filename = '/Users/yaolun/bhr71/plots/'+pixelname+'_'+linename+'_below5sigma.eps', /helvetica, /portrait, /encapsulated, isolatin = 1, font_size = 14, decomposed = 0, /color
          loadct ,13
          !p.thick = 3 & !x.thick = 3 & !y.thick = 3
          maxx = max([max(flux), height])
          minn = min([0,min(flux)])
          plot, wl, flux/1d-22, psym = 10, xtitle = '!9m!3m', ytitle = '10!u-22!n W/cm!u2!n/!9m!3m', yrange = [minn/1d-22, maxx*1.1/1d-22]        ;plot the baseline substracted spectrum
          oplot, wl, (gauss)/1d-22, color = 80                                                                                                    ;plot the fitted curve(Gaussian)
          oplot, wl, (flux-gauss)/1d-22, psym = 10, color = 250                                                                                              ;plot the residual
          oplot, [line[0], line[0]], [-1000,1000], linestyle = 2
          if keyword_set(double_gauss) then oplot, [line[1],line[1]], [-1000,1000], linestyle = 2
          if keyword_set(single_gauss) then begin
            xyouts, 0.2, 0.85, 'SNR='+strtrim(string(snr),1), /normal
            xyouts, 0.2, 0.8, 'FWHM='+strtrim(string(fwhm),1), /normal
          endif
          if keyword_set(double_gauss) then begin
            xyouts, 0.2, 0.85, 'SNR='+strtrim(string(snr[0]),1), /normal
            xyouts, 0.2, 0.8, '    '+strtrim(string(snr[1]),1), /normal
            xyouts, 0.2, 0.75, 'FWHM='+strtrim(string(fwhm[0]),1), /normal
            xyouts, 0.2, 0.7, '     '+strtrim(string(fwhm[1]),1), /normal
          endif
          xyouts, 0.7, 0.85, title_name(linename), /normal
          device, /close_file, decomposed = 1
          !p.multi = 0
        endif
      endif
      if not keyword_set(test) then begin
        ;Make a plot
        ;plot the well-functional fitting result
        set_plot, 'ps'
        !p.font = 0
        device, filename = '/Users/yaolun/bhr71/plots/'+pixelname+'_'+linename+'.eps', /helvetica, /portrait, /encapsulated, isolatin = 1, font_size = 14, decomposed = 0, /color
        loadct ,13
        !p.thick = 3 & !x.thick = 3 & !y.thick = 3
        maxx = max([max(flux), height])
        minn = min([0,min(flux)])
        plot, wl, flux/1d-22, psym = 10, xtitle = '!9m!3m', ytitle = '10!u-22!n W/cm!u2!n/!9m!3m', yrange = [minn/1d-22, maxx*1.1/1d-22]        ;plot the baseline substracted spectrum
        oplot, wl, (gauss)/1d-22, color = 80                                                                                                    ;plot the fitted curve(Gaussian)
        oplot, wl, (flux-gauss)/1d-22, psym = 10, color = 250                                                                                              ;plot the residual
        oplot, [line[0], line[0]], [-1000,1000]/1d-22, linestyle = 2
        if keyword_set(double_gauss) then oplot, [line[1],line[1]], [-1000,1000], linestyle = 2
        if keyword_set(single_gauss) then begin
          xyouts, 0.2, 0.85, 'SNR='+strtrim(string(snr),1), /normal
          xyouts, 0.2, 0.8, 'FWHM='+strtrim(string(fwhm),1), /normal
        endif
        if keyword_set(double_gauss) then begin
          xyouts, 0.2, 0.85, 'SNR='+strtrim(string(snr[0]),1), /normal
          xyouts, 0.2, 0.8, '    '+strtrim(string(snr[1]),1), /normal
          xyouts, 0.2, 0.75, 'FWHM='+strtrim(string(fwhm[0]),1), /normal
          xyouts, 0.2, 0.7, '     '+strtrim(string(fwhm[1]),1), /normal
        endif
        xyouts, 0.7, 0.85, title_name(linename), /normal
        device, /close_file, decomposed = 1
        !p.multi = 0
      endif
    endif else begin 
      ;Try to fit the line with shifting all of the flux value above zero.
      offset = 0;-min(flux)
      fluxs = flux + offset
      
      expo = round(alog10(abs(median(fluxs))))*(-1)+1
      factor = 10d^expo
      nwl = wl - median(wl)
      fluxx = fluxs*factor
      nflux = fluxx - median(fluxx)
      
      ;define the initial guess of the line profile
      ;--------------------------------------------
  
      ;First, construct the structure of the constrain.  Here to constrain that the width of the Gaussian cannot larger than the range of the wavelength put into this program
      r = -700*(median(wl)-200)/470+1000
      dl = median(wl)/r
      
      ;--------------------------------------------
      ;For single Gaussian fit
      if keyword_set(single_gauss) then begin
        start = dblarr(3)
        start[0] = max(nflux)
        start[1] = line[0] - median(wl);nwl[where(nflux eq max(nflux))]
        ind = where(nflux gt 0.5*(max(nflux) - min(nflux)) + min(nflux))
        start[2] = dl;(max(nwl[ind]) - min(nwl[ind]))
      endif
      ;For double Gaussian fit
      if keyword_set(double_gauss) then begin
        start = dblarr(6) & nflux_sort = sort(reverse(nflux))
        start[0] = nflux_sort[0] & start[3] = nflux_sort[1]
        start[1] = nwl[where(nflux eq nflux_sort[0])] & start[4] = nwl[where(nflux eq nflux_sort[1])]
        start[2] = dl & start[5] = dl
        onedbase = [0, 0]
      endif

      if keyword_set(single_gauss) then begin
        parinfo = replicate({parname:'', value:0.D, fixed:0, limited:[0,0], limits:[0.D,0.D]}, 3)
        parinfo[*].parname = ['height','center','width']
        parinfo[*].value = start
        parinfo[0].limited = [1,0] & parinfo[0].limits[0] = 0
        parinfo[1].limited = [1,1] & parinfo[1].limits = line[1:2]-median(wl);[min(nwl), max(nwl)]
        parinfo[2].limited = [0,1] & parinfo[2].limits[1] = 4.5*dl
      endif
      if keyword_set(double_gauss) then begin
        parinfo = replicate({parname:'', value:0.D, fixed:0, limited:[0,0], limits:[0.D,0.D]}, 6)
        parinfo[*].parname = ['height_1','center_1','width_1','height_2','center_2','width_2']
        parinfo[*].value = start
        parinfo[0].limited = [1,0] & parinfo[0].limits[0] = 0
        parinfo[3].limited = [1,0] & parinfo[3].limits[0] = 0
        parinfo[1].limited = [1,1] & parinfo[1].limits = line[2:3]-median(wl)
        parinfo[4].limited = [1,1] & parinfo[4].limits = line[4:5]-median(wl)
        parinfo[2].limited = [0,1] & parinfo[2].limits[1] = 4.5*dl
        parinfo[5].limited = [0,1] & parinfo[4].limits[1] = 4.5*dl
      endif
      ;-------------------------------------------
      ;Fit it!
      if keyword_set(single_gauss) then func = 'gauss'
      if keyword_set(double_gauss) then func = 'double_gauss'
      result = mpfitfun(func, nwl, nflux, weight, start, /quiet, perror=sigma, status = status, errmsg = errmsg, parinfo=parinfo)
      p = result
      if status gt 0 then begin
        print, 'GOTCHA!'
        ;Recover everything since they are changed at first.  And calculate the physical quantities
  
      ;----------------------------------------------------------------
      if keyword_set(single_gauss) then begin
        rms2 = total((gauss(nwl,p)-nflux)^2)/(n_elements(wl)-2-1)
        rms = sqrt(rms2)
        sigma = sigma*rms
        cen_wl = p[1] + median(wl) & sig_cen_wl = sigma[1]
        height = p[0]/factor & sig_height = sigma[0]/factor
        fwhm = 2.354*abs(p[2]) & sig_fwhm = 2.354*abs(sigma[2])
        str = (2*!PI)^0.5*height*abs(p[2]) & sig_str = str*((sig_height/height)^2+(abs(sigma[2])/abs(p[2]))^2)^0.5
        gauss = height*exp(-(wl-cen_wl)^2/2/p[2]^2)
        residual = flux - gauss
        noise = stddev(residual)
        snr = height/noise
      endif
      if keyword_set(double_gauss) then begin
         rms2 = total((double_gauss(nwl,p)-nflux)^2)/(n_elements(wl)-2-1)
         rms = sqrt(rms2)
         sigma = sigma*rms
         cen_wl = [p[1]+median(wl), p[4]+median(wl)] & sig_cen_wl = [sigma[1],sigma[4]]
         height = [p[0],p[3]]/factor & sig_height = [sigma[0],sigma[1]]/factor
         fwhm = 2.354*[abs(p[2]), abs(p[5])] & sig_fwhm = 2.354*[abs(sigma[2]), abs(sigma[5])]
         str = (2*!PI)^0.5*[height[0]*abs(p[2]), height[1]*abs(p[5])] & sig_str = [str[0]*((sig_height[0]/height[0])^2+(abs(sigma[2])/abs(p[2]))^2)^0.5,str[1]*((sig_height[1]/height[1])^2+(abs(sigma[5])/abs(p[5]))^2)^0.5]
         gauss = height[0]*exp(-(wl-cen_wl[0])^2/2/p[2]^2) + height[1]*exp(-(wl-cen_wl[1])^2/2/p[5]^2)
         residual = flux - gauss
         noise = stddev(residual)
         snr = height/noise
      endif
      ;----------------------------------------------------------------
       ;plot it
        set_plot, 'ps'
        !p.font = 0
        device, filename = '/Users/yaolun/bhr71/plots/cannot_fit/'+pixelname+'_'+linename+'_2nd.eps', /helvetica, /portrait, /encapsulated, isolatin = 1, font_size = 14, decomposed = 0, /color
        loadct ,13
        !p.thick = 3 & !x.thick = 3 & !y.thick = 3
        maxx = max([max(fluxs), p[0]/factor])
        minn = min([0,min(fluxs)])
        plot, wl, fluxs/1d-22, psym = 10, xtitle = '!9m!3m', ytitle = '10!u-22!n W/cm!u2!n/!9m!3m', yrange = [minn/1d-22, maxx*1.1/1d-22]        ;plot the baseline substracted spectrum
        oplot, wl, (gauss)/1d-22, color = 80                                                                                                    ;plot the fitted curve(Gaussian)
        oplot, wl, (fluxs-gauss)/1d-22, psym = 10, color = 21000                                                                                              ;plot the residual
        oplot, [line[0], line[0]], [-1000,1000], linestyle = 2
        if keyword_set(double_gauss) then oplot, [line[1],line[1]], [-1000,1000], linestyle = 2
        if keyword_set(single_gauss) then begin
          xyouts, 0.2, 0.85, 'SNR='+strtrim(string(snr),1), /normal
          xyouts, 0.2, 0.8, 'FWHM='+strtrim(string(fwhm),1), /normal
        endif
        if keyword_set(double_gauss) then begin
          xyouts, 0.2, 0.85, 'SNR='+strtrim(string(snr[0]),1), /normal
          xyouts, 0.2, 0.8, '    '+strtrim(string(snr[1]),1), /normal
          xyouts, 0.2, 0.75, 'FWHM='+strtrim(string(fwhm[0]),1), /normal
          xyouts, 0.2, 0.7, '     '+strtrim(string(fwhm[1]),1), /normal
        endif
        xyouts, 0.6, 0.85, title_name(linename), /normal
        device, /close_file, decomposed = 1
        !p.multi = 0
      endif else begin
        ;plot the spectrum when it is failed to converge
        ;-----------------------------------------------------------------
        if keyword_set(single_gauss) then begin
          ind = where(wl gt line[1] and wl lt line[2])
          fluxx = fluxs-min(fluxs)
          line_str = total(fluxx[ind])/(line[2]-line[1])
          noise = (total(fluxx)-total(fluxx[ind]))/(max(wl)-min(wl)-line[2]+line[1])
          if line_str/noise gt 2 then msg = 'over_2sigma' else msg = ''
        endif
        if keyword_set(double_gauss) then begin
          ind1 = where(wl gt line[2] and wl lt line[3]) & ind2 = where(wl gt line[4] and wl lt line[5])
          fluxx = fluxs - min(fluxs)
          line_str = [total(fluxx[ind1])/(line[3]-line[2]), total(fluxx[ind2])/(line[5]-line[4])]
          noise = (total(fluxx)-total(fluxx[ind1])-total(fluxx[ind2]))/(max(wl)-min(wl)-line[3]+line[2]-line[5]+line[4])
          ;if line_str/noise gt 2 then msg = 'over_2sigma' else msg = ''
          msg = ''
        endif
        set_plot, 'ps'
        !p.font = 0
        device, filename = '/Users/yaolun/bhr71/plots/cannot_fit/'+pixelname+'_'+linename+'cannot_fit'+msg+'.eps', /helvetica, /portrait, /encapsulated, isolatin = 1, font_size = 14, decomposed = 0, /color
        loadct ,13
        !p.thick = 3 & !x.thick = 3 & !y.thick = 3
        plot, wl, fluxs/1d-22, psym = 10, xtitle = '!9m!3m', ytitle = '10!u-22!n W/cm!u2!n/!9m!3m'  ;plot the baseline substracted spectrum
        if keyword_set(single_gauss) then begin
          oplot, [line[1], line[1]], [-1000,1000], linestyle = 2
          oplot, [line[2], line[2]], [-1000,1000], linestyle = 2
          xyouts, 0.2, 0.8, strtrim(string(line_str/noise),1), /normal
        endif
        if keyword_set(double_gauss) then begin
          oplot, [line[2], line[2]], [-1000,1000], linestyle = 2
          oplot, [line[3], line[3]], [-1000,1000], linestyle = 2
          oplot, [line[4], line[4]], [-1000,1000], linestyle = 2
          oplot, [line[5], line[5]], [-1000,1000], linestyle = 2
          xyouts, 0.2, 0.8, strtrim(string(line_str[0]/noise),1), /normal
          xyouts, 0.2, 0.75, strtrim(string(line_str[1]/noise),1), /normal
        endif
        xyouts, 0.2, 0.85, 'Fail to Converge', /normal
        xyouts, 0.6, 0.85, title_name(linename), /normal
        device, /close_file, decomposed = 1
        !p.multi = 0
      endelse
 
    endelse

    
endif
end
