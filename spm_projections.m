function [t,XYZ] = spm_projections(t,XYZ,u,k,V,W,S,G,C,df)
% display and analysis of SPM{Z} [SPM{t}]
% FORMAT [Z,XYZ] = spm_projections(Z,XYZ,u,k,V,W,S,G,C,df);
%
% Z   - row vector of {n} voxel values
% XYZ - {3 x n} matrix of spatial locations {mm}
% u   - height threshold (uncorrected)
% k   - extent threshold (uncorrected)
% V   - vector of image and voxel sizes (see spm_map.m)
% W   - vector of smoothness estimates (one element for each dimension)
% S   - Lebesgue measure or volume of search space
% G   - design matrix for the experiment
% C   - row vector contrast for the SPM{Z}
% df  - degrees of freedom due to error
%
% Z & XYZ - filtered according to threshold criteria
%___________________________________________________________________________
%
% spm_projections applies a threshold {u} to a point list of voxel values {Z}
% (specified with their locations {XYZ}) and characterizes the resulting
% excursion set as a collection of face, edge and vertex connected subsets
% or clusters.  The significance of the results are based on set, cluster
% and voxel-level inferences using distributional approximations from the
% Theory of Gaussian Feilds.  These distributions assume that the SPM is
% a reasonable lattice approximation to a Gaussian field of smoothness
% {W = FWHM/sqrt(8.ln2)}
%
% The p values are based on the probability of obtaining c, or more,
% clusters of k, or more, voxels above u, in the volume S analysed =
% P(u,k,c).  For specified thresholds u, k, the set-level inference is
% based on the observed number of clusters C = P(u,k,C).  For each cluster
% of size K the cluster-level inference is based on P(u,K,1) and for each
% voxel (or selected maxima) of height U, in that cluster, the voxel-level
% inference is based on P(U,0,1).  All three levels of inference are
% supported with a tabular presentation of the p values and the underlying
% statistic (u, k or c).  The table is grouped by regions and sorted on
% the Z value of the primary maxima.  See 'Sections' in the help facility
% and spm_maxima.m for a more complete characterization of maxima within
% a region.
%
% If several contrasts are specified, only voxels surviving the height
% threshold u are considered further.  The mean of the component Z values
% (for each contrast) is corrected for the number of, and correlations
% among, the correpsonding compounds to give a new Z statistic.
%
% The secondary maxima are selected to be at least 8mm apart.
%
%__________________________________________________________________________
% %W% Karl Friston %E%

global CWD

%-If called with output arguments (i.e. from spm_projections_ui.m)
% *and* global proj_MultiPage is true then allow multi-page tables.
%---------------------------------------------------------------------------
global proj_MultiPage, if isempty(proj_MultiPage), proj_MultiPage=0; end
if (nargout & proj_MultiPage), bMultiPage=1; else, bMultiPage=0; end


%-Display, characterize and print SPM{t}
%===========================================================================
Fgraph = spm_figure('FindWin','Graphics');
figure(Fgraph)
spm_clf
set(Fgraph,'Units','Normalized');

