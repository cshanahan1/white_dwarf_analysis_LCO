from astropy.io import ascii 
from plotting_helper_functions import *
import matplotlib.pyplot as plt
# change default font for all plot text to LaTeX font; also change font size
plt.rcParams['font.family'] = 'serif'
plt.rcParams['mathtext.fontset'] = 'custom'
plt.rcParams['xtick.labelsize']=20
plt.rcParams['ytick.labelsize']=20

def make_lightcurve_plot(WD_tab, stable_star_tab, obs_info_tab, plot_output_dir, fits_dir, targname, weighted=True):

	WD_tab = ascii.read(WD_tab, format='csv')
	stable_star_tab = ascii.read(stable_star_tab, format='csv')
	obs_info_tab = ascii.read(obs_info_tab)
	obs_info_tab = add_hjd_to_obs_info_tab(obs_info_tab, fits_dir)

	#hjd, mean mags, and std of stable comparison star groups, grouped by nearest hjd
	hjd_comparison_stars, mean_mag_comparison_stars, mean_weighted_mag_comparison_stars, std_comparison_stars = stable_comparison_stars_binned_hjd_mean_std(stable_star_tab, obs_info_tab, plot_output_dir, fits_dir)

	#for each comparison star, mean mag of all observations
	star_id_means, star_id_weighted_means, star_id_stds = stable_comparison_star_means_stds(stable_star_tab)

	if weighted==True:
		mean_mag_comparison_stars = mean_weighted_mag_comparison_stars
		star_id_means = star_id_weighted_means

	all_difs = []
	for col in stable_star_tab.colnames:
		if 'mag' in col:
			for i, val in enumerate(stable_star_tab[col]):
				all_difs.append(stable_star_tab[col][i] - star_id_means[i])
	std_all_stable = np.std(all_difs)

	comparison_star_plot_label = r'stable comparison stars ({} $<$ var. index $<$ {}), $\sigma$={}'.\
								format(str(min(stable_star_tab['var_index'])),\
								str(max(stable_star_tab['var_index'])),\
								str(round(std_all_stable, 3)))

	plt.figure(figsize = (20,10))

	plt.fill_between(hjd_comparison_stars, mean_mag_comparison_stars-std_comparison_stars, mean_mag_comparison_stars+std_comparison_stars,color='r', alpha = 0.1)
	plt.plot(hjd_comparison_stars, mean_mag_comparison_stars, color='r', label = comparison_star_plot_label)

	WD_mean_mag, WD_weighted_mean_mag, WD_err_in_mean_squared = WD_mean_mag_std(WD_tab)

	filtered_mags = np.array([WD_tab[x] for x in WD_tab.colnames if 'mag_' in x and WD_tab[x] != 99.9999])
	WD_std_0 = np.std(filtered_mags-WD_mean_mag)
	WD_label =	r'{}, var. index={}, $\sigma$={}'.format(targname,str(WD_tab['var_index'][0]),str(np.round(WD_std_0, 3)))

	if weighted==True:
		WD_mean_mag = WD_weighted_mean_mag

	for i, val in enumerate([x for x in WD_tab.colnames if 'mag' in x]):
		ff = val.replace('mag_','')
		err = val.replace('mag_','err_')

		WD_hjd = obs_info_tab['hjd-obs'][obs_info_tab['ifile']==ff][0]
		WD_mag = WD_tab[val] - WD_mean_mag
		WD_err = np.sqrt(WD_tab[err]**2. + WD_err_in_mean_squared)

		if i == 0:
			plt.errorbar(WD_hjd, WD_mag, yerr = WD_err, label = None, c= 'k')
			plt.scatter(WD_hjd, WD_mag,s = 155, marker = 'x', c='k', zorder =3, label = WD_label)
		else:
			plt.errorbar(WD_hjd, WD_mag, yerr = WD_err, label = None, c= 'k')
			plt.scatter(WD_hjd, WD_mag,s = 155, marker = 'x', c='k', zorder = 3, label = None)

	plt.legend(loc='best', fontsize = 27, frameon=False)
	plt.xlabel('HJD',fontsize = 30)
	plt.ylabel(r'$\Delta$ mag', fontsize = 30)
	plt.ylim(-0.1,0.1)

	plt.savefig(plot_output_dir + 'lightcurve_{}.png'.format(targname))
	#plt.show()
	print('saving {}'.format(plot_output_dir + 'lightcurve_{}'.format(targname)))

if __name__ == '__main__':

		all_23_targs = ['SDSSJ010322.19-002047.7','SDSSJ022817.16-082716.4','SDSSJ024854.96+334548.3','SDSSJ041053.632-063027.580','SDSSJ072752.76+321416.1',
				 		'SDSSJ081508.78+073145.7','SDSSJ102430.93-003207.0','SDSSJ111059.42-170954.2','SDSSJ111127.30+395628.0','SDSSJ120650.504+020143.810',
				 		'SDSSJ121405.11+453818.5','SDSSJ130234.43+101238.9','SDSSJ131445.050-031415.588','SDSSJ151421.27+004752.8','SDSSJ155745.40+554609.7',
				 		'SDSSJ163800.360+004717.822','SDSSJ172135.97+294016.0','SDSSJ181424.075+785403.048','SDSSJ20372.169-051302.964','SDSSJ210150.65-054550.9',
				 		'SDSSJ232941.330+001107.755','SDSSJ235144.29+375542.6','WD0554-165']


		for targname in all_23_targs[0:1]:
			print(targname)
			WD_tab = '/Users/cshanahan/Desktop/white_dwarf_analysis_LCO/processed_data/23_northern_targets/psf_phot/{}/plots_and_output/WD_tab.csv'.format(targname)
			stable_star_tab = '/Users/cshanahan/Desktop/white_dwarf_analysis_LCO/processed_data/23_northern_targets/psf_phot/{}/plots_and_output/stable_comparison_star_tab.csv'.format(targname)
			obs_info_tab = '/Users/cshanahan/Desktop/white_dwarf_analysis_LCO/processed_data/23_northern_targets/psf_phot/{}/obs_info.csv'.format(targname)
			plot_output_dir = '/Users/cshanahan/Desktop/white_dwarf_analysis_LCO/output_for_paper/23_northern/lightcurve_plots/'
			fits_dir = '/Users/cshanahan/Desktop/white_dwarf_analysis_LCO/processed_data/23_northern_targets/psf_phot/{}/'.format(targname)


			make_lightcurve_plot(WD_tab, stable_star_tab, obs_info_tab, plot_output_dir, fits_dir, targname, weighted=False)

