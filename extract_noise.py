def extract_noise(indir, obj, spire=False, pacs=False, noiselevel=3):
	import numpy as np
	from astropy.io import ascii
	import astropy.constants as const

	# constant setup
	c = const.c.cgs.value

	# define Gaussian
	def gauss(x, height, width, center):
		return height * np.exp(-(x - center)**2/2/width**2)

	if pacs:
		suffix = '_centralSpaxel_PointSourceCorrected_CorrectedYES_trim_flat_spectrum.txt'
		[wl_flat,flux_flat,unc_flat] = np.genfromtxt(indir+obj+suffix,dtype='float',skip_header=1).T
	if spire:
		suffix = '_spire_corrected_flat_spectrum.txt'
		[wl_flat,flux_flat] = np.genfromtxt(indir+obj+suffix,dtype='float',skip_header=1).T

	# spectra in unit of um and Jy

	# read fitting table
	fitting = ascii.read(indir+obj+suffix[0:-17]+'lines.txt')

	# iterate through lines
	flux_lines = np.zeros_like(flux_flat)
	size = 10
	for i in range(0, len(fitting['Line'])):
		if fitting['SNR'][i] < noiselevel:
			continue
		else:
			# factor?
			line_gauss = gauss(wl_flat[(wl_flat > fitting['ObsWL(um)'][i]-size*fitting['FWHM(um)'][i]) & (wl_flat < fitting['ObsWL(um)'][i]+size*fitting['FWHM(um)'][i])], \
				fitting['Str(W/cm2)'][i]/(fitting['FWHM(um)'][i]*1e-4)/(2*np.pi)**0.5 * (fitting['ObsWL(um)'][i]*1e-4)**2/c * 1e7,\
				fitting['FWHM(um)'][i]/2.354,\
				fitting['ObsWL(um)'][i])

			flux_lines[(wl_flat > fitting['ObsWL(um)'][i]-size*fitting['FWHM(um)'][i]) & (wl_flat < fitting['ObsWL(um)'][i]+size*fitting['FWHM(um)'][i])] = line_gauss

	import matplotlib.pyplot as plt
	plt.plot(wl_flat, flux_lines)
	plt.savefig('/Users/yaolun/test/linesum.pdf', dpi=300, format='pdf', bbox_inches='tight')

indir = '/Users/yaolun/bhr71/fitting/BHR71/pacs/advanced_products/'
obj = 'BHR71'
extract_noise(indir, obj, pacs=True)