%-Apply height threshold {u}
%---------------------------------------------------------------------------
if size(C,1) > 1
	Q = all(t > u);

	g = C*pinv(G'*G)*C';
	r = inv(diag(sqrt(diag(g))))'*g*inv(diag(sqrt(diag(g))));
	t = sum(t(:,Q))/sqrt(sum(r(:)));
else
	Q = t > u;
	t = t(1,Q);
end
XYZ       = XYZ(:,Q);

%-Return if there are no voxels
%---------------------------------------------------------------------------
if sum(Q) == 0
	axis off
	text(0,0.8,spm('DirTrunc',CWD));
	text(0,0.7,'No voxels above this threshold {u}','FontSize',16);
	return
end

%-Apply extent threshold {k}
%---------------------------------------------------------------------------
A     = spm_clusters(XYZ,V([4 5 6]));
Q     = [];
for i = 1:max(A)
	j = find(A == i);
	if length(j) >= k
		Q = [Q j];
	end
end

t     = t(Q);
XYZ   = XYZ(:,Q);

%-Return if there are no voxels
%---------------------------------------------------------------------------
if sum(Q) == 0
	axis off
	text(0,0.8,spm('DirTrunc',CWD));
	text(0,0.7,'No clusters above this threshold {k}','FontSize',16);
	return
end

%-Maximium intenisty projection of SPM{Z}
%===========================================================================
axes('Position',[0.05 0.5 0.5 0.5],'Tag','Empty');
spm_mip(t,XYZ,V(1:6)); axis image
title('SPM{Z}','FontSize',16,'Fontweight','Bold')

%-Show design matrix & contrast
%===========================================================================
axes('Position',[0.65 0.6 0.2 0.2],'Tag','Empty')
imagesc(spm_DesMtxSca(G))
xlabel 'design matrix'
axes('Position',[0.65 0.8 0.2 0.1],'Tag','Empty')
bar(C'); hold on
[i j]   = bar(C(1,:));
fill(i,j,[1 1 1]*.8);
set(gca,'Xlim',[min(i) max(i)]) 
title 'contrast'; axis off; hold off

%-Display (sorted on Z values and grouped by regions)
%===========================================================================

%-Characterize excursion set in terms of maxima 
%---------------------------------------------------------------------------
[N Z M A] = spm_max(t,XYZ,V([4 5 6]));


%-Table headings
%---------------------------------------------------------------------------
y   = 25;
axes('Position',[0.1 0.06 0.8 0.46],'Tag','Empty'); axis off
text(0,y,['P values & statistics:   ' spm('DirTrunc',CWD,40)],...
	'FontSize',12,'FontWeight','Bold');
y   = y - 1;
line([0 1],[y y],'LineWidth',3,'Color',[0 0 0])
y   = y - 1;

%-Construct tables
%---------------------------------------------------------------------------
text(0.00,y,'set-level {c}'      ,'FontSize',10,'Tag','Empty');
text(0.18,y,'cluster-level {k,Z}','FontSize',10,'Tag','Empty');
text(0.42,y,'voxel-level {Z}'    ,'FontSize',10,'Tag','Empty');
text(0.64,y,'uncorrected'        ,'FontSize',10,'Tag','Empty');
text(0.84,y,'location {mm}'      ,'FontSize',10,'Tag','Empty');
y  = y - 1;

line([0 1],[y y],'LineWidth',3,'Color',[0 0 0])
y  = y - 1;

%-Set-level p values {c}
%-----------------------------------------------------------------------
c      = max(A);				% number of clusters
Pc     = spm_P(c,W,u,k,S);			% set-level p value

%-Pagination variables
%-----------------------------------------------------------------------
y0 = y;
hPage = [];
nPage = 1;
Vis = 'on';

%-Print set-level p-value
%-----------------------------------------------------------------------
str    = sprintf('%-0.3f   (%i)',Pc,c);
h = text(0.00,y,str,'FontSize',8,'FontWeight','Bold','Visible',Vis);
hPage = [hPage, h];


while max(Z) & ((y > 2) | bMultiPage)
	% Paginate if necessary
	%-------------------------------------------------------
	if (y < 6) & proj_MultiPage
		h = text(0.5,-2,['Page ',num2str(nPage)],...
			'FontSize',8,'FontAngle','Italic',...
			'Visible',Vis);
		hPage = [hPage, h];
		spm_figure('NewPage',hPage)
		hPage = [];
		nPage = nPage + 1;
		Vis   = 'off';
		y = y0;
	end

    	%-Find largest remaining local maximum
    	%---------------------------------------------------------------
	[U i] = max(Z);				% largest Z value
	j     = find(A == A(i));		% maxima in cluster

    	%-Compute cluster {k} and voxel-level p values for this cluster
    	%---------------------------------------------------------------
	Pkn   = spm_Pkn(N(i),U-u,W,u,S);	% Bivariate cluster-height p
%	Pk    = spm_P(1,W,u,N(i),S);		% cluster-level p value
	Pu    = spm_P(1,W,U,0,S);		% voxel-level p value
	Pz    = 1 - spm_Ncdf(U);		% uncorrected p value

        if N(i) < k; break; end

	%-Print cluster and maximum voxel-level p values {Z}
    	%---------------------------------------------------------------
        str   = sprintf('%-0.3f   (%i, %0.2f)',Pkn,N(i),U);
	h = text(0.18,y,str,'FontSize',8,'FontWeight','Bold','Visible',Vis);
	hPage = [hPage, h];
        str   = sprintf('%-0.3f   (%-0.2f)',Pu,U);
	h = text(0.44,y,str,'FontSize',8,'FontWeight','Bold','Visible',Vis);
	hPage = [hPage, h];
        str   = sprintf('%-0.3f',Pz);
	h = text(0.68,y,str,'FontSize',8,'FontWeight','Bold','Visible',Vis);
	hPage = [hPage, h];
        str   = sprintf('%-6.0f',M(:,i));
	h = text(0.84,y,str,'FontSize',8,'FontWeight','Bold','Visible',Vis);
	hPage = [hPage, h];
 
	y     = y - 1;

	%-Print 2 secondary maxima (> 8mm apart)
    	%---------------------------------------------------------------
	[l q] = sort(-Z(j));				% sort on Z value
	D     = i;
	for i = 1:length(q)
		d    = j(q(i));
		if min(sqrt(sum((M(:,D) - M(:,d)*ones(1,size(D,2))).^2))) > 8;
		    if length(D) < 3
			
			% voxel-level p values {Z}
			%-----------------------------------------------
			Pu  = spm_P(1,W,Z(d),0,S);	% voxel-level p value
			Pz  = 1 - spm_Ncdf(Z(d));	% uncorrected p value

        		str = sprintf('%-0.3f   (%-0.2f)',Pu,Z(d));
			h = text(0.44,y,str,'FontSize',8,'Visible',Vis);
			hPage = [hPage, h];
        		str = sprintf('%-0.3f',Pz);
			h = text(0.68,y,str,'FontSize',8,'Visible',Vis);
			hPage = [hPage, h];
        		str = sprintf('%-6.0f',M(:,d));
			h = text(0.84,y,str,'FontSize',8,'Visible',Vis);
			hPage = [hPage, h];
			D   = [D d];
			y   = y - 1;
		    end
		end
	end
	Z(j) = Z(j)*0;			% Zero local maxima for this cluster
end					% end region

%-Number and paginate last page (if pagination was required)
if strcmp(Vis,'off')
	%-Label last page
	h = text(0.5,-2,['Page ',num2str(nPage)],...
		'FontSize',8,'FontAngle','Italic',...
		'Visible',Vis);
	hPage = [hPage, h];
	spm_figure('NewPage',hPage);
end

y = min(3,y);

if size(C,1) > 1
	str = 'NB multiple contrasts - use voxel-level inferences';
	text(0,y,str,'Color',[1 0 0])
	y = y - 1;
end


%-Volume, resels and smoothness 
%=======================================================================
D               = length(W);					% dimension
FWHM            = sqrt(8*log(2))*W.*V(([1:D] + 3),1)'; 		% FWHM {mm}
RESEL           = S*prod(V([1:D] + 3))/prod(FWHM);		% RESELS
[P,EN,Em,En,Pk] = spm_P(1,W,u,k,S);


%-Footnote with SPM parameters
%-----------------------------------------------------------------------
y  = y + 0.5;
line([0 1],[y y],'LineWidth',1,'Color',[0 0 0])
y  = y - 0.5;
str = sprintf('Height threshold {u} = %0.2f, p = %0.3f',u,1 - spm_Ncdf(u));
text(0,y,str,'FontSize',8);
y  = y - 1;
str = sprintf('Extent threshold {k} = %i voxels',k);
text(0,y,str,'FontSize',8);
y  = y - 1;
str = sprintf('Expected voxels per cluster, E{n} = %0.1f',En);
text(0,y,str,'FontSize',8);
y  = y - 1;
str = sprintf('Expected number of clusters, E{m} = %0.1f',Em*Pk);
text(0,y,str,'FontSize',8);
y  = y + 3;
str = sprintf('Volume {S} = %i voxels or %0.1f Resels ',S,RESEL);
text(0.6,y,str,'FontSize',8);
y  = y - 1;
str = sprintf('Degrees of freedom due to error = %0.0i ',df);
text(0.6,y,str,'FontSize',8);
y  = y - 1;

if D == 2
    str = sprintf('Smoothness = %0.1f %0.1f mm {FWHM}',FWHM);
end
if D == 3
    str = sprintf('Smoothness = %0.1f %0.1f %0.1f mm {FWHM}',FWHM);
end
text(0.6,y,str,'FontSize',8);
y  = y - 1;
if D == 2
    str = sprintf(' = %0.1f %0.1f {voxels}',W.*V([1:D] + 3)');
end
if D == 3
    str = sprintf(' = %0.1f %0.1f %0.1f {voxels}',W.*V([1:D] + 3)');
end
text(0.6,y,str,'FontSize',8);


% set(gca,'Ylim',[y 24]);

