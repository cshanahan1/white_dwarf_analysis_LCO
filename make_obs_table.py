import argparse
from astropy.io import fits
from astropy.table import Table
import glob
import numpy as np
import os 

def parse_args():
	"""Parse the command line arguments.

	Returns
	-------
	args : obj
		An agparse object containing all of the added arguments
	"""

	parser = argparse.ArgumentParser(
		description="For all files in a specified input directory, write CSV file with file names and observational parameters.")
		
	parser.add_argument(
		'-input_dir',
		required = True,
		help = 'Path to directory that contains files to sort.')
		
	parser.add_argument('-output_file',
						required=False, 
						default='obs_info.csv',
	help='Name out output file, which will be written out in the input directory.')
	args = parser.parse_args()

	return args

def get_hdr0_items(ifile,hdr0_items):

	hdu = fits.open(ifile)
	hdr0 =	hdu[0].header
	hdu.close
	
	hdr0_vals = []
	
	for item in hdr0_items:
		hdr0_vals.append(hdr0[item])
	
	return hdr0_vals
		
def get_table_items(ifile,table_items):

	hdu = fits.open(ifile)
	tbl =  Table(hdu[1].data)
	hdu.close
	
	table_item_vals = []
	
	if 'MED-FWHM' in table_items:
		fwhm = tbl['FWHM']
		table_item_vals.append(np.median(fwhm))
	
	return table_item_vals

						
def main_make_obs_table(input_dir,output_file, hdr0_items, table_items):

	ifiles = glob.glob(input_dir+'/*[0-9].fits')
	
	
	#write header of output file
	with open(output_file,'w') as f:
		print 'Writing ' + output_file
		f.write('#ifile')
		for x in hdr0_items:
			f.write(','+str(x))
		for x in table_items:
			f.write(','+str(x))
		f.write('\n')
	
	if len(ifiles) > 0:
	
		for ifile in ifiles:
			print ifile
		
			hdr0_vals = get_hdr0_items(ifile,hdr0_items)
			table_item_vals = get_table_items(ifile,table_items)
			
			with open(output_file,'a') as f:
				f.write(os.path.basename(ifile))
				for x in hdr0_vals:
					f.write(','+str(x))
				for x in table_item_vals:
					f.write(','+str(x))
				f.write('\n')
	
	else:
	
		print 'No files in input directory.'
	

if __name__ == '__main__':
	
	hdr0_items = ['MJD-OBS','FILTER','RDNOISE','EXPTIME','PROPID','SITEID']
	table_items = ['MED-FWHM']

	#args = parse_args()
	
	#input_dirs = glob.glob('/Users/cshanahan/Desktop/WD_project/lco_data/*/*2018*')
	input_dirs = ['/Users/cshanahan/Desktop/WD_project/lco_data/done_A020.503022/2018']
# 	
# 	
# 	#remove trailing slashes for consistency
# 	input_dir = args.input_dir
# 	if input_dir[-1]=='/':
# 		input_dir = input_dir[:-1]
# 	output_file = args.output_file
# 	if output_file[-1]=='/':
# 		output_file = output_file[:-1]

	for input_dir in input_dirs:
		
		output_file = input_dir + '/obs_info.csv'
	
		main_make_obs_table(input_dir,output_file, hdr0_items, table_items)