function hdr = empty_hdr
% Create an empty NIFTI-1 header
% FORMAT hdr = empty_hdr
% _______________________________________________________________________
% %W% John Ashburner %E%

org = niftistruc;
for i=1:length(org),
    hdr.(org(i).label) = org(i).def;
end;

