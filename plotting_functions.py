from astropy.wcs import WCS
import numpy as np
import os

def parse_output_files(targname, ref_file_path, mch_file_path,cor_file_path,mag_file_path,output_path):
    #wcs info from original file 
    wcs_ref = WCS(ref_file_path)
    #print wcs_ref
    mch_file_names = []
    with open(mch_file_path,'r') as f:
        mch_lines = f.readlines()
        
    with open(mag_file_path,'r') as f:
        mag_lines = f.readlines()[3:]
        
    var_indicies = []
    for l in mag_lines:
        var_indicies.append(l.split()[9])
        
    for l in mch_lines:
        mch_file_names.append(l.split()[0].replace('.alf','').replace("'",""))

    with open(cor_file_path,'r') as f:
        lines = f.readlines()[3:]
        n_new_lines = [l.split() for l in lines]
        len_lines = np.array([len(l) for l in n_new_lines])
        thresh = max(len_lines)
        n_new = 0
        for l in len_lines:
            if l >= thresh:
                n_new += 1
        ix_max = len(lines)/n_new
                
        star_ids = []
        star_xs = []
        star_ys = []
        star_chis = []
        star_sharps = []
        star_magss = []
        star_mag_errss = []
            
        col_names = ['star_id','var_index','x_ref','y_ref','ra_ref','dec_ref','chi','sharp'] + ['mag_' + os.path.basename(x).replace('.ap','').replace('.als','') for x in mch_file_names] + ['err_' + os.path.basename(x).replace('.als','') for x in mch_file_names]
        ix = np.arange(0,len(lines),ix_max)
        for i in range(0,len(ix)-1):
            if True:
                block = lines[ix[i]:ix[i+1]]
                block = ' '.join(block).strip('\n').split()

                star_ids.append(block[0])
                star_xs.append(block[1])
                star_ys.append(block[2])
                star_chis.append(block[-2])
                star_sharps.append(block[-1])
                star_magss.append(block[3:-2][::2])
                star_mag_errss.append(block[3:-2][1::2])
        star_ras, stars_dec = wcs_ref.all_pix2world(np.array(star_xs).astype(float),np.array(star_ys).astype(float),1)
        
        with open(output_path+'{}_phot_output.txt'.format(targname),'w') as ff:
            print 'writing ' + output_path+'{}_phot_output.txt'.format(targname)
            for col in col_names:
                ff.write(col+',')   
            ff.write('\n')
            for k, val in enumerate(star_magss):
                ff.write('{0},{1},{2},{3},{4},{5},{6},{7},'.format(star_ids[k],var_indicies[k],star_xs[k],star_ys[k],star_ras[k],stars_dec[k],star_chis[k],star_sharps[k]))
                ff.write(','.join(star_magss[k]))
                ff.write(','+','.join(star_mag_errss[k])+'\n')

## plot with binning WD
# plt.figure(figsize = (20,10))
# mjd_all_stars = []
# mean_all_stars = []
# std_all_stars = []
# 
# for j, groupp in enumerate(mjd_groups):
#     
#     mjd_group = np.mean(groupp['mjd-obs-int'])
#     mjd_all_stars.append(mjd_group)
#     fnames_group = groupp['ifile']
#     mean_all_stars_mjd = []
#     std_all_stars_mjd = []
#     
#     for i, star_id in enumerate(stable_group_tab['star_id']):
#         star_row = stable_group_tab[stable_group_tab['star_id'] == star_id]
#         star_row_mags_group =  [star_row['mag_'+ff][0]  for ff in fnames_group]
#         star_row_mags_errs_group = [star_row['err_'+ff][0]  for ff in fnames_group]
#         mean_star_row_mags_group = np.average(star_row_mags_group, weights = star_row_mags_errs_group) - star_id_weighted_means[i]
#         std_star_row_mags_group = np.std(star_row_mags_group)
#         mean_all_stars_mjd.append(mean_star_row_mags_group)
#         std_all_stars_mjd.append(std_star_row_mags_group)
#     mean_all_stars.append(np.mean(mean_all_stars_mjd))
#     std_all_stars.append(np.std(mean_all_stars_mjd)) 
#     
# mjd_all_stars = np.array(mjd_all_stars)
# mean_all_stars = np.array(mean_all_stars)
# std_all_stars = np.array(std_all_stars)
# 
# plt.fill_between(mjd_all_stars, mean_all_stars-std_all_stars, mean_all_stars+std_all_stars,color='r', alpha = 0.1)
# plt.plot(mjd_all_stars,mean_all_stars,color='r', label = r'stable comparison stars ({} $<$ var. index $<$ {})'.format(str(min(stable_group_tab['var_index'])),str(max(stable_group_tab['var_index']))))
# plt.scatter(mjd_all_stars,mean_all_stars,color='r')
# 
# mjdss, meanss,stdss = [],[],[]
# for j, groupp in enumerate(mjd_groups):
#     mjd_group = np.mean(groupp['mjd-obs-int'])
#     fnames_group = groupp['ifile']
#     WD_row_mags_group =  [WD_tab['mag_'+ff][0]  for ff in fnames_group]
#     mean_WD_row_mags_group = np.mean(WD_row_mags_group) - WD_mag_0
#     std_WD_row_mags_group = np.std(WD_row_mags_group)
#     mjdss.append(mjd_group)
#     meanss.append(mean_WD_row_mags_group)
#     stdss.append(std_WD_row_mags_group)
#     
# plt.fill_between(mjdss, meanss-stds, meanss+stds,color='k', alpha = 0.1)
# plt.scatter(mjdss,meanss,color='k',label = r'{}, var. index = {}'.format(targname, str(match_obj['var_index'][0])))
# plt.plot(mjdss,meanss,color='k')
#         
# plt.legend(loc='best', fontsize = 20)
# plt.title(targname,fontsize = 30)
# plt.xlabel('MJD',fontsize = 30)
# plt.ylabel(r'$\Delta$ mag', fontsize = 30)
# plt.savefig(plot_output_dir+'{}_averaged_binned.png'.format(targname))
# plt.show()
