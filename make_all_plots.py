from astropy.io import ascii
from choose_comparison_stars import *
import glob
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.pyplot import cm 
import os
# import module that sets formatting parameters
from matplotlib import rc
# change default font for all plot text to LaTeX font; also change font size
plt.rcParams['font.family'] = 'Times New Roman'
plt.rcParams['xtick.labelsize']=20
plt.rcParams['ytick.labelsize']=20


def make_plot_0(base_path, phot_output_tab, plot_output_dir, stable_star_tab, unstable_star_tab, targname):

	mag_file = glob.glob(base_path+'*.mag')[0]
	ref_file = mag_file.replace('.mag','.fits')
	ref_file = os.path.basename(ref_file)
	plt.figure(figsize = (8,6))
	#clip outliers
	phot_output_tab.sort('var_index')
	print phot_output_tab
	ref_phot_output_tab = phot_output_tab[phot_output_tab['mag_'+ref_file.replace('.fits','')] != 99.9999][0:-10]
	plt.scatter(ref_phot_output_tab['mag_'+ref_file.replace('.fits','')],ref_phot_output_tab['var_index'], c= 'k',s = 10,label = 'ref image stars')
	plt.scatter(unstable_star_tab['mag_'+ref_file.replace('.fits','')],unstable_star_tab['var_index'],c='b',s=75,label = 'Star ' + str(unstable_star_tab['star_id'][0]))
	plt.scatter(WD_tab['mag_'+ref_file.replace('.fits','')],WD_tab['var_index'],c='r',s=150,label = targname,marker='*')
	plt.scatter(stable_star_tab['mag_'+ref_file.replace('.fits','')],stable_star_tab['var_index'],c='g',s=75,label = 'Star ' + str(stable_star_tab['star_id'][0]))
	plt.legend(loc = 'best',prop={'size': 15})
	plt.xlabel('g [mag]', fontsize = 20)
	plt.ylabel('var index', fontsize = 20)
	plt.xticks(fontsize = 15)
	plt.yticks(fontsize = 15)
	plt.gca().invert_xaxis()
	print 'saving ', plot_output_dir+targname+'_var_idx_mag.pdf'
	plt.savefig(plot_output_dir+targname+'_var_idx_mag.pdf',dpi = 800, format = 'pdf')
	
def make_plot_1(targname,base_path,plot_output_dir,WD_tab,stable_star_tab,unstable_star_tab):
	obs_info_tab = base_path + '/obs_info.csv'
	obs_info_tab = ascii.read(obs_info_tab)
	
	plott = plt.figure(figsize=(14*1.2,8*1.2))
	for i, row in enumerate(obs_info_tab):
		fname = row['ifile'].replace('.fits','')
		mjd = row['mjd-obs']
		mag_WD = WD_tab['mag_'+fname][0]
		mag_stable_compare = stable_star_tab['mag_'+fname][0]
		mag_unstable_compare = unstable_star_tab['mag_'+fname][0]
		if	mag_unstable_compare != 99.9999:
			err_unstab = unstable_star_tab['err_'+fname][0]
			plt.errorbar(mjd,mag_unstable_compare,yerr=err_unstab, c='b',capsize=6)
			if i == 0:
				plt.scatter(mjd,mag_unstable_compare,c='b',s=20,label = 'Star '+ str(unstable_star_tab['star_id'][0])+', var = '+str(unstable_star_tab['var_index'][0])+r', $<$g$>$ = '+str(np.round(np.mean(unstable_star_mean_mag),4)))
			else:
				plt.scatter(mjd,mag_unstable_compare,c='b',s=20)	  
		if mag_WD != 99.9999:
			err_WD = WD_tab['err_'+fname][0]
			plt.errorbar(mjd,mag_WD,yerr=err_WD, c='r',capsize=6)
			if i == 0:
				plt.scatter(mjd,mag_WD,c='r',s=20,label = targname+', var = '+str(WD_tab['var_index'][0])+r', $<$g$>$ = '+str(np.mean(mag_WD)))
			else:
				plt.scatter(mjd,mag_WD,c='r',s=20)	   
		if	mag_stable_compare != 99.9999:
			err_stab = stable_star_tab['err_'+fname][0]
			plt.errorbar(mjd,mag_stable_compare,yerr=err_stab, c='g',capsize=6)
			if i == 0:
				plt.scatter(mjd,mag_stable_compare,c='g',s=20,label = 'Star '+ str(stable_star_tab['star_id'][0])+', var = '+str(stable_star_tab['var_index'][0])+r', $<$g$>$ = '+str(np.round(np.mean(stable_star_mean_mag),4)))
			else:
				plt.scatter(mjd,mag_stable_compare,c='g',s=20)
		plt.xticks(fontsize = 15)
		plt.yticks(fontsize = 15)
		plt.legend(loc=8,prop={'size': 15})
		plt.title(targname,fontsize = 20)  
		plt.ylabel('g [mag]',fontsize = 20)
		plt.gca().invert_yaxis()
		plt.xlabel('MJD',fontsize = 20)
	
	print 'saving ' + plot_output_dir+targname+'_plot1.pdf'
	plt.savefig(plot_output_dir+targname+'_plot1.pdf',dpi = 800, format = 'pdf')
	
