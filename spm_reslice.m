function spm_reslice(P,flags)
% Rigid body reslicing of images
% FORMAT spm_reslice(P,flags)
%
% P     - matrix of filenames {one string per row}
%         All operations are performed relative to the first image.
%         ie. Coregistration is to the first image, and resampling
%         of images is into the space of the first image.
%
% flags    - a structure containing various options.  The fields are:
%
%         mask - mask output images (1 for yes, 0 for no)
%                To avoid artifactual movement-related variance the realigned
%                set of images can be internally masked, within the set (i.e.
%                if any image has a zero value at a voxel than all images have
%                zero values at that voxel).  Zero values occur when regions
%                'outside' the image are moved 'inside' the image during
%                realignment.
%
%         mean - write mean image (1 for yes, 0 for no)
%                The average of all the realigned scans is written to
%                mean*.img.
%
%         hold - the interpolation method (see spm_slice_vol or spm_sample_vol).
%                Non-finite values result in Fourier interpolation.  Note that
%                Fourier interpolation only works for purely rigid body
%                transformations.  Voxel sizes must all be identical and
%                isotropic.
%
%         which - Values of 0, 1 or 2 are allowed.
%                0   - don't create any resliced images.
%                      Useful if you only want a mean resliced image.
%                1   - don't reslice the first image.
%                      The first image is not actually moved, so it may not be
%                      necessary to resample it.
%                2   - reslice all the images.
%
%         fudge - adjust the data (fMRI) to remove movement-related components.
%                 This is enabled when the fudge field exists in the flags
%                 structure.  See help from spm_realign_ui for details.
%
%             The spatially realigned images are written to the orginal
%             subdirectory with the same filename but prefixed with an 'r'.
%             They are all aligned with the first.
%__________________________________________________________________________
%
% Inputs
% A series of *.img conforming to SPM data format (see 'Data Format').  The 
% relative displacement of the images is stored in their ".mat" files.
%
% Outputs
% The routine uses information in these ".mat" files and writes the
% realigned *.img files to the same subdirectory prefixed with an 'r'
% (i.e. r*.img).
%__________________________________________________________________________
%
% The `.mat' files.
%
% This simply contains a 4x4 affine transformation matrix in a variable `M'.
% These files are normally generated by the `realignment' and
% `coregistration' modules.  What these matrixes contain is a mapping from
% the voxel coordinates (x0,y0,z0) (where the first voxel is at coordinate
% (1,1,1)), to coordinates in millimeters (x1,y1,z1).  By default, the
% the new coordinate system is derived from the `origin' and `vox' fields
% of the image header.
%  
% x1 = M(1,1)*x0 + M(1,2)*y0 + M(1,3)*z0 + M(1,4)
% y1 = M(2,1)*x0 + M(2,2)*y0 + M(2,3)*z0 + M(2,4)
% z1 = M(3,1)*x0 + M(3,2)*y0 + M(3,3)*z0 + M(3,4)
%
% Assuming that image1 has a transformation matrix M1, and image2 has a
% transformation matrix M2, the mapping from image1 to image2 is: M2\M1
% (ie. from the coordinate system of image1 into millimeters, followed
% by a mapping from millimeters into the space of image2).
%
% These `.mat' files allow several realignment or coregistration steps to be
% combined into a single operation (without the necessity of resampling the
% images several times).  The `.mat' files are also used by the spatial
% normalisation module.
%__________________________________________________________________________
% Refs:
%
% Friston KJ, Williams SR, Howard R Frackowiak RSJ and Turner R (1995)
% Movement-related effect in fMRI time-series.  Mag. Res. Med. 35:346-355
%
% W. F. Eddy, M. Fitzgerald and D. C. Noll (1996) Improved Image
% Registration by Using Fourier Interpolation. Mag. Res. Med. 36(6):923-931
%
% R. W. Cox and A. Jesmanowicz (1999)  Real-Time 3D Image Registration
% for Functional MRI.  Submitted to MRM (April 1999) and avaliable from:
% http://varda.biophysics.mcw.edu/~cox/index.html.
%
%__________________________________________________________________________
% %W% John Ashburner %E%

P = spm_vol(P);

def_flags = struct('hold',-9,'mask',1,'mean',1,'which',2);
if nargin < 2,
	flags = def_flags;
