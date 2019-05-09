from astropy.io import ascii, fits
from astropy.table import Table
from astropy import units as u
from astropy.coordinates import SkyCoord
from ginga.util import zscale
import glob
import numpy as np
import os
#from plotting_functions import *
from parse_output_files_to_photcat import *
import sys
import matplotlib.pyplot as plt
import scipy.misc
#obs_info_tab = ascii.read(obs_info)

def construct_phot_table(targname,base_path,plot_output_dir):
	mag_file = glob.glob(base_path+'*.mag')[0]
	ref_file = mag_file.replace('.mag','.fits')
	cor_file = mag_file.replace('.mag','.cor')
	mch_file = mag_file.replace('.mag','.mch')
	obs_info = base_path+'obs_info.csv'
	parse_output_files_to_photcat(targname, ref_file, mch_file, cor_file, mag_file, plot_output_dir)
	phot_output_tab = ascii.read(plot_output_dir+'{}_phot_output.txt'.format(targname),format = 'csv')
	#sort table by variability index
	phot_output_tab.sort('var_index')
	return phot_output_tab

def filter_phot_table(phot_output_tab):
	#filter out 99.9999s (star not detected in frame)
	mag_cols = [x for x in phot_output_tab.colnames if 'mag' in x]
	for i, nam in enumerate(mag_cols):
		if i == 0:
			phot_output_tab = phot_output_tab[(phot_output_tab[mag_cols[0]] != 99.9999)]
		else:
			phot_output_tab = phot_output_tab[(phot_output_tab[mag_cols[i]] != 99.9999)]

	return phot_output_tab

def find_wd(targname, plot_output_dir,phot_output_tab,ref_file, delta_ra_dec = 0.001):

	ref_file_hdr = fits.open(ref_file)[0].header
	cat_ra,cat_dec = ref_file_hdr['cat-ra'],ref_file_hdr['cat-dec']
	c = SkyCoord(ra=cat_ra, dec=cat_dec, frame='icrs',unit=(u.hourangle, u.deg))
	ref_ra, ref_dec = c.ra.deg, c.dec.deg
	print 'Finding {} in list of stars. Catalog position is {}, {}'.format(targname,ref_ra,ref_dec)

	match_obj = phot_output_tab[(np.abs(phot_output_tab['ra_ref']-ref_ra) < delta_ra_dec) \
	& (np.abs(phot_output_tab['dec_ref']-ref_dec) < delta_ra_dec)]

	if len(match_obj) == 0:
		print 'no WD found within {} degrees in RA and in Dec of catalog position'.format(str(delta_ra_dec))
		sys.exit()
	if len(match_obj) > 1:
		print 'multiple stars found within {} degrees in RA and in Dec of catalog position'.format(str(delta_ra_dec))
		sys.exit()
	WD_id = match_obj['star_id']
	WD_tab = phot_output_tab[(phot_output_tab['star_id'] == WD_id) & (phot_output_tab['ra_ref'] == match_obj['ra_ref'])]

	#mag, err values that aren't 99.9999, 9.9999
	filtered_mags = np.array([WD_tab[x] for x in WD_tab.colnames if 'mag_' in x and WD_tab[x] != 99.9999])
	filtered_errs = np.array([WD_tab[x] for x in WD_tab.colnames if 'err_' in x and WD_tab[x] != 9.9999])
	WD_mag_0 = np.mean(filtered_mags)
	WD_std_0 = np.std(filtered_mags-WD_mag_0)
	WD_weighted_mean_mag = np.average(filtered_mags,weights = filtered_errs)
	print '\nFound WD {0} within delta RA, Dec of {1}, at {2} {3}. Mean mag is {4}, var. index {5}'.\
	format(targname, str(delta_ra_dec), str(WD_tab['ra_ref'][0]),str(WD_tab['dec_ref'][0]), str(WD_mag_0),str(WD_tab['var_index'][0]))
	ascii.write(WD_tab,plot_output_dir + 'WD_tab.csv',format = 'csv', overwrite = True)

	return (WD_tab, WD_id, WD_mag_0, WD_std_0, WD_weighted_mean_mag)