def make_mjd_groups(stable_group_tab, plot_output_dir, base_path):

	obs_info_tab = base_path + '/obs_info.csv'
	obs_info_tab = ascii.read(obs_info_tab)
	
	#mean of all observations for each star id
	star_id_means = []
	star_id_weighted_means = []
	star_id_medians = []
	star_id_stds = []
	for idd in stable_group_tab['star_id']:
		id_row = stable_group_tab[stable_group_tab['star_id']==idd]
		star_id_means.append(np.mean([id_row[x] for x in id_row.colnames if 'mag' in x]))
		star_id_weighted_means.append(np.average([id_row[x] for x in id_row.colnames if 'mag' in x],weights = [id_row[x] for x in id_row.colnames if 'err' in x]))
		star_id_medians.append(np.median([id_row[x] for x in id_row.colnames if 'mag' in x]))
		star_id_stds.append(np.std([id_row[x] for x in id_row.colnames if 'mag' in x]))
	
	star_id_means = np.array(star_id_means)
	star_id_medians = np.array(star_id_medians)
	star_id_stds = np.array(star_id_stds)

	#write table with comparison stars info
	with open(plot_output_dir+'{}_comparison_star_info.txt'.format(targname),'w') as f:
		print 'writing ', plot_output_dir+'{}_comparison_star_info.txt'.format(targname)
		f.write('#starid, star_ra, star_dec, mean_mag_weighted, mean_mag_unweighted, sigma_mag, var_idx\n')

	for i, star_id in enumerate(stable_group_tab['star_id']):
		star_row = stable_group_tab[stable_group_tab['star_id'] == star_id]
		with open(plot_output_dir+'{}_comparison_star_info.txt'.format(targname),'a') as f:
			#starid,star_ra,star_dec,mean_mag_weighted,mean_mag_unweighted,sigma_mag,var_idx
			star_row_mags = [star_row[col] for col in mag_colnames]
			star_row_errs = [star_row[col.replace('mag','err')] for col in mag_colnames]
			mean_star_row_mags = np.average(star_row_mags, weights = star_row_errs)
			unweighted_mean = np.mean(star_row_mags)
			std_star_row_mags = np.std(star_row_mags)
			write_line = '{}, {}, {}, {}, {}, {}, {}\n'.format(str(star_id),str(star_row['ra_ref'][0]),\
														str(star_row['dec_ref'][0]),str(mean_star_row_mags),\
														str(unweighted_mean),str(std_star_row_mags),\
														str(star_row['var_index'][0]))
	
			f.write(write_line)

	#make groups of MJD to round observations 
	max_var = str(max(stable_group_tab['var_index']))
	min_var = str(min(stable_group_tab['var_index']))

	obs_info_tab['mjd-obs-int'] = obs_info_tab['mjd-obs'].astype(int)

	mjd_bin = np.trunc(obs_info_tab['mjd-obs-int'] / 5.)
	mjd_groups_obs_info_tab = obs_info_tab.group_by(mjd_bin)
	mjd_groups = mjd_groups_obs_info_tab.groups
	
	all_difs = []
	for col in stable_group_tab.colnames:
		if 'mag' in col:
			for i, val in enumerate(stable_group_tab[col]):
				all_difs.append(stable_group_tab[col][i] - star_id_means[i])
	std_all_stable = np.std(all_difs)
	
	
	
	return (mjd_bin, mjd_groups_obs_info_tab,mjd_groups,star_id_means,std_all_stable)
	

