# This script is for reading in the fitting results from my fitting routine and exporting them into the format that POMAC can read.
import numpy as np
from astropy.io import ascii
import os
from astropy import coordinates as coord
from astropy import units as u
home = os.path.expanduser('~')
def read_fitting(filepath,noiselevel,obj=False,cube=False):
	import numpy as np
	from astropy.io import ascii
	import os
	home = os.path.expanduser('~')
	data = ascii.read(home+filepath)
	# data = np.genfromtxt(home+filepath, skip_header=1, dtype=str)
	header = data.colnames
	data = data[np.isnan(data['SNR'])!=True]        # Temperory procedure to exclude the missing segment in the spectrum resulting in the NaN in SNR
	data = data[(data['SNR']>noiselevel)]# & (data['Validity']!=0) & (data['Str(W/cm2)']!=0)]
	return data, header

def her2pomac(obj, outdir, linelist):
	import numpy as np
	from astropy.io import ascii
	import os
	from astropy import coordinates as coord
	from astropy import units as u
	home = os.path.expanduser('~')

	pix = np.arange(1,26)
	filename = []
	for i in range(0,len(pix)):
		filename = filename+[outdir+obj+'/pacs/advanced_products/cube/'+obj+'_pacs_pixel'+pix[i]+'_os8_sf7_lines.txt']
	if not os.path.exists(home+outdir+'pomac/'+obj):
		os.makedirs(home+outdir+'pomac/'+obj)
	# source pointing coordinates part
	[data, header] = read_fitting(outdir+obj+'/pacs/advanced_products/'+obj+'_centralSpaxel_PointSourceCorrected_CorrectedYES_trim_lines.txt', 0)
	ra = data['RA(deg)'][0]
	dec = data['Dec(deg)'][0]
	# unit conversion
	c = coord.ICRS(ra=ra, dec=dec, unit=(u.degree, u.degree))
	# Print the source pointing coordinates
	posdata = open(home+outdir+'pomac/posdata.dat','w')
	posdata.write('%s \t %+02dh%02dm%03.1fs \t %+03dd%02dm%03.1fs \n' % (obj, c.ra.hms[0],c.ra.hms[1],c.ra.hms[2],c.dec.dms[0],abs(c.dec.dms[1]),abs(c.dec.dms[2])))
	posdata.close()

	# The rest parts
	inten = open(home+outdir+'pomac/'+obj+'/intendata.dat','w')
	error = open(home+outdir+'pomac/'+obj+'/errordata.dat','w')
	pacscoord = open(home+outdir+'pomac/'+obj+'/pacscoord.dat','w')
	for line in linelist:
		inten.write('%s \t' % line)
		error.write('%s \t' % line)
		pacscoord.write('%s \t' % line)
		for foo in filename:
			[data, header] = read_fitting(foo, 0)
			inten_dum = data[data['Line'] == line]['Str(W/cm2)']
			error_dum = data[data['Line'] == line]['Sig_str(W/cm2)']
			ra_dum = data[data['Line'] == line]['RA(deg)']
			if data[data['Line'] == line]['Validity'] == 0:
				inten_dum = 0.0
				error_dum = 0.0
			inten.write('%16.10e \t' % inten_dum)
			error.write('%16.10e \t' % error_dum)
			pacscoord.write('%16.10f \t' % ra_dum)
		# Print Dec
		for foo in filename:
			[data, header] = read_fitting(foo, 0)
			dec_dum = data[data['Line'] == line]['Dec(deg)']
			pacscoord.write('%16.10f \t' % dec_dum)
	inten.close()
	error.close()
	pacscoord.close()


line_name_oh2o = ['o-H2O8_27-7_16','o-H2O10_29-10_110','o-H2O9_09-8_18','o-H2O7_52-8_27','o-H2O4_32-3_21','o-H2O5_41-6_16','o-H2O9_18-9_09','o-H2O8_18-7_07','o-H2O6_61-6_52','o-H2O7_61-7_52',\
	              'o-H2O6_25-5_14','o-H2O7_16-6_25','o-H2O3_30-2_21','o-H2O3_30-3_03','o-H2O8_27-8_18','o-H2O7_07-6_16','o-H2O7_25-6_34','o-H2O3_21-2_12','o-H2O8_54-8_45','o-H2O6_52-6_43',\
	              'o-H2O5_50-5_41','o-H2O7_52-7_43','o-H2O4_23-3_12','o-H2O9_27-9_18','o-H2O6_16-5_05','o-H2O8_36-8_27','o-H2O7_16-7_07','o-H2O8_45-8_36','o-H2O6_43-6_34','o-H2O6_25-6_16',\
	              'o-H2O4_41-4_32','o-H2O6_34-6_25','o-H2O2_21-1_10','o-H2O7_43-7_34','o-H2O4_41-5_14','o-H2O4_14-3_03','o-H2O9_27-10_110','o-H2O8_36-9_09','o-H2O7_34-6_43','o-H2O4_32-4_23',\
	              'o-H2O9_36-9_27','o-H2O7_25-7_16','o-H2O9_45-9_36','o-H2O4_23-4_14','o-H2O8_36-7_43','o-H2O5_14-5_05','o-H2O3_30-3_21','o-H2O5_23-4_32','o-H2O8_45-7_52','o-H2O6_34-7_07',\
	              'o-H2O5_32-5_23','o-H2O7_34-7_25','o-H2O3_03-2_12','o-H2O4_32-5_05','o-H2O2_12-1_01','o-H2O2_21-2_12','o-H2O8_54-9_27']
	              ;'o-H2O5_41-5_32','o-H2O5_05-4_14','o-H2O5_14-4_23'
