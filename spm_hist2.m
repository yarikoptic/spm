% Create 2D scatter-plot of two images after affine transformation
% FORMAT H = spm_hist2(G,F,M,s)
% G  - unsigned 8 bit 3D array representing the first volume
% F  - unsigned 8 bit 3D array representing the second volume
% M  - the affine transformation matrix so that G(x) is plotted
%      against F(x)
% s  - 3 element vector representing the sampling density.
%      A value of [1 1 1] means that all voxels are sampled,
%      whereas [4 4 4] means that only 1 in 64 voxels are
%      sampled.
%
% This function is called by spm_mireg for rapidly computing
% scatterplots for mutual information image registration.
%
% Interpolation is dealt with as described in:
% A Collignon, F Maes, D Delaere, D Vandermeulen, P Suetens & G Marchal
% (1995) "Automated Multi-modality Image Registration Based On
% Information Theory". In the proceedings of Information Processing in
% Medical Imaging (1995).  Y. Bizais et al. (eds.).  Kluwer Academic
% Publishers.
%_______________________________________________________________________
% %W% John Ashburner %E%
