import numpy as np
import dipy.reconst.dki as dki
import dipy.reconst.dti as dti
import dipy.reconst.dki_micro as dki_micro
from dipy.data import fetch_cfin_multib
from dipy.data import read_cfin_dwi
from dipy.segment.mask import median_otsu
from scipy.ndimage.filters import gaussian_filter

import nibabel as nib

from dipy.io.image import load_nifti, save_nifti
from dipy.io import read_bvals_bvecs
from dipy.core.gradients import gradient_table
from dipy.reconst.dti import TensorModel

fdwi = 'dwidata.nii.gz'
fbval = 'bvals'
fbvec = 'bvecs'
mask = load_nifti('mask.nii.gz')

data, affine = load_nifti(fdwi)
bvals, bvecs = read_bvals_bvecs(fbval, fbvec)
gtab = gradient_table(bvals, bvecs)

tenmodel = TensorModel(gtab)
tenfit = tenmodel.fit(data)

fwhm = 1.25
gauss_std = fwhm / np.sqrt(8 * np.log(2))  # converting fwhm to Gaussian std
data_smooth = np.zeros(data.shape)
for v in range(data.shape[-1]):
    data_smooth[..., v] = gaussian_filter(data[..., v], sigma=gauss_std)

dkimodel = dki.DiffusionKurtosisModel(gtab)

dkifit = dkimodel.fit(data_smooth, mask=mask[0])

FA = dkifit.fa
MD = dkifit.md
AD = dkifit.ad
RD = dkifit.rd

MK = dkifit.mk(0, 3)
AK = dkifit.ak(0, 3)
RK = dkifit.rk(0, 3)

dti_FA = tenfit.fa
dti_MD = tenfit.md
dti_AD = tenfit.ad
dti_RD = tenfit.rd

save_nifti('dki_FA.nii.gz', FA, affine)
save_nifti('dki_MD.nii.gz', MD, affine)
save_nifti('dki_AD.nii.gz', AD, affine)
save_nifti('dki_RD.nii.gz', RD, affine)
save_nifti('dki_MK.nii.gz', MK, affine)
save_nifti('dki_AK.nii.gz', AK, affine)
save_nifti('dki_RK.nii.gz', RK, affine)

save_nifti('dti_FA.nii.gz', dti_FA, affine)
save_nifti('dti_MD.nii.gz', dti_MD, affine)
save_nifti('dti_AD.nii.gz', dti_AD, affine)
save_nifti('dti_RD.nii.gz', dti_RD, affine)
