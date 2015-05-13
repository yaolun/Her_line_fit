pro archival_extract
; IDL script for extracting archival data
objlist = ['AS205','B1-a','B1-c','B335','BHR71','Elias29','FUOri','GSS30-IRS1','HD100546',$
		   'HD104237','HD135344','HD141569','HD142527','HD142666','HD169142','HD97048','HD98922','IRAM04191',$
		   'IRAS03245','IRAS03301','IRAS12496','IRS44','IRS63','L1014','L1157','L1448-MM','L1455-IRS3','L1489','L1527',$
		   'L1551-IRS5','RCrA-IRS5A','RCrA-IRS7B','RCrA-IRS7C','SCra','Serpens-SMM3','Serpens-SMM4','TMC1','TMC1A',$
		   'TMR1','V1331Cyg','V1515Cyg','V1735Cyg','VLA1623','WL12']
OBSID = [['1342215737', '1342215738'], ['1342216182', '1342216183'], ['1342216213', '1342216214'], ['1342208889', '1342208888'], ['1342212230', '1342212231'],$
		 ['1342228519', '1342228520'], ['1342250907', '1342250908'], ['1342215678', '1342215679'], ['1342188037', '1342188038'],$
		 ['1342207819', '1342207820'], ['1342213921', '1342213922'], ['1342213913','na'], ['1342216174', '1342216175'], ['1342213916','na'],$
		 ['1342206987', '1342206988'], ['1342199412', '1342199413'], ['1342210385','na'], ['1342216654', '1342216655'], ['1342214677', '1342214676'],$
		 ['1342215668', '1342216181'], ['1342188039', '1342188040'], ['1342228474', '1342228475'], ['1342228472', '1342228473'],$
		 ['1342208911', '1342208912'], ['1342208908', '1342208909'], ['1342213683', '1342214675'], ['1342204122', '1342204123'],$
		 ['1342216215', '1342216216'], ['1342192981', '1342192982'], ['1342192805', '1342229711'], ['1342207805', '1342207806'],$
		 ['1342207807', '1342207808'], ['1342206989', '1342206990'], ['1342207809', '1342207810'], ['1342193216', '1342193214'],$
		 ['1342193217', '1342193215'], ['1342225803', '1342225804'], ['1342192987', '1342192988'], ['1342192985', '1342192986'],$
		 ['1342233445', '1342233446'], ['1342235690', '1342235691'], ['1342235848', '1342235849'], ['1342213917', '1342213918'],$
		 ['1342228187', '1342228188']]
datadir = '/scratch/.hcss/lstore/'

