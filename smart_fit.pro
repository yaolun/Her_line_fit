;#> single_line.dc2
; Identifier   single_line  
;
; Purpose      Fits single gaussian/lorentzian line using the selected 
;              regions of data 
;
; Synopsis     status = single_line(info) 
;
; Arguments     Name      I/O  Type        Description
;               --------------------------------------------------------
;               info       I/O   structure  user_value of parent widget
; 
;           
; Returns      status, 1 if error occurs otherwise 0        
;
; Description   This routine fit and remove the line using Gaussian 
;               method for a given array of (wave,flux) in input AAR
;               The routine works both for baseline removed data (Fit Line)
;               and the original data with baseline (Composite Fit)
;            
;
; Dependencies   CALLS: GET_REDSHIFT, GET_RESOL, FIT_1LINE, POLY, LINEGAUSS,
;                       LORENTZIAN, SHOW_TEXT
;                CALLED FROM: GUI_FIT 
;
; Comment     This routine was named 'single_gauss.pro' until version 1.2 
;             (contained gaussian fit only)
;
; Example        status = single_line(info)
;
; Category    ISAP
;
; Filename   single_line.pro 
;
; Author     Iffat Khan (irk@ipac.caltech.edu)    
;
; Version    1.3
;
; History     1.0  10-11-97 IRK design and code
;                           this routine is a modified version
;                           of ISAP 1.3 routine "fit_line.pro"
;                           to handle the single gaussian fits
;                           only.
;             1.1  03-02-98 updated chi^2 computations as in 
;                           multi gausS
;             1.2  12-02-98 update "show_linelist" if open
;             1.3  15-11-99 modified for lorentzian fit   
;
;    $Log$
;    Revision 1.3  2006/07/19 21:58:20  dblevitan
;    added cvs header
;    updated print statements to standard
;    removed debug var in favor of !sm_debug
;
;-
;    $Id: single_line.pro 2244 2006-10-20 18:39:13Z don $
;
; Copyright (C) 1997, California Institute of Technology.
;           U.S. Government Sponsorship under NASA Contract NAS7-918 is acknowledged.
;******************************************************************************
;#<
FUNCTION smart_fit, wave, flux, stdev

;  debug = 0 ; DBL 7/18/2006

;  info = info
;  handle_value, info.handle, aar              ;working copy of AAR
;  aar = aar 
;  stop
;  factor = info.factor                        ;scale factor
;  wave = aar.data.wave                        ;wave array
;  flux = double(aar.data.flux)                ;flux array
;  stdev  = double(aar.data.stdev)             ;stdev array
;  func = info.func
;  width_fac = info.wid_conv


;; select zoomed/selected part
;   xra = info.xrange                          ;selected x-range
;   yra = info.yrange                          ;selected y-range
;   indexrange  = where(wave LE xra(1) $       ;indices of data within selection
;                AND wave GE xra(0) $
;                AND flux LE yra(1) $
;                AND flux GE yra(0), cpt)
;
;   IF cpt EQ 0 THEN BEGIN                     ;none selected, exit 
;     acknowledge,  $
;       text = 'Please select more data values'
;     return, -1
;   ENDIF
;
;   wave = wave(indexrange)                    ;selected wave array
;   flux = double(flux(indexrange))            ;selected flux array
;   stdev = double(stdev(indexrange))          ;selected flux array
;   line_range = xra                           ;report line_range         


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Get Redshift , Width , Line center if entered
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;redshift value, if entered
;   status = get_redshift(info)
;   IF status EQ -1 THEN return, -1
;
;; check if line height is fixed or free
;   widget_control, info.hgt_txt , $
;       get_value=fixhgt
;   IF strtrim(fixhgt(0),2) eq '' THEN $
;       fixhgt = 0.0 $
;   ELSE fixhgt = float(strtrim(fixhgt(0),2))
;   IF fixhgt NE 0.0 THEN $
;       fixhgt = fixhgt*factor
;
;; check if line center is fixed or free
;   widget_control, info.cntr_txt , $
;       get_value=fixwave
;   IF strtrim(fixwave(0),2) eq '' THEN $
;       fixwave = 0.0 $
;   ELSE fixwave = float(strtrim(fixwave(0),2))
;
;; check if line width is fixed or free
;   fixwidth = get_resol(info, aar, indexrange, $
;       fixwave=fixwave)
;   IF fixwidth EQ -1 THEN $
;       return, -1
;
;; reset above quantities if irrelevant
;   IF fixwidth LE 1e-6 THEN fixwidth=0
;   IF fixwave LE xra(0) OR $
;       fixwave GE xra(1) THEN fixwave = 0
;   IF fixwidth GT 0.0 THEN $                  ;FWHM=2.3542.828*sigma
;      fixwidth = fixwidth/width_fac 