def output_wd_cutout_images(ref_file,WD_tab, base_path, plot_output_dir, subtracted = True):
	#make cutout of WD in each frame
	#if 'subtracted', also make cutouts of subtracted images
	print 'making WD cutout images\n'
	if not os.path.isdir(plot_output_dir+'/WD_cutout_images/unsubtracted'):
		print 'Making directory ',plot_output_dir+'/WD_cutout_images/unsubtracted'
		os.makedirs(plot_output_dir+'/WD_cutout_images/unsubtracted')

	if subtracted:
		if not os.path.isdir(plot_output_dir+'/WD_cutout_images/subtracted'):
			print 'Making directory ',plot_output_dir+'/WD_cutout_images/subtracted'
			os.makedirs(plot_output_dir+'/WD_cutout_images/subtracted')

	ref_file_dat = fits.open(ref_file)['sci',1].data
	all_fits = glob.glob(base_path + '*[0-9].fits')


	WD_ra, WD_dec = WD_tab['ra_ref'][0], WD_tab['dec_ref'][0]
	for f in all_fits:
		s_file = f.replace('.fits','s.fits')
		dat = fits.open(f)['sci',1].data
		if subtracted:
			dat_sub = fits.open(s_file)['sci',1].data

		mjd_obs = fits.open(f)[0].header['mjd-obs']

		magg = WD_tab['mag_'+os.path.basename(f).replace('.fits','')][0]

		wcs_file = WCS(f)
		WD_x, WD_y = wcs_file.all_world2pix(WD_ra,WD_dec,1)

		dat_cutout = dat[int(WD_y)-35:int(WD_y)+35,int(WD_x)-35:int(WD_x)+35]
		if subtracted:
			s_dat_cutout = dat_sub[int(WD_y)-35:int(WD_y)+35,int(WD_x)-35:int(WD_x)+35]

		cutout_path = plot_output_dir+'/WD_cutout_images/unsubtracted/{}_{}_{}mag.png'.format(str(mjd_obs),\
																					os.path.basename(f).replace('.fits',''),\
																					str(magg))

		z1, z2 = zscale.zscale(dat_cutout)
		plt.imshow(dat_cutout, origin = 'lower', vmin = z1, vmax = z2,cmap='Greys_r')
		plt.savefig(cutout_path)

		if subtracted:
			subtracted_cutout_path = cutout_path.replace('unsubtracted','subtracted')
			z1, z2 = zscale.zscale(s_dat_cutout)
			plt.imshow(s_dat_cutout, origin = 'lower', vmin = z1, vmax = z2,cmap='Greys_r')
			plt.savefig(subtracted_cutout_path)
	print '*************************************************'



def write_close_mag_tab(phot_output_tab,ref_file,plot_output_dir,WD_id,WD_mag_0,delta_mag = 0.25,exclude_star_ids = []):

	ref_file_col = phot_output_tab['mag_'+os.path.basename(ref_file).replace('.fits','')]

	len_close_mag = 0
	n_inc = 0
	while len_close_mag < 20:
		close_mag_tab = phot_output_tab[(ref_file_col > (WD_mag_0 - (delta_mag + n_inc))) & (ref_file_col < (WD_mag_0 + delta_mag + n_inc)) & (ref_file_col != 99.9999)]
		close_mag_tab = close_mag_tab[close_mag_tab['star_id'] != WD_id]
		len_close_mag = len(close_mag_tab)
		delta_mag = delta_mag + n_inc
		n_inc += 0.25

	print 'found {} stars within {} mag of WD {}, mag = {}'.format(str(len(close_mag_tab)),str(delta_mag), targname, str(WD_mag_0))
	print 'writing {}'.format(plot_output_dir + 'close_mag_tab.csv')
	print '*************************************************'
	ascii.write(close_mag_tab, plot_output_dir + 'close_mag_tab.csv', format = 'csv', overwrite = True)
	with open(plot_output_dir + 'close_mag_log.txt', 'w') as f:
		print 'writing ', plot_output_dir + 'close_mag_log.txt'
		f.write('found {} stars within {} mag of WD {}, mag = {}'.format(str(len(close_mag_tab)),str(delta_mag), targname, str(WD_mag_0)))
	return close_mag_tab

def write_stable_comparison_star_table(close_mag_tab,plot_output_dir, WD_id, sharp_lim = 0.5):

	print 'Cutting close mag table on sharpness, and selecting 15 most stable stars'
	stable_group_tab = close_mag_tab[np.abs(close_mag_tab['sharp']) <= sharp_lim]
	stable_group_tab = stable_group_tab[stable_group_tab['star_id'] != WD_id][0:15]
	print 'writing {}.'.format(plot_output_dir + 'stable_comparison_star_tab.csv')
	print '*************************************************'
	ascii.write(stable_group_tab, plot_output_dir + 'stable_comparison_star_tab.csv', format = 'csv', overwrite = True)
	return stable_group_tab

