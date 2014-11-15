pro get_spire, SSW, SLW, wl, flux
readcol, '~/bhr71/data/pixel_spectrum/extended_correction/'+SSW+'.txt', wl0, flux0
readcol, '~/bhr71/data/pixel_spectrum/extended_correction/'+SLW+'.txt', wl1, flux1
wl0 = reverse(wl0) & flux0 = reverse(flux0)
wl1 = reverse(wl1) & flux1 = reverse(flux1)
i0 = n_elements(wl0[0:where(wl0 eq 312.5)]) & i1 = n_elements(wl1[where(wl1 eq 312.5):*])
wl = dblarr(i1 + i0)
wl[0:i0-1] = wl0[0:where(wl0 eq 312.5)] & wl[i0:i0+i1-1] = wl1[where(wl1 eq 312.5):*]
flux = dblarr(i1 + i0)
f = flux1[where(wl1 eq 310)]/flux0[where(wl0 eq 310)]
print, f
flux[0:i0-1] = flux0[0:where(wl0 eq 312.5)] & flux[i0:i0+i1-1] = flux1[where(wl1 eq 312.5):*]*total(f)
;plot, wl, flux, psym = 10
end
