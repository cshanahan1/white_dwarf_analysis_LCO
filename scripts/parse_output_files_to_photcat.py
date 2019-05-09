from astropy.wcs import WCS
import numpy as np
import os

def parse_output_files_to_photcat(targname, ref_file_path, mch_file_path, cor_file_path, mag_file_path, output_path):

    #wcs info from original file
    wcs_ref = WCS(ref_file_path)

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

        col_names = ['star_id','var_index','chi2_nu','x_ref','y_ref','ra_ref','dec_ref','chi','sharp'] + ['mag_' + os.path.basename(x).replace('.ap','').replace('.als','') for x in mch_file_names] + ['err_' + os.path.basename(x).replace('.als','') for x in mch_file_names]
        ix = np.arange(0,len(lines),ix_max)
        for i in range(0,len(ix)-1):
            if True:
                block = lines[ix[i]:ix[i+1]]
                block = ' '.join(block).strip('\n').split()

                star_ids.append(str(i))
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
                #other variabilty index
                
                filtered_mags = np.array([float(x) for x in star_magss[k] if x != '99.9999'])
                filtered_errs = np.array([float(x) for x in star_mag_errss[k] if x != '9.9999'])

                mean_mag_weighted = np.average(filtered_mags, weights = filtered_errs)
                chi2_nu = np.sum((1/filtered_errs**2) * ((filtered_mags - mean_mag_weighted)**2))/(len(filtered_mags)-1)
                
                ff.write('{0},{1},{2},{3},{4},{5},{6},{7},{8},'.format(star_ids[k],var_indicies[k],str(chi2_nu),star_xs[k],star_ys[k],star_ras[k],stars_dec[k],star_chis[k],star_sharps[k]))
                ff.write(','.join(star_magss[k]))
                ff.write(','+','.join(star_mag_errss[k])+'\n')