def make_plot_2(stable_group_tab, plot_output_dir, base_path,WD_mag_0,WD_tab,mjd_bin, mjd_groups_obs_info_tab,mjd_groups,star_id_means):

	obs_info_tab = base_path + '/obs_info.csv'
	obs_info_tab = ascii.read(obs_info_tab)
	plt.figure(figsize = (20,10))
	plt.rcParams['xtick.labelsize'] = 20
	plt.rcParams['ytick.labelsize'] = 20
	colors=cm.rainbow(np.linspace(0,1,len(stable_group_tab)))[::-1]

	for i, star_id in enumerate(stable_group_tab['star_id']):
		star_row = stable_group_tab[stable_group_tab['star_id'] == star_id]
		xs,ys,stds = [],[],[]
		for j, groupp in enumerate(mjd_groups):
			mjd_group = np.mean(groupp['mjd-obs-int'])
			fnames_group = groupp['ifile']
			star_row_mags_group =  [star_row['mag_'+ff][0]	for ff in fnames_group]
			star_row_errs_group =  [star_row['err_'+ff][0]	for ff in fnames_group]
			mean_star_row_mags_group = np.average(star_row_mags_group, weights = star_row_errs_group) - star_id_means[i]
			std_star_row_mags_group = np.std(star_row_mags_group)
			xs.append(mjd_group)
			ys.append(mean_star_row_mags_group)
			stds.append(std_star_row_mags_group)

		mjdss = np.array(xs)
		meanss = np.array(ys)
		stds = np.array(stds)

		plt.fill_between(mjdss, meanss-stds, meanss+stds,color=colors[i], alpha = 0.1)
		plt.plot(mjdss,meanss,color=colors[i],label = str(star_id))
		plt.legend(loc='best')
		
	for i, val in enumerate(mag_colnames):
		ff = val.replace('mag_','')
		WD_mjd = obs_info_tab['mjd-obs'][obs_info_tab['ifile']==ff][0]
		if WD_tab[val] != 99.9999:
			WD_mag = WD_tab[val] - WD_mag_0
			err = WD_tab[val.replace('mag','err')][0]
			if i == 0:
				plt.scatter(WD_mjd,WD_mag,s = 155, marker = 'x', c='k', zorder = 3, label = targname)
			else:
				plt.scatter(WD_mjd,WD_mag,s = 155, marker = 'x', c='k', zorder = 3, label = None)
	plt.legend(loc='best')
	plt.title(targname,fontsize = 30)
	plt.grid(ls=':')
	print 'saving ' + plot_output_dir+targname+'_plot2.pdf'
	plt.savefig(plot_output_dir+targname+'_plot2.pdf',dpi = 800, format = 'pdf')
	#plt.show()
	