else,
	fnms = fieldnames(def_flags);
	for i=1:length(fnms),
		if ~isfield(flags,fnms{i}),
			flags = setfield(flags,fnms{i},getfield(def_flags,fnms{i}));
		end;
	end;
end;

if flags.which == 0 & isfield(flags,'fudge'), flags = rmfield(flags,'fudge'); end;
if ~finite(flags.hold) | ~isfield(flags,'fudge'),
	if isfield(flags,'fudge'), warning('No adjustment will be done'); end;
	if iscell(P), P = cat(1,P{:}); end;
	reslice_images_volbyvol(P,flags);
else,
	if iscell(P),
		sessions=zeros(length(P),1);
		for i=1:length(P),
			sessions(i) = length(P{i});
		end;
		sessions = cumsum(sessions);
		P = cat(1,P{:});
	else,
		sessions = length(P);
	end;
	reslice_adjust(P,flags,sessions);
end;
return;
%_______________________________________________________________________

%_______________________________________________________________________
function reslice_images_volbyvol(P,flags)
% Reslices images volume by volume
% FORMAT reslice_images_volbyvol(P,flags)
%
% P        - matrix of image handles from spm_vol.
%            All operations are performed relative to the first image.
%            ie. resampling of images is into the space of the first image.
%
% flags    - a structure containing various options.  The fields are:
%
%         mask - mask output images (1 for yes, 0 for no)
%                To avoid artifactual movement-related variance the realigned
%                set of images can be internally masked, within the set (i.e.
%                if any image has a zero value at a voxel than all images have
%                zero values at that voxel).  Zero values occur when regions
%                'outside' the image are moved 'inside' the image during
%                realignment.
%
%         mean - write mean image
%                The average of all the realigned scans is written to
%                mean*.img.
%
%         hold - the interpolation method (see spm_slice_vol or spm_sample_vol).
%                Non-finite values result in Fourier interpolation
%
%         which - Values of 0, 1 or 2 are allowed.
%                0   - don't create any resliced images.
%                      Useful if you only want a mean resliced image.
%                1   - don't reslice the first image.
%                      The first image is not actually moved, so it may not be
%                      necessary to resample it.
%                2   - reslice all the images.
%
%             The spatially realigned images are written to the orginal
%             subdirectory with the same filename but prefixed with an 'r'.
%             They are all aligned with the first.

if ~finite(flags.hold), % Use Fourier method
	% Check for non-rigid transformations in the matrixes
	for i=1:prod(size(P)),
		pp = P(1).mat\P(i).mat;
		if any(abs(svd(pp(1:3,1:3))-1)>1e-7),
			fprintf('\n  Zooms  or shears  appear to  be needed');
			fprintf('\n  (probably due to non-isotropic voxels).');
			fprintf('\n  These  can not yet be  done  using  the');
			fprintf('\n  Fourier reslicing method.  Switching to');
			fprintf('\n  sinc interpolation instead.\n\n');
			flags.hold = -9;
			break;
		end;
	end;
end;

linfun = inline('fprintf(''%-60s%s'', x,sprintf(''\b'')*ones(1,60))');