def output_stable_star_cutout_images(ref_file, stable_group_tab, base_path, plot_output_dir ,subtracted = False):
	#make cutout of WD in each frame

	print 'making stable star cutout images\n'
	if not os.path.isdir(plot_output_dir+'/stable_star_cutout_images/unsubtracted'):
		print 'Making directory ',plot_output_dir+'/stable_star_cutout_images/unsubtracted'
		os.makedirs(plot_output_dir+'/stable_star_cutout_images/unsubtracted')

	if subtracted:
		if not os.path.isdir(plot_output_dir+'/stable_star_cutout_images/subtracted'):
			print 'Making directory ',plot_output_dir+'/stable_star_cutout_images/subtracted'
			os.makedirs(plot_output_dir+'/stable_star_cutout_images/subtracted')


	all_fits = glob.glob(base_path + '*[0-9].fits')[::5]

	for row in stable_group_tab:
		star_id = row['star_id']
		ra_ref, dec_ref = row['ra_ref'], row['dec_ref']

		for f in all_fits:
			fname = os.path.basename(f).replace('.fits','')
			dat = fits.open(f)[0].data
			wcs_file = WCS(f)
			mjd_obs = fits.open(f)[0].header['mjd-obs']
			magg = row['mag_'+os.path.basename(f).replace('.fits','')]
			s_x, s_y = wcs_file.all_world2pix(ra_ref,dec_ref,1)
			z1, z2 = zscale.zscale(dat)
			dat_cutout = dat[int(s_y)-25:int(s_y)+25,int(s_x)-25:int(s_x)+25]
			plt.imshow(dat_cutout, origin = 'lower', vmin = z1, vmax = z2)
			plt.title('star #{}, mjd = {} mag = {}'.format(str(star_id),mjd_obs, magg))
			plt.savefig(plot_output_dir+'/stable_star_cutout_images/unsubtracted/'+'{}_{}_{}.png'.format(star_id,mjd_obs,fname))

def main_choose_comparison_stars(targname, base_path, plot_output_dir,
								save_cutout_WD = False, save_cutout_stable_stars = False):

	print(base_path+'*.mag')
	mag_file = glob.glob(base_path+'*.mag')[0]
	ref_file = mag_file.replace('.mag','.fits')

	phot_output_tab = construct_phot_table(targname, base_path, plot_output_dir)
	#phot_output_tab = ascii.read(plot_output_dir+'_phot_output.txt',format = 'csv')

	WD_tab, WD_id, WD_mag_0, WD_std_0, WD_weighted_mean_mag = find_wd(targname, plot_output_dir,phot_output_tab,ref_file, delta_ra_dec = 0.002)
	if save_cutout_WD:
		output_wd_cutout_images(ref_file, WD_tab, base_path, plot_output_dir, subtracted = True)
	phot_output_tab = filter_phot_table(phot_output_tab)
	close_mag_tab = write_close_mag_tab(phot_output_tab,ref_file,plot_output_dir,WD_id,WD_mag_0,delta_mag = 0.25)
 	stable_group_tab = write_stable_comparison_star_table(close_mag_tab,plot_output_dir, WD_id,sharp_lim = 0.5)
 	if save_cutout_stable_stars:
 		output_stable_star_cutout_images(ref_file, stable_group_tab, base_path, plot_output_dir)

if __name__ == '__main__':

 	targs = glob.glob('/Users/cshanahan/Desktop/clean_desktop/WD_project/redo_final_ver/23_northern_targets/psf_phot/*/')
	# targs = glob.glob('/Users/cshanahan/Desktop/clean_desktop/WD_project/redo_final_ver/southern_targs/new_psf_phot/W*/')
	# targs = targs + glob.glob('/Users/cshanahan/Desktop/clean_desktop/WD_project/redo_final_ver/southern_targs/new_psf_phot/S*/')
	# targs = targs + glob.glob('/Users/cshanahan/Desktop/clean_desktop/WD_project/redo_final_ver/southern_targs/new_psf_phot/A*/')

	for targ in targs:
		dir = targ
		targname = dir.split('/')[-2]
		print 'starting ', targname
		print '*\n*\n*\n'
		plot_output_dir = dir + 'plots_and_output/'
		if not os.path.isdir(plot_output_dir):
			os.makedirs(plot_output_dir)
			print 'making directory ' + plot_output_dir
		main_choose_comparison_stars(targname, dir, plot_output_dir, \
								 save_cutout_WD = False, save_cutout_stable_stars = False)