def make_plot_3(stable_group_tab, plot_output_dir, base_path,WD_mag_0,WD_tab,mjd_bin, \
				mjd_groups_obs_info_tab,mjd_groups,star_id_means,std_all_stable,WD_std,err_in_mean_squared ):

	obs_info_tab = base_path + '/obs_info.csv'
	obs_info_tab = ascii.read(obs_info_tab)
	plt.figure(figsize = (20,10))
	mjd_all_stars = []
	mean_all_stars = []
	std_all_stars = []
	for j, groupp in enumerate(mjd_groups):
	
		mjd_group = np.mean(groupp['mjd-obs-int'])
		mjd_all_stars.append(mjd_group)
		fnames_group = groupp['ifile']
		mean_all_stars_mjd = []
		std_all_stars_mjd = []
	
		for i, star_id in enumerate(stable_group_tab['star_id']):
			star_row = stable_group_tab[stable_group_tab['star_id'] == star_id]
			star_row_mags_group =  [star_row['mag_'+ff][0]	for ff in fnames_group]
			star_row_mags_errs_group = [star_row['err_'+ff][0]	for ff in fnames_group]
			unweighted_mean = np.mean(star_row_mags_group) - star_id_means[i]
			mean_star_row_mags_group = np.average(star_row_mags_group, weights = star_row_mags_errs_group) - star_id_means[i]
			std_star_row_mags_group = np.std(star_row_mags_group)
			mean_all_stars_mjd.append(mean_star_row_mags_group)
			std_all_stars_mjd.append(std_star_row_mags_group)
		

		mean_all_stars.append(np.mean(mean_all_stars_mjd))
		std_all_stars.append(np.std(mean_all_stars_mjd)) 
	
	comparison_star_label = r'stable comparison stars ({} $<$ var. index $<$ {}), $\sigma$ = {}'.\
				 format(str(min(stable_group_tab['var_index'])),\
						str(max(stable_group_tab['var_index'])),\
				 str(round(std_all_stable,4)))	
	
	WD_label =	r'{}, var. index = {}, $\sigma$	 = {}'.format(targname,str(WD_tab['var_index'][0]),\
																		   str(np.round(WD_std,4)))
	
	mjd_all_stars = np.array(mjd_all_stars)
	mean_all_stars = np.array(mean_all_stars)
	std_all_stars = np.array(std_all_stars)

	plt.fill_between(mjd_all_stars, mean_all_stars-std_all_stars, mean_all_stars+std_all_stars,color='r', alpha = 0.1)
	plt.plot(mjd_all_stars,mean_all_stars,color='r', label = comparison_star_label)

	for i, val in enumerate(mag_colnames):
		ff = val.replace('mag_','')
		err = val.replace('mag_','err_')
		WD_mjd = obs_info_tab['mjd-obs'][obs_info_tab['ifile']==ff][0]
		WD_mag = WD_tab[val] - WD_mag_0
		WD_err = np.sqrt(WD_tab[err]**2. + err_in_mean_squared)
		
		#print WD_mjd, WD_tab[val], err
		if i == 0:
			plt.errorbar(WD_mjd, WD_mag, yerr = WD_err, label = None, c= 'k')
			plt.scatter(WD_mjd,WD_mag,s = 155, marker = 'x', c='k', zorder =3, label = WD_label)
		else:
			plt.errorbar(WD_mjd, WD_mag, yerr = WD_err, label = None, c= 'k')
			plt.scatter(WD_mjd,WD_mag,s = 155, marker = 'x', c='k', zorder = 3, label = None)
			
		
	plt.legend(loc='best', fontsize = 20)
	#plt.title(targname,fontsize = 30)
	plt.xlabel('MJD',fontsize = 30)
	plt.ylabel(r'$\Delta$ mag', fontsize = 30)
	plt.ylim(-0.1,0.07)
	print 'saving ' + plot_output_dir+targname+'_plot3.pdf'
	#plt.savefig(plot_output_dir+targname+'_plot3.pdf',dpi = 800, format = 'pdf')
	plt.savefig('/Users/cshanahan/Desktop/'+targname+'_plot3.pdf',dpi = 800, format = 'pdf')
	#plt.show()

def make_plot_4(stable_group_tab, plot_output_dir, base_path,WD_mag_0,WD_tab,mjd_bin, \
				mjd_groups_obs_info_tab,mjd_groups,star_id_means,std_all_stable,WD_std, \
				comparison_star_label,WD_label):
	obs_info_tab = base_path + '/obs_info.csv'
	obs_info_tab = ascii.read(obs_info_tab)
	
	#plot without binning WD
	plt.figure(figsize = (20,10))
	mjd_all_stars = []
	mean_all_stars = []
	std_all_stars = []

	for j, groupp in enumerate(mjd_groups):
	
		mjd_group = np.mean(groupp['mjd-obs-int'])
		mjd_all_stars.append(mjd_group)
		fnames_group = groupp['ifile']
		mean_all_stars_mjd = []
		std_all_stars_mjd = []
	
		for i, star_id in enumerate(stable_group_tab['star_id']):
			star_row = stable_group_tab[stable_group_tab['star_id'] == star_id]
			star_row_mags_group =  [star_row['mag_'+ff][0]	for ff in fnames_group]
			star_row_mags_errs_group = [star_row['err_'+ff][0]	for ff in fnames_group]
			unweighted_mean = np.mean(star_row_mags_group) - star_id_means[i]
			mean_star_row_mags_group = np.average(star_row_mags_group, weights = star_row_mags_errs_group) - star_id_means[i]
			std_star_row_mags_group = np.std(star_row_mags_group)
			mean_all_stars_mjd.append(mean_star_row_mags_group)
			std_all_stars_mjd.append(std_star_row_mags_group)
		

		mean_all_stars.append(np.mean(mean_all_stars_mjd))
		std_all_stars.append(np.std(mean_all_stars_mjd)) 
	
	mjd_all_stars = np.array(mjd_all_stars)
	mean_all_stars = np.array(mean_all_stars)
	std_all_stars = np.array(std_all_stars)

	plt.errorbar(mjd_all_stars, mean_all_stars, yerr = std_all_stars ,color='r', marker = 'o',\
				 capsize = 5, ls = 'none', label = comparison_star_label)

	for i, val in enumerate(mag_colnames):
		ff = val.replace('mag_','')
		WD_mjd = obs_info_tab['mjd-obs'][obs_info_tab['ifile']==ff][0]
		WD_mag = WD_tab[val] - WD_mag_0
		#print WD_mjd, WD_tab[val], err
		if i == 0:
			plt.scatter(WD_mjd,WD_mag,s = 155, marker = 'x', c='k', zorder =3, label = WD_label)
		else:
			plt.scatter(WD_mjd,WD_mag,s = 155, marker = 'x', c='k', zorder = 3, label = None)
		
	plt.legend(loc='best', fontsize = 20)
	plt.title(targname,fontsize = 30)
	plt.xlabel('MJD',fontsize = 30)
	plt.ylabel(r'$\Delta$ mag', fontsize = 30)
	print 'saving ' + plot_output_dir+targname+'_plot4.pdf'
	plt.savefig(plot_output_dir+targname+'_plot4.pdf',dpi = 800, format = 'pdf')
	#plt.show()
	
