function [Nv, Nf] = spm_mesh_normals(M, unit)
% Compute (unit) normals of a surface mesh
% FORMAT [Nv, Nf] = spm_mesh_normals(M, unit)
% M      - a patch structure or a handle to a patch
% unit   - boolean to indicate unit normals or not [default: false]
%
% Nv     - a [nx3] array of (unit) normals on vertices
% Nf     - a [mx3] array of (unit) normals on faces
%__________________________________________________________________________
% Copyright (C) 2008-2016 Wellcome Trust Centre for Neuroimaging

% Guillaume Flandin
% $Id: spm_mesh_normals.m 6955 2016-11-30 11:40:52Z guillaume $


if nargin < 2, unit = false; end

if ishandle(M)
    Nv = double(get(M,'VertexNormals'));
    if nargout > 1
        Nf = double(get(M,'FaceNormals'));
    end
    if isempty(Nv)
        M = struct('faces',get(M,'Faces'), 'vertices',get(N,'Vertices'));
        if nargout > 1
            [Nv, Nf] = spm_mesh_normals(M, unit);
        else
            Nv = spm_mesh_normals(M, unit);
        end
    end
else
    try
        t = triangulation(double(M.faces),double(M.vertices));
        Nv = -double(t.vertexNormal);   % unit norm
        if nargout > 1
            Nf = -double(t.faceNormal); % unit norm
        end
    catch
        [Nv,Nf] = mesh_normal(M);
        % f = figure('visible','off');
        % M = patch(M, 'parent',axes('parent',f), 'visible', 'off');
        % [Nv, Nf] = spm_mesh_normals(M, unit);
        % close(f);
    end
end

if unit
    Nv     = normit(Nv);
    if nargout > 1
        Nf = normit(Nf);
    end
end


function [Nv,Nf] = mesh_normal(M)
Nf = cross(...
    M.vertices(M.faces(:,2),:)-M.vertices(M.faces(:,1),:), ...
    M.vertices(M.faces(:,3),:)-M.vertices(M.faces(:,1),:));
Nf = normit(Nf); % it seems the way triangulation.vertexNormal works
                 % i.e. Nv is not a weighted sum by faces' area.

Nv = zeros(size(M.vertices));
for i=1:size(M.faces,1)
    f = M.faces(i,:);
    for j=1:3
        Nv(f(j),:) = Nv(f(j),:) + Nf(i,:);
    end
end

C = bsxfun(@minus,M.vertices,mean(M.vertices,1));
if nnz(sign(sum(C.*Nv,2))) > size(C,1)/2
    Nv = -Nv;
    Nf = -Nf;
end


function N = normit(N)
normN = sqrt(sum(N.^2,2));
normN(normN < eps) = 1;
N     = bsxfun(@rdivide,N,normN);
    