pro get_radec_spire, filename=filename, pix, ra, dec, slw=slw, ssw=ssw, central=central
if not keyword_set(central) then begin
	if keyword_set(slw) then begin
		pix_name = strarr(19)
		coord = dblarr(2,19)
		plot_coord = dblarr(2,19)
		hdr = headfits(filename, exten=11,/silent)
		cen_dec = sxpar(hdr, 'DEC') & cen_ra = sxpar(hdr, 'RA')
		for i = 2, 20 do begin
			hdr = headfits(filename, exten=i,/silent)
			dec = sxpar(hdr, 'DEC') & ra = sxpar(hdr, 'RA')
			pix = sxpar(hdr,'EXTNAME')
			pix_name[i-2] = strcompress(pix,/remove_all)
			coord[*,i-2] = [ra, dec]
			plot_coord[*,i-2] = [ra-cen_ra, dec-cen_dec]
		endfor
		;print, cen_ra, cen_dec
	endif

	if keyword_set(ssw) then begin
		pix_name = strarr(35)
		coord = dblarr(2,35)
		plot_coord = dblarr(2,35)
		hdr = headfits(filename, exten=39,/silent)
		cen_dec = sxpar(hdr, 'DEC') & cen_ra = sxpar(hdr, 'RA')
		for i = 21, 55 do begin
			hdr = headfits(filename, exten=i,/silent)
			dec = sxpar(hdr, 'DEC') & ra = sxpar(hdr, 'RA')
			pix = sxpar(hdr,'EXTNAME')
			pix_name[i-21] = strcompress(pix,/remove_all)
			coord[*,i-21] = [ra, dec]
			plot_coord[*,i-21] = [ra-cen_ra, dec-cen_dec]
		endfor
	endif
	pix = pix_name
	ra = coord[0,*]
	dec = coord[1,*]
endif else begin
	hdr = headfits(filename, exten=5,/silent)
	dec = [sxpar(hdr, 'DEC')] & ra = [sxpar(hdr, 'RA')]
	pix = ['SLWC3']
endelse

end