def make_plot_5(stable_group_tab, plot_output_dir, base_path,WD_mag_0,WD_tab,mjd_bin, \
				mjd_groups_obs_info_tab,mjd_groups,star_id_means,std_all_stable,WD_std, \
				comparison_star_label,WD_label):
				
	obs_info_tab = base_path + '/obs_info.csv'
	obs_info_tab = ascii.read(obs_info_tab)

	plt.figure(figsize = (20,10))
	mjd_all_stars = []
	mean_all_stars = []
	std_all_stars = []

	for j, groupp in enumerate(mjd_groups):
	
		mjd_group = np.mean(groupp['mjd-obs-int'])
		mjd_all_stars.append(mjd_group)
		fnames_group = groupp['ifile']
		mean_all_stars_mjd = []
		std_all_stars_mjd = []
	
		for i, star_id in enumerate(stable_group_tab['star_id']):
			star_row = stable_group_tab[stable_group_tab['star_id'] == star_id]
			star_row_mags_group =  [star_row['mag_'+ff][0]	for ff in fnames_group]
			star_row_mags_errs_group = [star_row['err_'+ff][0]	for ff in fnames_group]
			unweighted_mean = np.mean(star_row_mags_group) - star_id_means[i]
			mean_star_row_mags_group = np.average(star_row_mags_group, weights = star_row_mags_errs_group) - star_id_means[i]
			std_star_row_mags_group = np.std(star_row_mags_group)
			mean_all_stars_mjd.append(mean_star_row_mags_group)
			std_all_stars_mjd.append(std_star_row_mags_group)
		mean_all_stars.append(np.mean(mean_all_stars_mjd))
		std_all_stars.append(np.std(mean_all_stars_mjd)) 
	
	mjd_all_stars = np.array(mjd_all_stars)
	mean_all_stars = np.array(mean_all_stars)
	std_all_stars = np.array(std_all_stars)

	plt.errorbar(mjd_all_stars, mean_all_stars, yerr = std_all_stars ,color='r', marker = 'o',\
				 capsize = 5, ls = 'none',\
				 label = comparison_star_label)

	mjdss, meanss,stdss = [],[],[]
	for j, groupp in enumerate(mjd_groups):
		mjd_group = np.mean(groupp['mjd-obs-int'])
		fnames_group = groupp['ifile']
		WD_row_mags_group =	 [WD_tab['mag_'+ff][0]	for ff in fnames_group]
		WD_row_errs_group =	 [WD_tab['mag_'+ff][0]	for ff in fnames_group]
		mean_WD_row_mags_group = np.average(WD_row_mags_group, weights = WD_row_errs_group) - WD_weighted_mean_mag
		std_WD_row_mags_group = np.std(WD_row_mags_group)
		mjdss.append(mjd_group)
		meanss.append(mean_WD_row_mags_group)
		stdss.append(std_WD_row_mags_group)

	plt.errorbar(mjdss, meanss, yerr = stdss ,color='k', marker = 'o',\
				 capsize = 5, ls = 'none',\
				 label = WD_label)
		
	plt.legend(loc='best', fontsize = 20)
	plt.title(targname,fontsize = 30)
	plt.xlabel('MJD',fontsize = 30)
	plt.ylabel(r'$\Delta$ mag', fontsize = 30)
	
	print 'saving ' + plot_output_dir+targname+'_plot5.pdf'
	plt.savefig(plot_output_dir+'{}_plot5.pdf'.format(targname))
	
