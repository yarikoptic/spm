function t = mystruct(obj)
% _______________________________________________________________________
% $Id$

if numel(obj)~=1,
    error('Too many elements to convert');
end;
fn = fieldnames(obj);
for i=1:length(fn)
    t.(fn{i}) = subsref(obj,struct('type','.','subs',fn{i}));
end;
return;
