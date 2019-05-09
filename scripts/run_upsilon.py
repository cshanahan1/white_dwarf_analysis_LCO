from astropy.io import ascii
import glob
import numpy as np
import upsilon
import os


def make_lightcurve(targname, input_dir, output_dir):
    obs_info_tab = ascii.read(input_dir+'/obs_info.csv')
    wd_phot_tab = ascii.read(input_dir+'/plots_and_output/WD_tab.csv')
    wd_mag_cols = [x for x in wd_phot_tab.colnames if 'mag' in x]
    lightcurve_path = output_dir + '{}_lightcurve.dat'.format(targname)
    print('Writing {}.'.format(lightcurve_path))
    with open(lightcurve_path,'w') as f:
        f.write('#mjd, mag, mag_err\n')
    for mag_col in wd_mag_cols:
        fname = mag_col.replace('mag_','')
        mjd = obs_info_tab[obs_info_tab['ifile'] == fname]['mjd-obs'][0]
        mag = wd_phot_tab[mag_col][0]
        err = wd_phot_tab[mag_col.replace('mag','err')][0]
        with open(lightcurve_path,'a') as f:
            f.write('{},{},{}\n'.format(mjd,mag,err))
            
for f in glob.glob('/Users/cshanahan/Desktop/white_dwarf_analysis_LCO/processed_data/23_northern_targets/psf_phot/*'):
    targname = f.split('/')[-1]
    input_dir = f
    output_dir = '/Users/cshanahan/Desktop/white_dwarf_analysis_LCO/output_for_paper/23_northern/upsilon/'
    make_lightcurve(targname, input_dir, output_dir)

 WD_lightcurves = glob.glob('/Users/cshanahan/Desktop/white_dwarf_analysis_LCO/output_for_paper/23_northern/upsilon/*lightcurve*')

 with open('/Users/cshanahan/Desktop/white_dwarf_analysis_LCO/output_for_paper/23_northern/upsilon/upsilon_classification.dat', 'w') as f:
    f.write('#target, label, flag, probability, period\n')
    
for i, WD_lightcurve in enumerate(WD_lightcurves):

    WD_lightcurve_tab = ascii.read(WD_lightcurve)
    obj = os.path.basename(WD_lightcurve).replace('_lightcurve.dat','')
    mags = WD_lightcurve_tab['mag']
    errs = WD_lightcurve_tab['mag_err']
    mjds = WD_lightcurve_tab['mjd']
    # load a classification model
    rf_model = upsilon.load_rf_model()

    # extract features
    e_features = upsilon.ExtractFeatures(mjds, mags, errs)
    e_features.run()
    features = e_features.get_features()

    # classify the light curve
    label, probability, flag = upsilon.predict(rf_model, features)
    
    with open('/Users/cshanahan/Desktop/white_dwarf_analysis_LCO/output_for_paper/23_northern/upsilon/upsilon_classification.dat', 'a') as f:
        f.write('{}, {} ,{} ,{}, {}\n'.format(obj, label, flag, probability, features['period']))