def make_plot_6(stable_group_tab, plot_output_dir, base_path,WD_mag_0,WD_tab,mjd_bin, \
				mjd_groups_obs_info_tab,mjd_groups,star_id_means,std_all_stable,WD_std, \
				comparison_star_label,WD_label):
				
				
	obs_info_tab = base_path + '/obs_info.csv'
	obs_info_tab = ascii.read(obs_info_tab)
	plt.figure(figsize = (20,10))
	mjd_all_stars = []
	mean_all_stars = []
	std_all_stars = []

	for j, groupp in enumerate(mjd_groups):
	
		mjd_group = np.mean(groupp['mjd-obs-int'])
		mjd_all_stars.append(mjd_group)
		fnames_group = groupp['ifile']
		mean_all_stars_mjd = []
		std_all_stars_mjd = []
	
		for i, star_id in enumerate(stable_group_tab['star_id']):
			star_row = stable_group_tab[stable_group_tab['star_id'] == star_id]
			star_row_mags_group =  [star_row['mag_'+ff][0]	for ff in fnames_group]
			star_row_mags_errs_group = [star_row['err_'+ff][0]	for ff in fnames_group]
			unweighted_mean = np.mean(star_row_mags_group) - star_id_means[i]
			mean_star_row_mags_group = np.average(star_row_mags_group, weights = star_row_mags_errs_group) - star_id_means[i]
			std_star_row_mags_group = np.std(star_row_mags_group)
			mean_all_stars_mjd.append(mean_star_row_mags_group)
			std_all_stars_mjd.append(std_star_row_mags_group)
		mean_all_stars.append(np.mean(mean_all_stars_mjd))
		std_all_stars.append(np.std(mean_all_stars_mjd)) 
	
	mjd_all_stars = np.array(mjd_all_stars)
	mean_all_stars = np.array(mean_all_stars)
	std_all_stars = np.array(std_all_stars)


	plt.errorbar(mjd_all_stars, mean_all_stars, yerr = std_all_stars ,color='r', marker = 'o',\
				 capsize = 5, ls = 'none',\
				 label = comparison_star_label)

	mjdss, meanss,stdss = [],[],[]
	for j, groupp in enumerate(mjd_groups):
		mjd_group = np.mean(groupp['mjd-obs-int'])
		fnames_group = groupp['ifile']
		WD_row_mags_group =	 [WD_tab['mag_'+ff][0] for ff in fnames_group if WD_tab['mag_'+ff][0] != 99.9999]
		WD_row_errs_group =	 [WD_tab['mag_'+ff][0] for ff in fnames_group if WD_tab['err_'+ff][0] != 9.9999]
		if len(WD_row_errs_group) >0:
			mean_WD_row_mags_group = np.average(WD_row_mags_group, weights = WD_row_errs_group) - WD_weighted_mean_mag
			std_WD_row_mags_group = np.std(WD_row_mags_group)
			mjdss.append(mjd_group)
			meanss.append(mean_WD_row_mags_group)
			stdss.append(std_WD_row_mags_group)

	plt.errorbar(mjdss, meanss, yerr = stdss ,color='k', marker = 'o',\
				 capsize = 5, ls = 'none',\
				 label = WD_label)

	for i, val in enumerate(mag_colnames):
		ff = val.replace('mag_','')
		WD_mjd = obs_info_tab['mjd-obs'][obs_info_tab['ifile']==ff][0]
		if WD_tab[val] != 99.9999:
			WD_mag = WD_tab[val] - WD_weighted_mean_mag
			plt.scatter(WD_mjd,WD_mag,s = 155, marker = 'x', c='k', label = None, alpha = 0.5)
		
	plt.legend(loc='best', fontsize = 20)
	plt.title(targname,fontsize = 30)
	plt.xlabel('MJD',fontsize = 30)
	plt.ylabel(r'$\Delta$ mag', fontsize = 30)
	print 'saving ' + plot_output_dir+targname+'_plot6.pdf'
	plt.savefig(plot_output_dir+'{}_plot6.pdf'.format(targname))
	#plt.show()
	
