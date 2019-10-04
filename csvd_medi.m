% QSM Pipeline
%
% Adopted by Kyle Murray

% Add MEDI toolbox to MATLAB search path
addpath('/path/to/MEDI_toolbox')

% Set MEDI functions to path
MEDI_set_path();

% Load DICOMS
[iField,voxel_size,matrix_size,CF,delta_TE,TE,B0_dir]=Read_DICOM('dicoms');

% CSVD protocol has equal TE spacing
[iFreq_raw N_std] = Fit_ppm_complex(iField);

% Created Magnitude map
iMag = 1./N_std; iMag(isnan(iMag)|isinf(iMag))=0;

% Unwrap Phase
iFreq = unwrapPhase(iMag, iFreq_raw, matrix_size);

%%%%%%%%% SPURS Method using Graph Cuts %%%%%%%%%%%%%
% iFreq = unwrapping_gc(iFreq_raw,iMag,voxel_size);

% Brain Extraction using FSLs bet
Mask = BET(iMag,matrix_size,voxel_size);

% Create RDF
RDF = PDF(iFreq, N_std, Mask,matrix_size,voxel_size, B0_dir);

%%%%%%%% Laplacian Boundary Value Method %%%%%%%%
% RDF = LBV(iFreq,Mask,matrix_size,voxel_size,0.005);

% Create R2* Map
R2s = arlo(TE, abs(iField));

% Mask CSF
Mask_CSF = extract_CSF(R2s, Mask, voxel_size);

% Create results directory
mkdir results;

% Save all variables to RDF.mat
save RDF.mat RDF iFreq iFreq_raw iMag N_std Mask matrix_size...
voxel_size delta_TE CF B0_dir Mask_CSF;

% Perform MEDI using L1 normalization with corrections
QSM = MEDI_L1('lambda',1000,'lambda_CSF',100,'smv',5,'merit');

% Save Results as DICOMS
write_QSM_dir(QSM,'dicoms','QSM_DICOM');

% Save R2* results as DICOMS
[iField,voxel_size,matrix_size,CF,delta_TE,TE,B0_dir,files]=Read_DICOM('dicoms');
opts=struct;
opts.SeriesDescription = 'R2*';
opts.SeriesNumber = 100;
opts.Window = 100;
opts.Level = 50;

Write_DICOM(R2s,files,'R2star',opts);

exit
