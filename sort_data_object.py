"""Renames files from LCO naming convention to a shortened version. 
   Sorts into subdirectories based on target names. In the event of one target having
   multiple names, a name will be chosen from a dictionary of names and their associated
   alises. """

from astropy.io import fits
import argparse
import glob
import os
import shutil
import sys
from LCO_data import LCOFile

def parse_args():

	"""Parse the command line arguments.

	Returns
	-------
	args : obj
		An agparse object containing all of the added arguments
	"""

	parser = argparse.ArgumentParser(
		description="Sort LCO observations in directories by object and filter name.")
		
	parser.add_argument(
		'-input_dir',
		required = True,
		help = 'Path to directory that contains files to sort.')
		
	parser.add_argument('-output_loc',
						required=True, 
	help='Path to location where output directories will be created and files will be moved to.')
	args = parser.parse_args()

	return args
	
def main_sort_data_object_propid(input_dir,output_loc):

	if not os.path.isdir(output_loc):
		print 'Making directory {}.'.format(output_loc)
	
	ifiles = glob.glob(input_dir+'/*.fits')
	
	if len(ifiles) < 1:
		print 'No files in input directory.'
	else:
		print 'Sorting {} files.'.format(str(len(ifiles)))
		
	for f in ifiles:
		print f
		lcofile = LCOFile(f)
		targname = lcofile.object_alias
		lcofile.shorten_file_name()
		final_path = output_loc + '/{}'.format(targname)
		if not os.path.isdir(final_path):
			print 'Making directory {}'.format(final_path)
			os.makedirs(final_path)
		
		lcofile.move(final_path)


if __name__ == '__main__':

	input_dir = '/Users/cshanahan/Desktop/WD_project/LCO2018B'
	output_loc = '/Users/cshanahan/Desktop/WD_project/LCO2018B'
	
	main_sort_data_object_propid(input_dir,output_loc)
	
	