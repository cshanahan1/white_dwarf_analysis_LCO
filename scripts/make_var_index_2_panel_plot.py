from astropy.io import ascii
import glob
import matplotlib.pyplot as plt
import os

def make_var_index_2_panel_plot(targname, WD_tab, close_mag_tab, phot_tab, plot_output_dir, fits_dir, unstable_star_idx=-1, stable_star_idx=0):

	WD_tab = ascii.read(WD_tab, format='csv')
	phot_tab = ascii.read(phot_tab, format='csv')
	close_mag_tab = ascii.read(close_mag_tab, format='csv')

	stable_star_idx = close_mag_tab[stable_star_idx]['star_id']
	unstable_star_idx = close_mag_tab[unstable_star_idx]['star_id']

	ref_file = os.path.basename(glob.glob(fits_dir+'*.mag')[0].replace('.mag','.fits'))

	#pick most unstable star
	most_unstable_star_tab = phot_tab[phot_tab['star_id'] == unstable_star_idx]

	#pick_most_stable_star
	most_stable_star_tab = phot_tab[phot_tab['star_id'] == stable_star_idx] 


	f, (ax1, ax2) = plt.subplots(nrows=1, ncols=2, sharex=True, figsize=(12,7))
	

	### PANEL 1 ###

	#sort by var index, index to clip outliers
	phot_tab.sort('var_index')
	ref_phot_output_tab = phot_tab[phot_tab['mag_'+ref_file.replace('.fits','')] != 99.9999][0:-25]

	#make ylim the same for both
	max_ws_index = max(ref_phot_output_tab['var_index'])

	ax1.set_ylim(0, max_ws_index*5.)
	ax2.set_ylim(0, max_ws_index*5.)
	
	#scatter plot of variability index of all stars in reference image
	ax1.scatter(ref_phot_output_tab['mag_'+ref_file.replace('.fits','')],ref_phot_output_tab['var_index'], c= 'k',s = 10,label = 'ref image stars')

	#plot most unstable star
	ax1.scatter(most_unstable_star_tab['mag_'+ref_file.replace('.fits','')], most_unstable_star_tab['var_index'], \
				c='b',s=75,label = 'Star ' + str(most_unstable_star_tab['star_id'][0]))

	#plot WD
	ax1.scatter(WD_tab['mag_'+ref_file.replace('.fits','')],WD_tab['var_index'],c='r',s=150,label = targname,marker='*')

	#plot most stable star
	ax1.scatter(most_stable_star_tab['mag_'+ref_file.replace('.fits','')],most_stable_star_tab['var_index'],c='g',s=75,label = 'Star ' + str(most_stable_star_tab['star_id'][0]))
	plt.gca().invert_xaxis()
	ax1.legend(loc = 'upper left',prop={'size': 10})
	ax1.set_title('Weltch-stetson index')


	### PANEL 2 ###

	#now sort by chi2_nu
	phot_tab.sort('chi2_nu')
	ref_phot_output_tab = phot_tab[phot_tab['mag_'+ref_file.replace('.fits','')] != 99.9999][0:-25]

	#scatter plot of chi2_nu of all stars in reference image
	ax2.scatter(ref_phot_output_tab['mag_'+ref_file.replace('.fits','')],ref_phot_output_tab['chi2_nu'], c= 'k',s = 10,label = 'ref image stars')

	#plot most unstable star
	ax2.scatter(most_unstable_star_tab['mag_'+ref_file.replace('.fits','')], most_unstable_star_tab['chi2_nu'], \
				c='b',s=75,label = 'Star ' + str(most_unstable_star_tab['star_id'][0]))

	#plot WD
	ax2.scatter(WD_tab['mag_'+ref_file.replace('.fits','')],WD_tab['chi2_nu'],c='r',s=150,label = targname,marker='*')

	#plot most stable star
	ax2.scatter(most_stable_star_tab['mag_'+ref_file.replace('.fits','')],most_stable_star_tab['var_index'],c='g',s=75,label = 'Star ' + str(most_stable_star_tab['star_id'][0]))

	f.text(0.5, 0.04, 'g [mag]', ha='center', fontsize=18)
	ax1.set_ylabel('var index', fontsize = 18)
	plt.gca().invert_xaxis()
	ax2.legend(loc = 'upper left',prop={'size': 10})
	ax2.set_title(r'$chi^2$')

	print('Saving {}.'.format(plot_output_dir+'{}_var_idx_plot.png'.format(targname)))
	plt.savefig(plot_output_dir+'{}_var_idx_plot.png'.format(targname))
	plt.close()

if __name__ == '__main__':

	stable_star_idx = 0
	unstable_star_idx = -1

	all_23_targs = ['SDSSJ010322.19-002047.7','SDSSJ022817.16-082716.4','SDSSJ024854.96+334548.3','SDSSJ041053.632-063027.580','SDSSJ072752.76+321416.1',
		 		'SDSSJ081508.78+073145.7','SDSSJ102430.93-003207.0','SDSSJ111059.42-170954.2','SDSSJ111127.30+395628.0','SDSSJ120650.504+020143.810',
		 		'SDSSJ121405.11+453818.5','SDSSJ130234.43+101238.9','SDSSJ131445.050-031415.588','SDSSJ151421.27+004752.8','SDSSJ155745.40+554609.7',
		 		'SDSSJ163800.360+004717.822','SDSSJ172135.97+294016.0','SDSSJ181424.075+785403.048','SDSSJ20372.169-051302.964','SDSSJ210150.65-054550.9',
		 		'SDSSJ232941.330+001107.755','SDSSJ235144.29+375542.6','WD0554-165']


	for targname in all_23_targs:
		print(targname)
		WD_tab = '/Users/cshanahan/Desktop/white_dwarf_analysis_LCO/processed_data/23_northern_targets/psf_phot/{}/plots_and_output/WD_tab.csv'.format(targname)
		phot_tab = '/Users/cshanahan/Desktop/white_dwarf_analysis_LCO/processed_data/23_northern_targets/psf_phot/{}/plots_and_output/{}_phot_output.txt'.format(targname, targname)
		plot_output_dir = '/Users/cshanahan/Desktop/white_dwarf_analysis_LCO/output_for_paper/23_northern/var_index_plots/'
		close_mag_tab = '/Users/cshanahan/Desktop/white_dwarf_analysis_LCO/processed_data/23_northern_targets/psf_phot/{}/plots_and_output/close_mag_tab.csv'.format(targname)
		fits_dir = '/Users/cshanahan/Desktop/white_dwarf_analysis_LCO/processed_data/23_northern_targets/psf_phot/{}/'.format(targname)

		make_var_index_2_panel_plot(targname, WD_tab, close_mag_tab, phot_tab, plot_output_dir, fits_dir, unstable_star_idx=-1, stable_star_idx=0)