;baseline degree 
   poly_deg = 2

;initialise parameters
   baseline = 3                              ;baseline option for fit_gauss
   mw = MEDIAN(wave)
   nwave = wave - mw                          ;median subtracted wl   
;   IF fixwave NE 0.0 THEN $
;     fixwave = fixwave - mw
   factor = 1e22
   chisqr = 0.0                               ;fit chisqr
   coeff = dblarr(4)                          ;normalised baseline coeffs
   flux = flux*factor                         ;normalise flux
   stdev = stdev*factor                       ;normalise stdev
   mf = MEDIAN(flux)                          ;median flux
   nflux = flux - mf                          ;median subtracted fluxes

;   IF STRPOS(info.pattern1, 'gauss') GE 0 THEN $
;     fit_id = "Single Gaussian" $               ; for reporting
;   ELSE IF STRPOS(info.pattern1, 'loren') GE 0 THEN $
;     fit_id = "Single Lorentzian"               ; for reporting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Do Line Fit -  Baseline already computed (and may be removed)     
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   IF info.fittype EQ "sline" THEN BEGIN      ; baseline and fit seperate
;     fitflux0 = wave*0.                       ; baseline, if removed already
;
;     coeff(0:3) = info.basecoef(0:3)*factor   ; stored baseline coeffs
;
;;;;;;subtract baseline, if selected and not done yet
;     IF info.basecoef(4) eq 1 THEN BEGIN
;	  waved = DOUBLE(wave)             
; 	  fitflux0 = poly(waved,coeff(0:poly_deg))
;          flux = flux - fitflux0
;     ENDIF 
;     mf = 0.
;     result = fit_1line(nwave,  flux,  $      ;selected wave and flux arrays
;                        func,  $              ;function, gauss/lorentzian
;                        a, $
;			nfree, sigmaa, chisqr, $  ;a=output Fit parameters 
;                        fixhgt=fixhgt, $      ;sigmaa=errors in awidth]
;                        fixwidth=fixwidth, $  ;chisqr = Fit chisqr 
;                        fixwave=fixwave )
;
;     IF result(0) EQ -1 THEN return, -1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Baseline + Line Fit Togather --- Composite Fit
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;   ENDIF ELSE BEGIN                       ; basline + line fit togather
;     fit_id = "Baseline + " + fit_id      
;     baseline = poly_deg + 1
;     info.basepoints = n_elements(wave)   ;data points for baseline fit
;     if info.fittype eq 'bline' then begin
;     result = fit_1line(nwave, nflux, $   ;selected wave and flux arrays
;                        func, a,      $
;			nfree, sigmaa, chisqr, $  ;a=output Fit parameters 
;			baseline=baseline, $  ; baseline degree + 1
;                        fixhgt=fixhgt, $      ;sigmaaa=errors in a
;                        fixwidth=fixwidth, $  ;chisqr = Fit chisqr
;                        fixwave=fixwave )
;  endif else begin
;     
     result = fit_1line(nwave, nflux, 'linegauss', a, nfree, sigmaa, chisqr, 0, 0, 0, baseline, 1)

;  endelse
;     IF result(0) EQ -1 THEN return, -1


     cin  = coeff
     na = n_elements(a) - 3
     aindx = na - 1
     cin = fltarr(4)
     cin(0: aindx) = a(3:aindx+3) 
     coeff(0) = cin(0)-cin(1)*mw+cin(2)*mw^2-cin(3)*mw^3 + mf
     coeff(1) = cin(1)-2.*cin(2)*mw+3.*cin(3)*mw^2
     coeff(2) = cin(2)-3.*cin(3)*mw
     coeff(3) = cin(3)
     a(3:aindx+3) = coeff(0:aindx)
     
     ;info.basecoef = [coeff/factor, 1.]
   ;ENDELSE                                  ; End Line Fitting
   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;End Line Fitting- process and display fitting params
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

   a(1) = a(1) + mw
   stop