def make_plot_7_8(stable_group_tab, plot_output_dir, base_path,WD_mag_0,WD_tab,mjd_bin, \
				mjd_groups_obs_info_tab,mjd_groups,star_id_means,std_all_stable,WD_std, \
				comparison_star_label,WD_label):
				
	obs_info_tab = base_path + '/obs_info.csv'
	obs_info_tab = ascii.read(obs_info_tab)
				
	plt.figure(figsize = (20,10))
	mjd_all_stars = []
	mean_all_stars = []
	std_all_stars = []
	

	for j, groupp in enumerate(mjd_groups):
	
		mjd_group = np.mean(groupp['mjd-obs-int'])
		mjd_all_stars.append(mjd_group)
		fnames_group = groupp['ifile']
		mean_all_stars_mjd = []
		std_all_stars_mjd = []
	
		for i, star_id in enumerate(stable_group_tab['star_id']):
			star_row = stable_group_tab[stable_group_tab['star_id'] == star_id]
			star_row_mags_group =  [star_row['mag_'+ff][0]	for ff in fnames_group]
			star_row_mags_errs_group = [star_row['err_'+ff][0]	for ff in fnames_group]
			unweighted_mean = np.mean(star_row_mags_group) - star_id_means[i]
			mean_star_row_mags_group = np.average(star_row_mags_group, weights = star_row_mags_errs_group) - star_id_means[i]
			std_star_row_mags_group = np.std(star_row_mags_group)
			mean_all_stars_mjd.append(mean_star_row_mags_group)
			std_all_stars_mjd.append(std_star_row_mags_group)
		mean_all_stars.append(np.mean(mean_all_stars_mjd))
		std_all_stars.append(np.std(mean_all_stars_mjd)) 
	
	mjd_all_stars = np.array(mjd_all_stars)
	mean_all_stars = np.array(mean_all_stars)
	std_all_stars = np.array(std_all_stars)

	plt.fill_between(mjd_all_stars, mean_all_stars-std_all_stars, mean_all_stars+std_all_stars,color='r', alpha = 0.1)
	plt.plot(mjd_all_stars,mean_all_stars,color='r', label = comparison_star_label)
	plt.scatter(mjd_all_stars,mean_all_stars,color='r')

	mjdss, meanss,stdss = [],[],[]
	for j, groupp in enumerate(mjd_groups):
		mjd_group = np.mean(groupp['mjd-obs-int'])
		fnames_group = groupp['ifile']
		WD_row_mags_group =	 [WD_tab['mag_'+ff][0] for ff in fnames_group if WD_tab['mag_'+ff][0] != 99.9999]
		WD_row_errs_group =	 [WD_tab['mag_'+ff][0] for ff in fnames_group if WD_tab['err_'+ff][0] != 9.9999]
		if len(WD_row_errs_group) >0:
			mean_WD_row_mags_group = np.average(WD_row_mags_group, weights = WD_row_errs_group) - WD_weighted_mean_mag
			std_WD_row_mags_group = np.std(WD_row_mags_group)
			mjdss.append(mjd_group)
			meanss.append(mean_WD_row_mags_group)
			stdss.append(std_WD_row_mags_group)
		
	stds = np.array(stdss)
	meanss = np.array(meanss)
	
	plt.fill_between(mjdss, meanss-stds, meanss+stds,color='k', alpha = 0.1)
	plt.scatter(mjdss,meanss,color='k')
	plt.plot(mjdss,meanss,color='k',label = r'{}, var. index = {}, $<$ $\sigma$ $>$ = {}'.format(targname,\
																		   str(WD_tab['var_index'][0]),\
																		   str(round(np.mean(stdss),4))))


		
	plt.legend(loc='best', fontsize = 20)
	plt.title(targname,fontsize = 30)
	plt.xlabel('MJD',fontsize = 30)
	plt.ylabel(r'$\Delta$ mag', fontsize = 30)
	print 'saving ', plot_output_dir+'{}_plot7.pdf'.format(targname)
	plt.savefig(plot_output_dir+'{}_plot7.pdf'.format(targname))
	for i, val in enumerate(mag_colnames):
		ff = val.replace('mag_','')
		WD_mjd = obs_info_tab['mjd-obs'][obs_info_tab['ifile']==ff][0]
		if WD_tab[val] != 99.9999:
			WD_mag = WD_tab[val] - WD_mag_0
			#print WD_mjd, WD_tab[val], err

			plt.scatter(WD_mjd,WD_mag,s = 155, marker = 'x', c='k', label = None, alpha = 0.5)
	print 'saving ', plot_output_dir+'{}_plot8.pdf'.format(targname)
	plt.savefig(plot_output_dir+'{}_plot8.pdf'.format(targname))


