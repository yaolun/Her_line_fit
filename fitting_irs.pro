filename = '/Users/yaolun/data/hh168_texes/ggd37-yaolun/aor_17856768_expid_62_0_file1_pixel1_TSA.txt'
readcol, filename, comment='#', wl, flux, err, format='F,F,F'
base_para = [0,0,0]
line = [25.97, 25.92, 26.02]
base_range = [25.67, 25.92, 26.02, 26.37]

pixelname = 'pixel1'
linename = 'FeII26'

ind = where(wl gt base_range[0] and wl lt base_range[3])
ind_line = where(wl gt base_range[1] and wl lt base_range[2])
ind_base = where((wl gt base_range[0] and wl lt base_range[1]) or (wl gt base_range[2] and wl lt base_range[3]))
plot_base = [[wl[ind_line]], [flux[ind_line]]]

; baseline fitting
fit_line, 'pixel1','FeII26', wl[ind_base], flux[ind_base], status, errmsg, cen_wl, sig_cen_wl, str, sig_str, fwhm, sig_fwhm, base_para, snr, line, noise, /baseline, /convert, outdir='~/test/', $
          noiselevel=3, plot_base=plot_base

print, base_para
base = base_para[0]*wl[ind]^2+base_para[1]*wl[ind]+base_para[2]
plot_base = [[wl[ind_base]], [flux[ind_base]]]

fit_line, 'pixel1','FeII26', wl[ind], flux[ind]-base, status, errmsg, cen_wl, sig_cen_wl, str, sig_str, fwhm, sig_fwhm, base_para, snr, line, noise, /single_gauss, /convert, outdir='~/test/', noiselevel=3,$
          base_range=base_range, plot_base=plot_base
          
; generic extraction routine
indir = '/Users/yaolun/data/hh168_texes/ggd37-yaolun/'
filename = 'aor_17856768_expid_62_0_file1_pixel1_TSA'
outdir = '~/test/'
extract_line, indir=indir, filename=filename, outdir=outdir, plotdir=outdir, noiselevel=3, ra=0, dec=0,$
  localbaseline=10, global_noise=0, fixed_width=0, continuum=1, object='GGD37', flat=1,$
  plot_subtraction=0, no_plot=0, double_gauss=0
