from astropy import coordinates as coord, units as u
from astropy.io import ascii, fits
from astropy.time import Time
import glob
import numpy as np

def WD_mean_mag_std(WD_tab):

	"""Reads in WD photometry table and returns:

		WD_mean_mag : Mean value of WD magnitude in all frames where detected.
		WD_weighted_mean_mag : Weighted mean of WD mags, weighted by errors.
		WD_error_in_mean_squared : average error of WD magnitude errors (all errs added in quaderture, divided by N)
	"""

	filtered_mags = np.array([WD_tab[x] for x in WD_tab.colnames if 'mag_' in x and WD_tab[x] != 99.9999])
	filtered_errs = np.array([WD_tab[x] for x in WD_tab.colnames if 'err_' in x and WD_tab[x] != 9.9999])

	WD_mean_mag = np.mean(filtered_mags)
	WD_weighted_mean_mag = np.average(filtered_mags, weights=filtered_errs)
	
	err_in_mean_squared = 0
	for err in filtered_errs:
		err_in_mean_squared += err**2.
	err_in_mean_squared = err_in_mean_squared / (len(filtered_errs)**2.)

	return WD_mean_mag, WD_weighted_mean_mag, err_in_mean_squared


def add_hjd_to_obs_info_tab(obs_info_tab, fits_dir):
	"""Convert mjd-obs to hjd-obs, write out new obs_info_tab with two new columns hjd, and rounded """

	mjds = obs_info_tab['mjd-obs']

	fits0 = glob.glob(fits_dir+'*[0-9].fits')[0] #first fits file in directory for WCS info 
	ra_field, dec_field = fits.open(fits0)[0].header['ra'], fits.open(fits0)[0].header['dec']

	c = coord.SkyCoord(ra=ra_field, dec=dec_field, frame='icrs',unit=(u.hourangle, u.deg))
	greenwich = coord.EarthLocation.of_site('greenwich')
	ts = Time(mjds, format = 'mjd', location = greenwich)
	ltt_helio = ts.light_travel_time(c, 'heliocentric')
	hjd_heliocentre = ts.mjd + ltt_helio.value
	obs_info_tab['hjd-obs'] = hjd_heliocentre
	obs_info_tab['hjd-obs-int'] = obs_info_tab['hjd-obs'].astype(int)

	return obs_info_tab

def bin_comparison_stars_by_closest_hjd(obs_info_tab):

	hjd_bin = np.trunc(obs_info_tab['hjd-obs-int'] / 5.) 
	hjd_grouped_obs_info_tab = obs_info_tab.group_by(hjd_bin)
	

	return hjd_grouped_obs_info_tab
	
def stable_comparison_star_means_stds(stable_star_tab):
	"""For each row in stable comparison star table, returns mean magnitude of all frames, weighted mean mag of all frames, and std of magnitudes"""
		#mean of all observations for each star id

	star_id_means = []
	star_id_weighted_means = []
	star_id_stds = []

	for idd in stable_star_tab['star_id']:
		id_row = stable_star_tab[stable_star_tab['star_id']==idd]
		star_id_means.append(np.mean([id_row[x] for x in id_row.colnames if 'mag' in x]))
		star_id_weighted_means.append(np.average([id_row[x] for x in id_row.colnames if 'mag' in x],weights = [id_row[x] for x in id_row.colnames if 'err' in x]))
		star_id_stds.append(np.std([id_row[x] for x in id_row.colnames if 'mag' in x]))

	star_id_means = np.array(star_id_means)
	star_id_weighted_means = np.array(star_id_weighted_means)
	star_id_stds = np.array(star_id_stds)

	return star_id_means, star_id_weighted_means, star_id_stds

def stable_comparison_stars_binned_hjd_mean_std(stable_star_tab, obs_info_tab, plot_output_dir, fits_dir):

	"""Reads in table containing stable comparison stars. Bins observations by nearest hjd (since decimal hjd is given,
	   and we want to consider observations taken in the same group). Returns:
		hjd_all_stars : """

	mag_colnames = [x for x in stable_star_tab.colnames if 'mag' in x]

	star_id_means, star_id_weighted_means, star_id_stds = stable_comparison_star_means_stds(stable_star_tab)
	
	hjd_grouped_obs_info_tab = bin_comparison_stars_by_closest_hjd(obs_info_tab)
	hjd_groups = hjd_grouped_obs_info_tab.groups

	hjd_all_stars = []
	mean_all_stars = []
	weighted_mean_all_stars = []
	std_all_stars = []

	for j, group in enumerate(hjd_groups):
		hjd_group = np.mean(group['hjd-obs-int'])
		hjd_all_stars.append(hjd_group)
		fnames_group = group['ifile']

		mean_all_stars_hjd = []
		weighted_mean_all_stars_hjd = []
		std_all_stars_hjd = []

		for i, star_id in enumerate(stable_star_tab['star_id']):
			star_row = stable_star_tab[stable_star_tab['star_id'] == star_id]
			star_row_mags_group =  [star_row['mag_'+ff][0]	for ff in fnames_group]
			star_row_mags_errs_group = [star_row['err_'+ff][0]	for ff in fnames_group]

			mean_star_row_mags_group = np.mean(star_row_mags_group) - star_id_means[i]
			weighted_mean_star_row_mags_group = np.average(star_row_mags_group, weights = star_row_mags_errs_group) - star_id_weighted_means[i]
			std_star_row_mags_group = np.std(star_row_mags_group)

			mean_all_stars_hjd.append(mean_star_row_mags_group)
			weighted_mean_all_stars_hjd.append(weighted_mean_star_row_mags_group)
			std_all_stars_hjd.append(std_star_row_mags_group)

		weighted_mean_all_stars.append(np.mean(weighted_mean_all_stars_hjd))
		mean_all_stars.append(np.mean(mean_all_stars_hjd))
		std_all_stars.append(np.std(mean_all_stars_hjd))

	hjd_comparison_stars = np.array(hjd_all_stars)
	mean_mag_comparison_stars = np.array(mean_all_stars)
	mean_weighted_mag_comparison_stars = np.array(weighted_mean_all_stars)
	std_comparison_stars = np.array(std_all_stars)

	return hjd_comparison_stars, mean_mag_comparison_stars, mean_weighted_mag_comparison_stars, std_comparison_stars

