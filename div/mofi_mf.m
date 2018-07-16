function samples_mf = mofi_mf (samples, kernel, enable_hilbert, shape)
%
% SAMPLES_MF = MOFI_MF(samples, kernel [,enable_hilbert = 1, shape = 'same'])
%
% The input samples are converted to double, the DC-offset is removed from each channel, and then 
% the matched-filtering and possibly the hilbert transform are carried out.
%
% Before filtering the kernel function is normalized to have unit area.
%
%
% EXAMPLE:
% enable_hilbert = 1;
% conv2_length   = 'same';
% [samples_mf]   = mofi_mf(samples, filter_kernel, enable_hilbert, conv2_length);
%
% 2012-05-25, V1.0, Init version, MFR
% 2012-09-07, v1.1, Help text expanded. MFR
% 2012-09-22, v1.2, Shape of conv2 now an input argument.
% 2012-09-27, v1.3, cutoff index is now calculated when shape='full'.
% 2013-09-17, v1.4, Renamed to mofi_mf. MFR
% 2014-03-10, v1.5, Updated the help file. MFR.
% 2014-05-04, v1.5, Speed optimization. MFR.
% 2014-06-10, v1.6, Transpose the kernel if it is not a column-vector.
% 2018-06-13, v1.7, The hilbert transform is now carried out within this function. 

if  nargin < 4,    shape = 'same'; end
if  nargin < 3,    enable_hilbert = true; end
if ~ischar(shape), error('''shape'' must be a string.'); end
N = size(kernel);
if length(N) > 2 || min(N) > 1
    error('The kernel must be a vector')
end

if strcmp(shape,'valid')
    error('Valid is not currently supported. Use ''same'' or ''full''.');
end

% Make sure the kernel is a column vector
if N(2) > 1, kernel = transpose(kernel); end;

% Make sure all data is double precision
if ~isa(samples, 'double'), samples = double(samples); end
if ~isa(kernel, 'double'),  kernel = double(kernel);   end

% Kernel
kernel  = flipud(kernel);
kernel  = kernel/sum(abs(kernel)+eps);

% Full length of convolution (makes hilbert behave well)
samples_mf = conv2(bsxfun(@minus, samples, mean(samples)), kernel, 'full');

% Hilbert transform
if enable_hilbert
    samples_mf = hilbert(samples_mf);
end

if strcmp(shape,'same')
    cut_idx = floor(length(kernel)/2);
    samples_mf = samples_mf(1+cut_idx:end-cut_idx,:); %remove extra samples from convolution
end    

