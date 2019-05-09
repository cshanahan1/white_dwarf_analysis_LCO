from astropy.io import ascii
import glob
import os

def read_obs_info_table(obs_info_table_path):
	"""Reads in obs_info.csv, located in same directy as input directory, and 
		returns the row corresponding to the input file"""

	t = ascii.read(obs_info_table_path, format = 'csv')
	
	return t[t['#ifile'] == os.path.basename(ifile)]
	
def calc_fwhm_fitt_ps(file_obs_info):
	
	fwhm = file_obs_info['MED-FWHM'][0]
	print fwhm
	fitt = fwhm
	ps = 5. * fwhm
	
	return (fwhm,fitt,ps)
	 
def write_opt_file(opt_filename,opt_params):

	with open(opt_filename,'w') as f:
		for key in opt_params:
			f.write('{0} = {1}\n'.format(key,str(opt_params[key])))

def main_make_opt_file(ifile):
	
	opt_params = {'re':9.2589,
				  'ga':1.0,
				  'hi':100000,
				  'ex':9,
				  'wa':-2,
				  'varia':1,
				  'analytic':3,
				  'low good datum':50,
				  'thre':10}
	opt_filename = ifile.replace('.fits','.opt')
	
	#looks for obs_info.csvfile in same directory as input file
	obs_info_table_path = ifile.replace(os.path.basename(ifile),'obs_info.csv')
	file_obs_info = read_obs_info_table(obs_info_table_path)
	print file_obs_info
	
	fwhm,fitt,ps = calc_fwhm_fitt_ps(file_obs_info)
	
	opt_params['fwhm'] = fwhm
	opt_params['fitt'] = fitt
	opt_params['ps'] = ps
	
	opt_params['re'] = file_obs_info['RDNOISE'][0]
	
	write_opt_file(opt_filename,opt_params)
	print 'Wrote {}'.format(opt_filename)
	
if __name__ == '__main__':
	
	ifiles = glob.glob('/Users/cshanahan/Desktop/WD_project/lco_data/done_A020.503022/2018/*[0-9].fits')
	for ifile in ifiles:
		main_make_opt_file(ifile)
				  
	
