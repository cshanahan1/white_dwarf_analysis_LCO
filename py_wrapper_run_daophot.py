import sys 
import glob
import shutil
import os

start_dir = '/Users/cshanahan/Desktop/WD_project/scripts'

#targ_dirs= ['/Users/cshanahan/Desktop/WD_project/lco_data/LCO2018A-002/A020.503022']
#targ_dirs = glob.glob('/Users/cshanahan/Desktop/WD_project/lco_data/*/*2016*/')
targ_dirs = ['/Users/cshanahan/Desktop/WD_project/lco_data/WD0418-534/LCO2018A-002/']

for targ_dir in targ_dirs:

	#move required stuff
	reqs = ['daophot.opt','allstar.opt','photo.opt','daophot','allstar','run_daophot.sh','wrapper_run_daophot.sh']

	for req in reqs:
 		shutil.copy(start_dir+'/'+req,targ_dir+'/'+req)
		
	os.chdir(targ_dir)
	
	os.system('./wrapper_run_daophot.sh')
	
	
