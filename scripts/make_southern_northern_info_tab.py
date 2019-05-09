from astropy.io import ascii
import glob
import numpy as np
import os


def write_stars_info_tab(output_file, data_dir):

    obj_dirs = glob.glob(data_dir + '*')

    print('Writing {}.'.format(output_file))
    with open(output_file, 'w') as f:
        f.write('targ, n_exp, mean_mag_weighted, std, WS_index, chi2\n')
        for obj_dir in obj_dirs:
            obj = os.path.basename(obj_dir).replace('/', '')

            wd_tab = ascii.read(obj_dir+'/plots_and_output/WD_tab.csv')
            ws_idx, ra_ref, dec_ref = wd_tab['var_index'][0], wd_tab['ra_ref'][0], wd_tab['dec_ref'][0]
            mag_colnames = [colname for colname in wd_tab.colnames if 'mag' in colname]
            err_colnames = [x.replace('mag','err') for x in mag_colnames]
            mags = np.array([wd_tab[mag_colname][0] for mag_colname in mag_colnames])
            errs = np.array([wd_tab[err_colname][0] for err_colname in err_colnames])
            mean_mag_weighted = np.average(mags, weights = errs)
            std_mags = np.std(mags)
            n_obs = len(mag_colnames)
            chisq_nu = np.sum((1/errs**2) * ((mags - mean_mag_weighted)**2))/(n_obs-1)
            
            f.write('{}, {}, {}, {}, {}, {}\n'.format(obj, n_obs, np.round(mean_mag_weighted,2), np.round(std_mags,2), ws_idx, np.round(chisq_nu,2)))



if __name__ == '__main__':

    northern_star_data_dir = '/Users/cshanahan/Desktop/clean_desktop/WD_project/redo_final_ver/23_northern_targets/psf_phot/'
    northern_star_output_tab = '/Users/cshanahan/Desktop/clean_desktop/WD_project/output_for_paper/23_northern/northern_targ_info.csv'
    write_stars_info_tab(northern_star_output_tab, northern_star_data_dir)

    southern_star_data_dir = '/Users/cshanahan/Desktop/clean_desktop/WD_project/redo_final_ver/15_southern_targs/psf_phot/'
    southern_star_output_tab = '/Users/cshanahan/Desktop/clean_desktop/WD_project/output_for_paper/15_southern/southern_targ_info.csv'