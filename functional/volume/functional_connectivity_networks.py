import numpy as np
import scipy as sp
import nibabel as nib
import scipy.io as sio
from nilearn import datasets
from nilearn.input_data import NiftiLabelsMasker
from nilearn.connectome import ConnectivityMeasure

# Load residual functional images in MNI152-2mm space
func = nib.load('mni_func_residual.nii.gz')
glob = nib.load('mni_func_residual_global.nii.gz')

# Load the Destrieux and Desikan atlases
destrieux = datasets.fetch_atlas_destrieux_2009()
destrieux_atlas = destrieux.maps
destrieux_labels = destrieux.labels

desikan = datasets.fetch_atlas_harvard_oxford(atlas_name='cort-maxprob-thr25-2mm')
desikan_atlas = desikan.maps
desikan_labels = desikan.labels

# Create time series
destrieux_masker_func = NiftiLabelsMasker(labels_img=destrieux_atlas, standardize=True)
destrieux_masker_glob = NiftiLabelsMasker(labels_img=destrieux_atlas, standardize=True)
desikan_masker_func = NiftiLabelsMasker(labels_img=desikan_atlas, standardize=True)
desikan_masker_glob = NiftiLabelsMasker(labels_img=desikan_atlas, standardize=True)

destrieux_func_time_series = destrieux_masker_func.fit_transform(func)
destrieux_glob_time_series = destrieux_masker_glob.fit_transform(glob)
desikan_func_time_series = desikan_masker_func.fit_transform(func)
desikan_glob_time_series = desikan_masker_glob.fit_transform(glob)

# Create networks via Pearson Correlation
destrieux_func_correlation_measure = ConnectivityMeasure(kind='correlation')
destrieux_glob_correlation_measure = ConnectivityMeasure(kind='correlation')
desikan_func_correlation_measure = ConnectivityMeasure(kind='correlation')
desikan_glob_correlation_measure = ConnectivityMeasure(kind='correlation')

destrieux_func_correlation_matrix = destrieux_func_correlation_measure.fit_transform([destrieux_func_time_series])[0]
destrieux_glob_correlation_matrix = destrieux_glob_correlation_measure.fit_transform([destrieux_glob_time_series])[0]
desikan_func_correlation_matrix = desikan_func_correlation_measure.fit_transform([desikan_func_time_series])[0]
desikan_glob_correlation_matrix = desikan_glob_correlation_measure.fit_transform([desikan_glob_time_series])[0]

np.fill_diagonal(destrieux_func_correlation_matrix, 0)
np.fill_diagonal(destrieux_glob_correlation_matrix, 0)
np.fill_diagonal(desikan_func_correlation_matrix, 0)
np.fill_diagonal(desikan_glob_correlation_matrix, 0)

# Save network matrices

sio.savemat('destrieux_func_cm_pearson.mat', {'cm' : destrieux_func_correlation_matrix})
sio.savemat('destrieux_global_cm_pearson.mat', {'cm' : destrieux_glob_correlation_matrix})
sio.savemat('desikan_func_cm_pearson.mat', {'cm' : desikan_func_correlation_matrix})
sio.savemat('desikan_global_cm_pearson.mat', {'cm' : desikan_glob_correlation_matrix})