if __name__ == '__main__':
	
			 
	targs = ['SDSSJ022817.16-082716.4', 'SDSSJ235144.29+375542.6','WD0554-165']
	

	for targname in targs:	
		base_path = '/Users/cshanahan/Desktop/WD_project/redo_final_ver/23_targets/psf_phot/{}/'.format(targname)
		plot_output_dir = base_path + 'plots_and_output/'
		close_mag_tab = ascii.read(plot_output_dir + 'close_mag_tab.csv', format = 'csv')
		phot_output_tab = ascii.read(plot_output_dir + '{}_phot_output.txt'.format(targname), format = 'csv')
		stable_group_tab = ascii.read(plot_output_dir + 'stable_comparison_star_tab.csv', format = 'csv')
		WD_tab = ascii.read(plot_output_dir + 'WD_tab.csv', format = 'csv')
		filtered_mags = np.array([WD_tab[x] for x in WD_tab.colnames if 'mag_' in x and WD_tab[x] != 99.9999])
		filtered_errs = np.array([WD_tab[x] for x in WD_tab.colnames if 'err_' in x and WD_tab[x] != 9.9999])
		WD_mag_0 = np.mean(filtered_mags)
		WD_std_0 = np.std(filtered_mags-WD_mag_0)
		WD_weighted_mean_mag = np.average(filtered_mags,weights = filtered_errs)
		err_in_mean_squared = 0
		for err in filtered_errs:
			err_in_mean_squared += err**2.
		err_in_mean_squared = err_in_mean_squared / (len(filtered_errs)**2.)
		print 'err in mean squared', err_in_mean_squared
	
		stable_star_idx = 0
		stable_star_index = close_mag_tab[stable_star_idx]['star_id']
		stable_star_tab = phot_output_tab[phot_output_tab['star_id'] == stable_star_index]
		mag_colnames = [x for x in stable_star_tab.colnames if 'mag' in x]
		stable_star_mean_mag = np.mean([stable_star_tab[x] for x in mag_colnames])
	
		unstable_star_idx = -5
		unstable_star_index = close_mag_tab[unstable_star_idx]['star_id']
		unstable_star_tab = phot_output_tab[phot_output_tab['star_id'] == unstable_star_index]
		mag_colnames = [x for x in unstable_star_tab.colnames if 'mag' in x]
		unstable_star_mean_mag = np.mean([unstable_star_tab[x] for x in mag_colnames])


		#make_plot_0(base_path, phot_output_tab, plot_output_dir, stable_star_tab, unstable_star_tab, targname)
		#make_plot_1(targname,base_path,plot_output_dir,WD_tab,stable_star_tab,unstable_star_tab)
		mjd_bin, mjd_groups_obs_info_tab,mjd_groups,star_id_means,std_all_stable = make_mjd_groups(stable_group_tab, plot_output_dir, base_path)
		comparison_star_label = r'stable comparison stars ({} $<$ var. index $<$ {}), $\sigma$ = {}'.\
								format(str(min(stable_group_tab['var_index'])),\
								str(max(stable_group_tab['var_index'])),\
								str(round(std_all_stable,4)))
		WD_label =	r'{}, var. index = {}, $\sigma$	 = {}'.format(targname,str(WD_tab['var_index'][0]),str(np.round(WD_std_0,4)))
		#make_plot_2(stable_group_tab, plot_output_dir, base_path,WD_mag_0,WD_tab,mjd_bin, mjd_groups_obs_info_tab,mjd_groups,star_id_means)
		make_plot_3(stable_group_tab, plot_output_dir, base_path,WD_mag_0,WD_tab,mjd_bin, mjd_groups_obs_info_tab,mjd_groups,star_id_means,std_all_stable,WD_std_0,err_in_mean_squared )
		#make_plot_4(stable_group_tab, plot_output_dir, base_path,WD_mag_0,WD_tab,mjd_bin, mjd_groups_obs_info_tab,mjd_groups,star_id_means,std_all_stable,WD_std_0,comparison_star_label,WD_label)
		#make_plot_5(stable_group_tab, plot_output_dir, base_path,WD_mag_0,WD_tab,mjd_bin, mjd_groups_obs_info_tab,mjd_groups,star_id_means,std_all_stable,WD_std_0,comparison_star_label,WD_label)
		#make_plot_6(stable_group_tab, plot_output_dir, base_path,WD_mag_0,WD_tab,mjd_bin, mjd_groups_obs_info_tab,mjd_groups,star_id_means,std_all_stable,WD_std_0,comparison_star_label,WD_label)
		#make_plot_7_8(stable_group_tab, plot_output_dir, base_path,WD_mag_0,WD_tab,mjd_bin, mjd_groups_obs_info_tab,mjd_groups,star_id_means,std_all_stable,WD_std_0,comparison_star_label,WD_label)