line_name_ph2o = ['p-H2O6_51-7_26','p-H2O7_71-7_62','p-H2O10_19-10_010','p-H2O4_31-3_22','p-H2O9_19-8_08','p-H2O4_22-3_13','p-H2O8_17-7_26','p-H2O6_42-7_17','p-H2O7_26-6_15','p-H2O8_26-7_35',\
				  'p-H2O7_62-8_35','p-H2O4_31-4_04','p-H2O4_40-5_15','p-H2O9_28-9_19','p-H2O8_08-7_17','p-H2O7_62-7_53','p-H2O3_31-2_20','p-H2O5_24-4_13','p-H2O7_17-6_06','p-H2O5_51-6_24',\
				  'p-H2O8_17-8_08','p-H2O9_37-9_28','p-H2O5_51-5_42','p-H2O7_53-7_44','p-H2O6_51-6_42','p-H2O6_15-5_24','p-H2O9_46-9_37','p-H2O8_53-8_44','p-H2O7_26-7_17','p-H2O8_35-7_44',\
				  'p-H2O6_06-5_15','p-H2O3_22-2_11','p-H2O7_44-7_35','p-H2O5_42-5_33','p-H2O6_42-6_33','p-H2O6_15-6_06','p-H2O5_24-5_15','p-H2O5_33-5_24','p-H2O9_46-8_53','p-H2O9_37-8_44',\
				  'p-H2O8_44-8_35','p-H2O4_04-3_13','p-H2O3_31-3_22','p-H2O7_53-8_26','p-H2O7_35-8_08','p-H2O3_13-2_02','p-H2O4_13-3_22','p-H2O4_31-4_22','p-H2O8_35-8_26',\
				  'p-H2O5_42-6_15','p-H2O3_22-3_13','p-H2O3_31-4_04','p-H2O8_26-9_19','p-H2O6_24-6_15','p-H2O7_35-6_42','p-H2O6_33-6_24','p-H2O5_33-6_06','p-H2O4_13-4_04']
				  ;,'p-H2O5_15-4_04','p-H2O4_40-4_31','p-H2O9_37-10_010','p-H2O8_26-8_17','p-H2O2_20-1_11','p-H2O6_24-5_33',\
line_name_co = ['CO40-39','CO39-38','CO38-37','CO37-36','CO36-35','CO35-34','CO34-33','CO33-32','CO32-31','CO31-30',\
				'CO30-29','CO29-28','CO28-27','CO25-24','CO24-23','CO23-22','CO22-21','CO21-20','CO20-19',\
				'CO19-18','CO18-17','CO17-16','CO16-15','CO15-14','CO14-13','CO41-40','CO42-41','CO43-42','CO44-43',\
				'CO45-44','CO46-45','CO47-46','CO48-47']
line_name_oh = ['OH19-14','OH18-15','OH13-9','OH12-8','OH14-10','OH15-11','OH5-1','OH4-0','OH9-3','OH8-2',\
			    'OH10-8','OH11-9','OH3-1','OH2-0','OH14-12','OH15-13','OH19-16','OH7-5','OH6-4']
line_name_other = ['OI3P1-3P2','NII_122','OI3P0-3P1','CII2P3_2-2P1_2']
linelist = line_name_oh2o+line_name_ph2o+line_name_co+line_name_oh+line_name_other

cdf = ['ABAur','AS205','B1-a','B1-c','B335','BHR71','Ced110-IRS4','DGTau','EC82','Elias29','FUOri','GSS30-IRS1','HD100453','HD100546','HD104237','HD135344B','HD139614',\
   'HD141569','HD142527','HD142666','HD144432','HD144668','HD150193','HD163296','HD169142','HD179218','HD203024','HD245906','HD35187','HD36112','HD38120','HD50138',\
   'HD97048','HD98922','HH46','HTLup','IRAM04191','IRAS03245','IRAS03301','IRAS12496','IRAS15398','IRS46','IRS48','IRS63','L1014','L1157','L1448-MM','L1455-IRS3',\
   'L1489','L1527','L1551-IRS5','L483','L723-MM','RCrA-IRS5A','RCrA-IRS7B','RCrA-IRS7C','RNO90','RNO91','RULup','RYLup','SCra','SR21',\
   'Serpens-SMM3','Serpens-SMM4','TMC1','TMC1A','TMR1','V1057Cyg','V1331Cyg','V1515Cyg','V1735Cyg','VLA1623','WL12']
outdir = '/FWD_archive/FWD_archive/'

for obj in cdf:
	her2pomac(obj, outdir, linelist)


