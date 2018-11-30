"""Wrapper around DAOphot, allframe, daomatch, daomaster, allframe, and daomaster again 

Starts with data downloaded from LCO observatory website, placed in a directory, and
does all processing steps to produce photometry catalogs. 

Step 1: Rename files
Step 2: Sort into directories based on target names
Step 3: Make a preliminary observation table with metadata / info from SExtractor table
Step 4: Move all files with large FWHM to a subdirectory named 'failed' within their 
		parent directoy
Step 5: Make a new observation table for 'good' files in each object subdirectory
Step 6: Create .opt files for DAOphot 
Step 7: Run daophot (call to shell script wrapper around DAOphot executable)
Step 8: Move all files that failed DAOphot (didn't produce a .psf file) to 'failed' 
		subdirectory
Step 9: Remake observation table again for 'good' files in each object subdirectory

"""

from astropy.io import ascii, fits
from astropy.table import Table
import glob
import numpy as np
from organize_new_data import organize_new_data
import os
import shutil


#global variables
new_data_dir = '/Users/cshanahan/Desktop/WD_project/lco_data/movee/',
data_dir = '/Users/cshanahan/Desktop/WD_project/LCO_DATA_NEW/'
code_dir = '/Users/cshanahan/Desktop/WD_project/scripts/'

class LCOFile:

	def __init__(self,full_path):

		self.full_path = full_path
		self.basename = os.path.basename(full_path)

		#header info
		hdr0 = fits.getheader(full_path, 0)
		self.propid = hdr0['propid']
		self.filt = hdr0['filter']
		self.object = hdr0['object'] 
		self.exptime = hdr0['exptime']
		self.readnoise = hdr0['rdnoise']
		self.mjd_obs = hdr0['mjd-obs']
		self.siteid = hdr0['siteid']
		
		#SExtractor table info
		tbl =  Table(fits.getdata(full_path,1))
		#print(tbl)
		fwhm = tbl['FWHM']
		self.med_fwhm = np.median(fwhm)
		
		#name alias
		self.object_alias = self.object #if no other name, set to header name 
		
		name_alises = {'SDSSJ102430.93-003207.0': 'SDSSJ0102430',
				   	   'SDSSJ111059.42-170954.2': 'SDSSJ0111059',
				       'SDSSJ111127.30+395628.0': 'SDSSJ0111127',
				       'SDSSJ120650.504+020143.810': 'SDSSJ0120650',
				       'SDSSJ121405.11+453818.5': 'SDSSJ0121405',
				       'SDSSJ130234.43+101238.9': 'SDSSJ0130234',
				       'SDSSJ131445.050-031415.588': 'SDSSJ0131445',
				       'WD0554-165' :'SDSSJ055701.288-163512.115',
				       'SDSSJ022817.16-082716.4' : 'SDSSJ022817',
				       'SDSSJ024854.96+334548.3' : 'SDSSJ024854',
				       'SDSSJ041053.632-063027.580' : 'SDSSJ041053',
				       'SDSSJ072752.76+321416.1' : 'SDSSJ072752',
				       'SDSSJ081508.78+073145.7' : 'SDSSJ081508',}

				   	
		for key in name_alises:
			if (self.object == key) or (self.object == name_alises[key]):
				self.object_alias = key
		
	def shorten_file_name(self):
	
		"""Renames file from something like 
				coj1m011-fl12-20180319-0008-e91.fits
			to:
				fl12-20180319-00091-e91.fits
			so DAOphot doesn't complain about character limits."""
			
		if len(self.basename) == 36:
			new_basename = self.basename[9:].replace('-','')
			print 'Renaming {0} to {1}'.format(self.basename,new_basename)
			new_path = self.full_path.replace(self.basename,new_basename)
			shutil.move(self.full_path,new_path)
		else:
			new_basename = self.basename.replace('-','')
			print 'Renaming {0} to {1}'.format(self.basename,new_basename)
			new_path = self.full_path.replace(self.basename,new_basename)
			shutil.move(self.full_path,new_path)
		
		self.full_path = self.full_path.replace(self.basename,new_basename)
		self.basename = new_basename
		
	def make_opt_file(self, overwrite = True):
	
		opt_path = self.full_path.replace('.fits','.opt')
		
		if (os.path.isfile(opt_path)) & (overwrite == False):
			#print opt_path, ' already exists, overwrite = False.'
			return
		
		opt_params = {'re':9.2589,
				  'ga':1.0,
				  'hi':100000,
				  'ex':9,
				  'wa':-2,
				  'varia':1,
				  'analytic':3,
				  'low good datum':50,
				  'thre':10}

		opt_params['fwhm'] = self.med_fwhm
		opt_params['fitt'] = self.med_fwhm
		opt_params['ps'] = 5. * self.med_fwhm
		opt_params['re'] = self.readnoise
			
		with open(opt_path,'w') as f:
			for key in opt_params:
				f.write('{0} = {1}\n'.format(key,str(opt_params[key])))
				
		print 'Wrote {}'.format(opt_path)

	def move(self,dest):
		print "Moving {} to {}.".format(self.full_path, dest)
		
		if dest[-1] != '/':
			dest = dest + '/'
			
		shutil.move(self.full_path, dest + self.basename)
	
		self.full_path = dest + self.basename
		
class LCODataDir:
	
	def __init__(self,path):
	
		if path[-1] != '/':
			path = path + '/'
			
		self.path = path
	
	def get_input_fits_names(self):
	
		"""Returns basenames of .fits files in directory that have been renamed to the 
			shortened convention"""

		fitss =  glob.glob(self.path + '*.fits')
		input_fits_basenames = [os.path.basename(x).replace('.fits','') for x in fitss]
		#check they match the shortened name convention 
		input_fits_names = [x for x in input_fits_basenames if len(x) == 19]
		
		return input_fits_names
		
	def get_filenames(self,ext):
		"""Globs for and returns all files in directory ending with a given expression"""
		
		return glob.glob(self.path + '*{}'.format(ext))
		
	def make_obs_table(self):
		
		output_file = self.path + 'obs_info.csv'
		
		hdr_items = ['MJD-OBS','FILTER','RDNOISE','EXPTIME','PROPID','SITEID','MED-FWHM']
		hdr_items = [x.lower() for  x in hdr_items]
		#write header of output file
		with open(output_file,'w') as f:
			print 'Writing ' + output_file
			f.write('#ifile')
			for x in hdr_items:
				f.write(','+str(x))
			f.write('\n')
			
		input_fits_names = self.get_input_fits_names()
		
		with open(output_file,'a') as fil:
			for f in input_fits_names:
				ff = LCOFile(self.path + f+'.fits')
				fil.write('{},{},{},{},{},{},{},{}\n'.format(f,ff.mjd_obs,ff.filt,ff.readnoise,
														ff.exptime,ff.propid,ff.siteid,
														ff.med_fwhm))
													
	def read_obs_table(self):
		obs_info_table_path = self.path + 'obs_info.csv'
		if not os.path.isfile(obs_info_table_path):
			print obs_info_table_path," doesn't exist."
			return
		else:
			t = ascii.read(obs_info_table_path, format = 'csv')
			return t



	
		
		
	

