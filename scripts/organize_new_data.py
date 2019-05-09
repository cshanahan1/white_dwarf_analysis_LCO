import glob
from LCO_photometry_pipeline import *
from LCO_data import *
import shutil
import os


def organize_new_data(new_data_dir,data_dir):

	"""Sorts data in new_data_dir into subdirectories within data_dir, by object name"""

	new_data_dir = format_path(new_data_dir)
	data_dir = format_path(data_dir)

	new_files = glob.glob(new_data_dir+'*.fits')

	for f in new_files:
		print f
		new_file = LCOFile(f)

		new_file.shorten_file_name()

		subdir = data_dir + new_file.object_alias + '/'

		#if subdirectory doesn't exist, make it
		if not os.path.isdir(subdir):
			print 'Making directory ' + subdir
			os.makedirs(subdir)

		new_file.move(subdir)


if __name__ == '__main__':

	new_data_dir = '/Users/cshanahan/Desktop/clean_desktop/WD_project/all_lco_data'
	data_dir = '/Users/cshanahan/Desktop/clean_desktop/WD_project/all_lco_data'
	organize_new_data(new_data_dir,data_dir)