for i = 0, n_elements(objlist)-1 do begin
	obj = objlist[i]
	print, obj
	OBSID_dum = OBSID[*,i]
	t = 0
	if OBSID_dum[1] ne 'na' then begin
		if file_test(datadir+OBSID_dum[0]+'/herschel.pacs.signal.PacsRebinnedCube/hpacs'+OBSID_dum[0]+'_20hps3drbs_00.fits') eq 1 then t = t+1
		if file_test(datadir+OBSID_dum[0]+'/herschel.pacs.signal.PacsRebinnedCube/hpacs'+OBSID_dum[0]+'_20hps3drbs.fits') eq 1 then t = t+2
		if file_test(datadir+OBSID_dum[1]+'/herschel.pacs.signal.PacsRebinnedCube/hpacs'+OBSID_dum[1]+'_20hps3drbs_00.fits') eq 1 then t = t+4
		if file_test(datadir+OBSID_dum[1]+'/herschel.pacs.signal.PacsRebinnedCube/hpacs'+OBSID_dum[1]+'_20hps3drbs.fits') eq 1 then t = t+8

		if t eq 5 then begin
			filename = [datadir+OBSID_dum[0]+'/herschel.pacs.signal.PacsRebinnedCube/hpacs'+OBSID_dum[0]+'_20hps3drbs_00.fits',$
						datadir+OBSID_dum[0]+'/herschel.pacs.signal.PacsRebinnedCube/hpacs'+OBSID_dum[0]+'_20hps3drrs_00.fits',$
						datadir+OBSID_dum[1]+'/herschel.pacs.signal.PacsRebinnedCube/hpacs'+OBSID_dum[1]+'_20hps3drbs_00.fits',$
						datadir+OBSID_dum[1]+'/herschel.pacs.signal.PacsRebinnedCube/hpacs'+OBSID_dum[1]+'_20hps3drrs_00.fits']
		endif
		if t eq 10 then begin
			filename = [datadir+OBSID_dum[0]+'/herschel.pacs.signal.PacsRebinnedCube/hpacs'+OBSID_dum[0]+'_20hps3drbs.fits',$
						datadir+OBSID_dum[0]+'/herschel.pacs.signal.PacsRebinnedCube/hpacs'+OBSID_dum[0]+'_20hps3drrs.fits',$
						datadir+OBSID_dum[1]+'/herschel.pacs.signal.PacsRebinnedCube/hpacs'+OBSID_dum[1]+'_20hps3drbs.fits',$
						datadir+OBSID_dum[1]+'/herschel.pacs.signal.PacsRebinnedCube/hpacs'+OBSID_dum[1]+'_20hps3drrs.fits']
		endif
		if t eq 9 then begin
			filename = [datadir+OBSID_dum[0]+'/herschel.pacs.signal.PacsRebinnedCube/hpacs'+OBSID_dum[0]+'_20hps3drbs_00.fits',$
						datadir+OBSID_dum[0]+'/herschel.pacs.signal.PacsRebinnedCube/hpacs'+OBSID_dum[0]+'_20hps3drrs_00.fits',$
						datadir+OBSID_dum[1]+'/herschel.pacs.signal.PacsRebinnedCube/hpacs'+OBSID_dum[1]+'_20hps3drbs.fits',$
						datadir+OBSID_dum[1]+'/herschel.pacs.signal.PacsRebinnedCube/hpacs'+OBSID_dum[1]+'_20hps3drrs.fits']
		endif
		if t eq 6 then begin
			filename = [datadir+OBSID_dum[0]+'/herschel.pacs.signal.PacsRebinnedCube/hpacs'+OBSID_dum[0]+'_20hps3drbs.fits',$
						datadir+OBSID_dum[0]+'/herschel.pacs.signal.PacsRebinnedCube/hpacs'+OBSID_dum[0]+'_20hps3drrs.fits',$
						datadir+OBSID_dum[1]+'/herschel.pacs.signal.PacsRebinnedCube/hpacs'+OBSID_dum[1]+'_20hps3drbs_00.fits',$
						datadir+OBSID_dum[1]+'/herschel.pacs.signal.PacsRebinnedCube/hpacs'+OBSID_dum[1]+'_20hps3drrs_00.fits']
		endif
		if t eq 0 then begin
			print, obj+': FITS is not found!'
			continue
		endif
	endif else begin
		if file_test(datadir+OBSID_dum[0]+'/herschel.pacs.signal.PacsRebinnedCube/hpacs'+OBSID_dum[0]+'_20hps3drbs_00.fits') eq 1 then t = t+1
		if file_test(datadir+OBSID_dum[0]+'/herschel.pacs.signal.PacsRebinnedCube/hpacs'+OBSID_dum[0]+'_20hps3drbs.fits') eq 1 then t = t+2

		if t eq 1 then begin
			filename = [datadir+OBSID_dum[0]+'/herschel.pacs.signal.PacsRebinnedCube/hpacs'+OBSID_dum[0]+'_20hps3drbs_00.fits',$
						datadir+OBSID_dum[0]+'/herschel.pacs.signal.PacsRebinnedCube/hpacs'+OBSID_dum[0]+'_20hps3drrs_00.fits']
		endif
		if t eq 2 then begin
			filename = [datadir+OBSID_dum[0]+'/herschel.pacs.signal.PacsRebinnedCube/hpacs'+OBSID_dum[0]+'_20hps3drbs.fits',$
						datadir+OBSID_dum[0]+'/herschel.pacs.signal.PacsRebinnedCube/hpacs'+OBSID_dum[0]+'_20hps3drrs.fits']
		endif
		if t eq 0 then begin
			print, obj+': FITS is not found!'
			continue
		endif
	endelse

	get_pacs, outdir='~/test/herschel_archival/'+obj+'/',objname=obj, filename=filename, suffix='archival'
	summed_three, '~/test/herschel_archival/'+obj+'/cube/', '~/test/herschel_archival/'+obj+'/', 'archival', obj, wl, flux
	spec_continuum_smooth,wl,flux,continuum, continuum_error,w1 = min(wl), w2 = max(wl), sbin=10,upper=0.9, lower=0.9

	; print out the smoothed continuum
	openw, sed, '~/test/herschel_archival/'+obj+'/'+obj+'summed_3x3_smooth.txt', /get_lun
	printf, sed, format='(3(a16,2x))','Wave (um)','Flux (Jy)'
	for k =0, n_elements(wl)-1 do printf, sed, format='(2(g16.6,2x))', wl[k],continuum[k]
	free_lun, sed
	close, sed

    set_plot, 'ps'
	!p.font = 0
	device, filename = '~/test/herschel_archival/'+obj+'/'+obj+'_summed_3x3.eps', /helvetica, /portrait, /encapsulated, isolatin = 1, font_size = 14, decomposed = 0, /color
  	loadct ,13,/silent
	!p.thick = 3 & !x.thick = 3 & !y.thick = 3
	plot, wl, flux, xtitle = '!3Wavelength (!9m!3m)', ytitle = '!3Flux Density (Jy)', /nodata, position=[0.15,0.1,0.95,0.95]
	plot, wl, flux, thick=2, color=0
	plot, wl, continuum, thick=2, color=60
	al_legend, ['summed 3x3', 'smoothed cont.'], textcolors=[0,60], /right
	device, /close_file, decomposed = 1
	!p.multi = 0
endfor

end