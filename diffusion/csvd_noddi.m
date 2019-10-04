% NODDI Pipeline
%
% Created by Kyle Murray
%
% This follows the tutorial of NODDI Toolbox with one subject
% This takes eddy corrected 4D data as input
% Inside subject NODDI folder files must be named as follows...
%   eddy_corrected_data = NODDI_DWI.nii
%   bvals = NODDI_protocol.bval
%   bvecs = NODDI_protocol.bvec
%   brain_extracted_mask = brain_mask.nii
%
   
% Add NODDI toolbox to MATLAB search path
addpath(genpath('/path/to/NODDI_toolbox'));

CreateROI('NODDI_DWI.nii','brain_mask.nii','NODDI_roi.mat');

protocol = FSL2Protocol('NODDI_protocol.bval','NODDI_protocol.bvec');

noddi = MakeModel('WatsonSHStickTortIsoV_B0');

batch_fitting_single('NODDI_roi.mat', protocol, noddi, 'FittedParams.mat');

SaveParamsAsNIfTI('FittedParams.mat', 'NODDI_roi.mat', 'brain_mask.nii', 'NODDI_out')
