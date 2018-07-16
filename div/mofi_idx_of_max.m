function max_idx = mofi_idx_of_max(volume)
%
% Finds the index of the maximum value.
%   max_idx = idx_of_max(volume);
% 
% Output:
%   max_idx.dim1        -- first  dim
%   max_idx.dim2        -- second dim
%   max_idx.dim3        -- third  dim
%   max_idx.max_val     -- the maximum value
%   max_idx.max_val_rep -- number of times the max value appears in 'volume'
%
% The function works on both three, two and one dimensional data.
%
% To find the index of the minimum value, one could use the following:
%   min_idx = idx_of_max(-volume);
%
% By Morten F. Rasmussen. 
% Updated April 2012 (now also supports one- and two-dimensional data).
% 2013-08-07, MFR, Rearranged the output order of dim1, dim2 and dim3. 
% 2013-08-16, MFR, Row vectors are no longer interpreted as 2D Matrices.
% 2013-09-17, MFR, Renamed to mofi_sound_speed_calc.
% 2014-02-02, MFR, Added max_val_rep.
% 2014-02-19, MFR, Can now also handle singular dimensions.
%

dims           = size(volume);
singular_dims  = find((dims==1));
N_dim          = length(dims) - length(singular_dims); % remove empty (singular) dimensions
[max_val, idx] = max(volume); %#ok



if length(singular_dims) > 0
    % Remove singular dimensions
    volume = squeeze(volume);
end


if N_dim == 3
    [max_val_1 max_1] = max(volume,[],1);
    max_surf = squeeze(max_val_1);
    [max_val_2 max_2] = max(max_surf,[],1);
    max_line = squeeze(max_val_2);
    [max_val temp_dim3] = max(max_line,[],2);  %#ok
    temp_dim2 = max_2(temp_dim3);
    temp_dim1 = max_1(1, temp_dim2, temp_dim3);
    
    temp_dim(1) = temp_dim1;
    temp_dim(2) = temp_dim2;
    temp_dim(3) = temp_dim3;
elseif N_dim ==2
    [max_val_1 max_1] = max(volume,[],1);
    [max_val   max_2] = max(max_val_1); %#ok
    temp_dim(1)       = max_1(max_2); 
    temp_dim(2)       = max_2;
        
elseif N_dim ==1
    [max_val   max_1] = max(volume); %#ok
    temp_dim(1)       = max_1;
end



% Set the output - also for singular dimensions. This makes it easier to use the tool
idx2 = 1;
for idx=1:length(dims)    
    if sum(idx == singular_dims) % singular dimension
        max_idx.(sprintf('dim%i',idx)) = 1;
    else                         % non-singular dimension
        max_idx.(sprintf('dim%i',idx)) = temp_dim(idx2);
        idx2 = idx2+1;
    end
end


% Other helper variables
if length(singular_dims)==0
    max_idx.singular_dims = [];
else
    max_idx.singular_dims = singular_dims;
end
max_idx.max_val       = max_val;
max_idx.max_val_rep   = sum(volume(:) == max_idx.max_val);