;;   if !sm_debug then begin ; DBL 7/18/2006
;;     print,"single_line : sigmaa width center = ",sigmaa,fixwidth,fixwave ; DBL 7/18/2006
;;     print,"single_line : a = ",a ; DBL 7/18/2006
;;   endif
;
;;first recompute chi^2 using real stdev
;; chi2 computation on points where:
;; i) stdev NE 0
;; ii) stdev/flux ge 1e-2
;; iii) number of points gt 10
;
;   q0 = where(stdev GT 0. AND  $
;	      abs(stdev/flux) GE 1.e-2, n0)
;
; if !sm_debug then print,"single_line : chisqr = ",chisqr
; bad_stdev = 0
; degfree = n0 - nfree
; xd=findgen(1000) 
; xd=(xd*(max(wave)-min(wave))/1000.)+min(wave)
;
; case func of 
; 'linegauss': linegauss, xd, a, yfit
; 'lorentzian': lorentzian, xd, a, yfit
; endcase
;
; IF n0 GT 0 THEN $
;   yq0 = interpol(yfit,xd,wave(q0))
; IF n0 GT 10 THEN BEGIN
;  chisqr=TOTAL(((flux(q0) - yq0)^2.) / $
;	 (stdev(q0)^2.))
;  chisqr = chisqr/degfree
; ENDIF ELSE IF n0 GT nfree THEN BEGIN
;  bad_stdev = 1 
;  chisqr=TOTAL((flux(q0) - yq0)^2.) 
;  chisqr = chisqr/degfree
; ENDIF ELSE chisqr = 0.0
;
;
;; recompute parameters for Report Purpose, identify and plot db lines 
;
;   text = ""
;   status = process_line(info, line_range, $
;			 wave, flux, a, sigmaa, $
;		         chisqr, func, width_fac,  fit_struc,  $
;			 line_struc, $
;			 text, fit_id, $
;			 fixhgt=fixhgt, $
;			 fixwave=fixwave,  $
;			 fixwidth=fixwidth, $
;			 bad_stdev=bad_stdev)
;   IF status EQ -1 THEN return, -1
;;stop
;   show_text, text, title='Line Fit Results',  $
;	      /linefit, recval=ok
;
;; record it
;
;   IF ok GE 1 THEN BEGIN      
;
;;save line results in the report
;      info.numlines = info.numlines + 1
;      elemtitle = '        Line Fit # ' + $
;	 strtrim(info.numlines, 2)
;      elemsep =  ['        --------------']
;      handle_value, info.output, lines
;      lines = [lines, ' ', elemtitle, elemsep, $
;	       text(0:*), '']
;
;      handle_value, info.output, lines,  $
;		       /set, /no_copy
;
;;save fitted line 
;      handle_value, info.lines, lfits     ;retrieve previous lines, if any
;      lfits = fit_struc
;      handle_value, info.lines, lfits, $
;		    /set, /no_copy
;      handle_value, info.selecid,selecp
;      select_lines, selecp, line_struc    ;identified lines are selected lines
;      handle_value, info.selecid, $
;		    selecp,/set
;      IF info.listid GT 0 THEN BEGIN      ;update "show_linelist" if open
;        active = widget_info(info.listid, $
;                              /valid_id)
;        IF active THEN BEGIN
;          entry = line_struc.entry - 1
;          widget_control,info.listid, $
;                    get_uval=lininfo
;          handle_value, lininfo.selec_handle, selid
;	  selid(entry) = 1
;	  FOR k = 0, n_elements(entry)-1 DO BEGIN
;	    seton = entry(k)
;	    widget_control, lininfo.lid(seton), $    ;set the button "on"
;	 	/set_button
;	  ENDFOR
;          handle_value, lininfo.selec_handle, $
;			selid ,  /set
; 
;         ENDIF
;      ENDIF
;    ENDIF
;
;   IF ok GE 2 THEN BEGIN                  ; remove the fitted line/line+baseline
;      aar_flux = aar.data.flux * factor
;      dwave = DOUBLE(aar.data.wave)
;
;      case func of 
;      'linegauss': linegauss, dwave, a, dflux
;      'lorentzian': lorentzian,  dwave, a, dflux
;      endcase
;
;; ; baseline over whole spectrum
;      basefit = poly(dwave,coeff(0:poly_deg))
;      IF info.fittype  EQ "sline"  $
;	AND info.basecoef(4) eq 1 THEN $
;          aar_flux = aar_flux - basefit
;      IF ok EQ 2 THEN aar_flux = $        ;remove line from AAR flux        
;	 aar_flux - dflux + basefit  $
;      ELSE IF ok EQ 3 THEN aar_flux = $   ;remove baseline & line from AAR flux
;	 aar_flux - dflux
;      aar.data.flux = aar_flux/factor
;      handle_value, info.handle, aar, /set
;
;      plot_all, aar, info.cw2, info.pstyle, $            
;		    textwid=info.msg_txt, $
;                    title='Remainder', $
;                    xtitle=info.xlab, $
;		    ytitle=info.ylab
;
;     ENDIF
;
;return, 0
END