if flags.mask | flags.mean,
	linfun('Computing mask..');
	spm_progress_bar('Init',P(1).dim(3),'Computing available voxels','planes completed');
	x1    = repmat((1:P(1).dim(1))',1,P(1).dim(2));
	x2    = repmat( 1:P(1).dim(2)  ,P(1).dim(1),1);
	if flags.mean,
		Count    = zeros(P(1).dim(1:3));
		Integral = zeros(P(1).dim(1:3));
	end;
	if flags.mask, msk = cell(P(1).dim(3),1);  end;
	for x3 = 1:P(1).dim(3),
		tmp = zeros(P(1).dim(1:2));
		for i = 1:prod(size(P)),
			tmp = tmp + getmask(inv(P(1).mat\P(i).mat),x1,x2,x3,P(i).dim(1:3));
		end;
		if flags.mask, msk{x3} = find(tmp ~= prod(size(P))); end;
		if flags.mean, Count(:,:,x3) = tmp; end;
		spm_progress_bar('Set',x3);
	end;
end;

linfun('Reslicing images..');
nread = prod(size(P));
if ~flags.mean,
	if flags.which == 1, nread = nread - 1; end;
	if flags.which == 0, nread = 0; end;
end;
spm_progress_bar('Init',nread,'Reslicing','volumes completed');

tiny = 5e-2; % From spm_vol_utils.c

PO = P;
nread = 0;
for i = 1:prod(size(P)),

	if (i>1 & flags.which==1) | flags.which==2, write_vol = 1; else, write_vol = 0; end;
	if write_vol | flags.mean,                   read_vol = 1; else   read_vol = 0; end;

	if read_vol,
		linfun(['Reslicing volume ' num2str(i) '..']);
		PO(i).fname   = prepend(P(i).fname,'r');
		PO(i).dim     = [P(1).dim(1:3) P(i).dim(4)];
		PO(i).mat     = P(1).mat;
		PO(i).descrip = 'spm - realigned';

		if ~finite(flags.hold),
			v = abs(kspace3d(loadvol(P(i)),P(1).mat\P(i).mat));
			for x3 = 1:P(1).dim(3),
				if flags.mean,
					Integral(:,:,x3) = Integral(:,:,x3) + ...
						v(:,:,x3).*getmask(inv(P(1).mat\P(i).mat),x1,x2,x3,P(i).dim(1:3));
				end;
				if flags.mask, tmp = v(:,:,x3); tmp(msk{x3}) = NaN; v(:,:,x3) = tmp; end;
			end;
			if write_vol, spm_write_vol(PO(i),v); end;
		else,
			if write_vol, spm_create_image(PO(i)); end;
			for x3 = 1:P(1).dim(3),
				M = inv(spm_matrix([0 0 -x3 0 0 0 1 1 1])*inv(P(1).mat)*P(i).mat);
				v = spm_slice_vol(P(i),M,P(1).dim(1:2),flags.hold);
				if flags.mean, Integral(:,:,x3) = Integral(:,:,x3) + v; end;

				if write_vol,
					if flags.mask, v(msk{x3}) = NaN; end;
					spm_write_plane(PO(i),v,x3);
				end;
			end;
		end;
		nread = nread + 1;
	end;
	spm_progress_bar('Set',nread);
end;

if flags.mean
	% Write integral image (16 bit signed)
	%-----------------------------------------------------------
	Integral   = Integral./Count;
	PO         = P(1);
	PO.fname   = prepend(P(1).fname, 'mean');
	PO.pinfo   = [max(max(max(Integral)))/32767 0 0]';
	PO.descrip = 'spm - mean image';
	PO.dim(4)  = 4;
	spm_write_vol(PO,Integral);
end

spm_figure('Clear','Interactive');
return;
%_______________________________________________________________________

%_______________________________________________________________________
function v = kspace3d(v,M)
% 3D rigid body transformation performed as shears in 1D Fourier space.
% FORMAT v1 = kspace3d(v,M)
% Inputs:
% v - the image stored as a 3D array.
% M - the rigid body transformation matrix.
% Output:
% v - the transformed image.
%
% The routine is based on the excellent papers:
% R. W. Cox and A. Jesmanowicz (1999)
% Real-Time 3D Image Registration for Functional MRI
% Submitted to MRM (April 1999) and avaliable from:
% http://varda.biophysics.mcw.edu/~cox/index.html.
% and:
% W. F. Eddy, M. Fitzgerald and D. C. Noll (1996)
% Improved Image Registration by Using Fourier Interpolation
% Magnetic Resonance in Medicine 36(6):923-931
%_______________________________________________________________________

[S0,S1,S2,S3] = shear_decomp(M);

d  = [size(v) 1 1 1];
g = 2.^ceil(log2(d));
if any(g~=d),
	tmp = v;
	v   = zeros(g);
	v(1:d(1),1:d(2),1:d(3)) = tmp;
	clear tmp;
end;

% XY-shear
tmp1 = -sqrt(-1)*2*pi*([0:((g(3)-1)/2) 0 (-g(3)/2+1):-1])/g(3);
for j=1:g(2),
	t        = reshape( exp((j*S3(3,2) + S3(3,1)*(1:g(1)) + S3(3,4)).'*tmp1) ,[g(1) 1 g(3)]);
	v(:,j,:) = real(ifft(fft(v(:,j,:),[],3).*t,[],3));
end;

% XZ-shear
tmp1 = -sqrt(-1)*2*pi*([0:((g(2)-1)/2) 0 (-g(2)/2+1):-1])/g(2);
for k=1:g(3),
	t        = exp( (k*S2(2,3) + S2(2,1)*(1:g(1)) + S2(2,4)).'*tmp1);
	v(:,:,k) = real(ifft(fft(v(:,:,k),[],2).*t,[],2));
end;

% YZ-shear
tmp1 = -sqrt(-1)*2*pi*([0:((g(1)-1)/2) 0 (-g(1)/2+1):-1])/g(1);
for k=1:g(3),
	t        = exp( tmp1.'*(k*S1(1,3) + S1(1,2)*(1:g(2)) + S1(1,4)));
	v(:,:,k) = real(ifft(fft(v(:,:,k),[],1).*t,[],1));
end;

% XY-shear
tmp1 = -sqrt(-1)*2*pi*([0:((g(3)-1)/2) 0 (-g(3)/2+1):-1])/g(3);
for j=1:g(2),
	t        = reshape( exp( (j*S0(3,2) + S0(3,1)*(1:g(1)) + S0(3,4)).'*tmp1) ,[g(1) 1 g(3)]);
	v(:,j,:) = real(ifft(fft(v(:,j,:),[],3).*t,[],3));
end;

if any(g~=d), v = v(1:d(1),1:d(2),1:d(3)); end;
return;
%_______________________________________________________________________

%_______________________________________________________________________
function [S0,S1,S2,S3] = shear_decomp(A)
% Decompose rotation and translation matrix A into shears S0, S1, S2 and
% S3, such that A = S0*S1*S2*S3.  The original procedure is documented
% in:
% R. W. Cox and A. Jesmanowicz (1999)
% Real-Time 3D Image Registration for Functional MRI

A0 = A(1:3,1:3);
if any(abs(svd(A0)-1)>1e-7), error('Can''t decompose matrix'); end;


t  = A0(2,3); if t==0, t=eps; end;
a0 = pinv(A0([1 2],[2 3])')*[(A0(3,2)-(A0(2,2)-1)/t) (A0(3,3)-1)]';
S0 = [1 0 0; 0 1 0; a0(1) a0(2) 1];
A1 = S0\A0;  a1 = pinv(A1([2 3],[2 3])')*A1(1,[2 3])';  S1 = [1 a1(1) a1(2); 0 1 0; 0 0 1];
A2 = S1\A1;  a2 = pinv(A2([1 3],[1 3])')*A2(2,[1 3])';  S2 = [1 0 0; a2(1) 1 a2(2); 0 0 1];
A3 = S2\A2;  a3 = pinv(A3([1 2],[1 2])')*A3(3,[1 2])';  S3 = [1 0 0; 0 1 0; a3(1) a3(2) 1];

s3 = A(3,4)-a0(1)*A(1,4)-a0(2)*A(2,4);
s1 = A(1,4)-a1(1)*A(2,4);
s2 = A(2,4);
S0 = [[S0 [0  0 s3]'];[0 0 0 1]];
S1 = [[S1 [s1 0  0]'];[0 0 0 1]];
S2 = [[S2 [0 s2  0]'];[0 0 0 1]];
S3 = [[S3 [0  0  0]'];[0 0 0 1]];
return;
%_______________________________________________________________________

%_______________________________________________________________________
function Mask = getmask(M,x1,x2,x3,dim)
tiny = 5e-2; % From spm_vol_utils.c
y1=M(1,1)*x1+M(1,2)*x2+(M(1,3)*x3+M(1,4));
y2=M(2,1)*x1+M(2,2)*x2+(M(2,3)*x3+M(2,4));
y3=M(3,1)*x1+M(3,2)*x2+(M(3,3)*x3+M(3,4));
Mask =        (y1 >= (1-tiny) & y1 <= (dim(1)+tiny));
Mask = Mask & (y2 >= (1-tiny) & y2 <= (dim(2)+tiny));
Mask = Mask & (y3 >= (1-tiny) & y3 <= (dim(3)+tiny));
return;
%_______________________________________________________________________

%_______________________________________________________________________
function v = loadvol(V)
v = zeros(V.dim(1:3));
for i=1:V.dim(3),
	v(:,:,i) = spm_slice_vol(V,spm_matrix([0 0 i]),V.dim(1:2),0);
end;
return;
%_______________________________________________________________________
%_______________________________________________________________________












%_______________________________________________________________________
%_______________________________________________________________________
function reslice_adjust(P,flags,sessions)
% Reslices images volume by volume
% FORMAT reslice_images_volbyvol(P,flags)
% P        - matrix of image handles from spm_vol.
%            All operations are performed relative to the first image.
%            ie. resampling of images is into the space of the first image.
%
% flags    - a structure containing various options.  The fields are:
%
%         mask - mask output images (1 for yes, 0 for no)
%                To avoid artifactual movement-related variance the realigned
%                set of images can be internally masked, within the set (i.e.
%                if any image has a zero value at a voxel than all images have
%                zero values at that voxel).  Zero values occur when regions
%                'outside' the image are moved 'inside' the image during
%                realignment.
%
%         mean - write mean image
%                The average of all the realigned scans is written to
%                mean*.img.
%
%         hold - the interpolation method (see spm_slice_vol or spm_sample_vol).
%                Non-finite values result in Fourier interpolation
%
%         which - Values of 0, 1 or 2 are allowed.
%                0   - don't create any resliced images.
%                      Useful if you only want a mean resliced image.
%                1   - don't reslice the first image.
%                      The first image is not actually moved, so it may not be
%                      necessary to resample it.
%                2   - reslice all the images.
%
%             The spatially realigned images are written to the orginal
%             subdirectory with the same filename but prefixed with an 'r'.
%             They are all aligned with the first.
%
% sessions - the last scan in each of the sessions.  For example,
%            the images in the second session would be
%            P((sessions(2-1)+1):sessions(2),:).
%
% The only reason for reslicing a series plane by plane is to do the adjustment.

linfun = inline('fprintf(''%-60s%s'', x,sprintf(''\b'')*ones(1,60))');
linfun('Reslicing images..');

start_vol = 1;
if flags.which == 1, start_vol = 2; end

% Write headers and matrixes
%------------------------------------------------------------------
PO = P;
for i = start_vol:prod(size(P)),
	PO(i).fname   = prepend(P(i).fname,'r');
	PO(i).dim     = [P(1).dim(1:3) P(i).dim(4)];
	PO(i).mat     = P(1).mat;
	PO(i).descrip = 'spm - realigned';
	spm_create_image(PO(i));
end;

spm_progress_bar('Init',P(1).dim(3),'Reslicing','planes completed');

if flags.mean,
	Integral = zeros(P(1).dim(1)*P(1).dim(2),P(1).dim(3));
end;

tiny = 5e-2; % From spm_vol_utils.c

linfun('Estimating a priori covariance matrix..');
Y1 = zeros(prod(P(1).dim(1:2)),prod(size(P)));
Y2 = zeros(prod(P(1).dim(1:2)),prod(size(P)));
Y3 = zeros(prod(P(1).dim(1:2)),prod(size(P)));

% Estimate a priori covariance matrix describing the distribution of
% the basis functions for the adjustment.
gl = spm_global(P(1));
varerr = 0;
npix   = 0;
for x3 = 1:P(1).dim(3),
	tmp = spm_slice_vol(P(1),spm_matrix([0 0 x3]),P(1).dim(1:2),0);
	msk = find(tmp > gl*0.8);
	tmp = reshape(interp_errors(tmp,flags.hold),prod(P(1).dim(1:2)),4);
	varerr = varerr + sum(sum(tmp(msk,:).^2));
	npix = npix + prod(size(msk));
end;
varerr = varerr/npix;
IC0  = eye(6)/varerr;

X  = zeros(prod(P(1).dim(1:2)),prod(size(P)));


x1=repmat((1:P(1).dim(1))',1,P(1).dim(2));x1=x1(:);
x2=repmat( 1:P(1).dim(2)  ,P(1).dim(1),1);x2=x2(:);

for x3 = 1:P(1).dim(3)
	linfun(['Reslicing plane ' num2str(x3) '..']);
	Count = zeros(prod(P(1).dim(1:2)),1);
	for i = 1:prod(size(P))
		M = inv(P(1).mat\P(i).mat);
		y1=M(1,1)*x1+M(1,2)*x2+(M(1,3)*x3+M(1,4));
		y2=M(2,1)*x1+M(2,2)*x2+(M(2,3)*x3+M(2,4));
		y3=M(3,1)*x1+M(3,2)*x2+(M(3,3)*x3+M(3,4));

		Mask =        (y1 >= (1-tiny) & y1 <= (P(i).dim(1)+tiny));
		Mask = Mask & (y2 >= (1-tiny) & y2 <= (P(i).dim(2)+tiny));
		Mask = Mask & (y3 >= (1-tiny) & y3 <= (P(i).dim(3)+tiny));
		Count = Count + Mask;

		X(:,i) = spm_sample_vol(P(i),y1,y2,y3,flags.hold);

		if isfield(flags,'fudge'),
			Y1(:,i)=y1;
			Y2(:,i)=y2;
			Y3(:,i)=y3;
		end;
	end;
	Mask = (Count == prod(size(P)));

	ss = 1;
	for s = 1:length(sessions),
		se = sessions(s);
		degrf = se-ss+1-7;

		for xx=find(Mask)',
			% Basis functions appropriate for sinc interpolation
			A = [cos(2*pi*Y1(xx,ss:se)') sin(2*pi*Y1(xx,ss:se)') ...
			     cos(2*pi*Y2(xx,ss:se)') sin(2*pi*Y2(xx,ss:se)') ...
			     cos(2*pi*Y3(xx,ss:se)') sin(2*pi*Y3(xx,ss:se)')];

			Tac   = X(xx,ss:se)';
			% centre the signal and covariates
			Tac   = Tac - mean(Tac);
			A     = A - repmat(mean(A,1),size(A,1),1);
			alpha = A'*A;
			beta  = A'*Tac;

			% Estimate the distribution of the errors.
			sumsq = sum((Tac - A*(pinv(alpha)*beta)).^2)/degrf;

			% Subtract a MAP estimate of the interpolation errors
			% from the data.
			Tac   = X(xx,ss:se)' - A*((alpha + IC0*sumsq)\beta);
			X(xx,ss:se) = Tac';
		end
		ss = se+1;
	end;


	if flags.mean,
		Integral(:,x3) = sum(X,2)./Count;
	end;

	if flags.mask, notmsk = find(~Mask); else, notmsk=[]; end;

	for i = start_vol:prod(size(P)),
		tmp = reshape(X(:,i),PO(i).dim(1:2));
		tmp(notmsk) = NaN;
		spm_write_plane(PO(i),tmp,x3);
	end;
	spm_progress_bar('Set',x3);
end;


if flags.mean,
	% Write integral image (16 bit signed)
	%-----------------------------------------------------------
	PO         = P(1);
	PO.fname   = prepend(P(1).fname, 'mean');
	PO.pinfo   = [max(max(Integral))/32767 0 0]';
	PO.descrip = 'spm - mean image';
	PO.dim(4)  = 4;
	spm_write_vol(PO,reshape(Integral,PO.dim(1:3)));
end;

spm_figure('Clear','Interactive');
return;
%_______________________________________________________________________

%_______________________________________________________________________
function A = interp_errors(img,Hold)
fimg = fft2(img);
t1 = 0.5;
t2 = 0.25;
A = zeros([size(img) 4]);
A(:,:,1) = interp_errors_sub1(fimg,[0 t1],Hold)-img;
A(:,:,2) = interp_errors_sub1(fimg,[0 t2],Hold)-img;
A(:,:,3) = interp_errors_sub1(fimg,[t1 0],Hold)-img;
A(:,:,4) = interp_errors_sub1(fimg,[t2 0],Hold)-img;
M = inv([1-cos(t1*2*pi) 1-cos(t2*2*pi); sin(t1*2*pi) sin(t2*2*pi)]);
M = [M zeros(2); zeros(2) M];
A = reshape(reshape(A,[prod(size(img)) 4])*M,[size(img) 4]);
return;
%_______________________________________________________________________

%_______________________________________________________________________
function img2 = interp_errors_sub1(fimg,t,Hold)
d    = size(fimg);
tr   = t(2);
if tr ~= 0,
	c    = fftshift(exp(sqrt(-1)*2*pi*tr*((-d(1)/2):((d(1)-1)/2))/d(1)))';
	fimg = fimg.*repmat(c,1,d(2));
end;
tr   = -t(1);
if tr ~= 0,
	c    = fftshift(exp(sqrt(-1)*2*pi*tr*((-d(2)/2):((d(2)-1)/2))/d(2)));
	fimg = fimg.*repmat(c,d(1),1);
end;
img1 = real(ifft2(fimg));
img2 = spm_slice_vol(img1,spm_matrix([t(2) t(1) 1]),size(img1),Hold);
return;
%_______________________________________________________________________

%_______________________________________________________________________
function PO = prepend(PI,pre)
[pth,nm,xt,vr] = fileparts(deblank(PI));
PO             = fullfile(pth,[pre nm xt vr]);
return;
%_______________________________________________________________________

