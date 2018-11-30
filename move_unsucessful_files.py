"""Checks for fits files that don't have an 's.fits' file, meaning DAOPhot did not 
	sucessfuly run. Creates a subdirdirectory (in the input directory) called 
	'unsucessful' and moves the fits/opt files there.
"""
import glob
import shutil
import os


def move_unsucessful_files(dir):

	if dir[-1] != '/':
		dir = dir + '/'
	
	fits = glob.glob(dir+'*[0-9].fits')
	sfits = glob.glob(dir+'*s.fits')
	
	if not os.path.isdir(dir+'unsucessful'):
		print 'Making directory', dir+'unsucessful'
		os.mkdir(dir+'unsucessful')
	

	for fit in fits:
		if fit.replace('.fits','s.fits') not in sfits:
			print fit,'not sucessful'
			move_files = glob.glob(dir + os.path.basename(fit).replace('.fits','')+'*')
			for f in move_files:
				targ = f
				dest = dir + 'unsucessful'
				print 'Moving',targ,'to',dest
				shutil.move(targ,dest)
			
			
if __name__ == '__main__':

	#dirs = glob.glob('/Users/cshanahan/Desktop/WD_project/lco_data/*/*2016*/')
	dirs = ['/Users/cshanahan/Desktop/WD_project/lco_data/WD0418-534/LCO2018A-002/new_files/']
	for dir in dirs:
		move_unsucessful_files(dir)
	