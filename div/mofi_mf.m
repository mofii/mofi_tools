function [samples_mf cutoff] = mofi_mf (samples, waveform, shape)

%
% SAMPLES_MF [CUTOFF] = CFU_MF(samples, waveform [,shape])
%
% The input samples are converted to double, the DC-offset is removed from each channel, and then 
% the matched-filtering is carried out.
%
% Before filtering the waveform amplitude is normalized to have unit area.
%
%
% EXAMPLE:
%[samples_mf cut_idx] = mofi_mf(samples, excitation, 'full');% match filtering
%rf_data = hilbert(samples_mf); % IQ beamforming
%rf_data=rf_data(1+cut_idx:end-cut_idx,:); %remove extra samples from convolution
%
% 2012-05-25, V1.0, Init version, MFR
% 2012-09-07, v1.1, Help text expanded. MFR
% 2012-09-22, v1.2, Shape of conv2 now an input argument.
% 2012-09-27, v1.3, cutoff index is now calculated when shape='full'.
% 2013-09-17, v1.4, Renamed to mofi_mf. MFR
% 2014-03-10, v1.5, Updated the help file. MFR.
% 2014-05-04, v1.5, Speed optimization. MFR.
% 2014-06-10, v1.6, Transpose the waveform if it is not a column-vector.


if  nargin < 3,    shape = 'same'; end
if ~ischar(shape), error('''shape'' must be a string.'); end
N = size(waveform);
if length(N) > 2 || min(N) > 1
    error('The waveform must be a vector')
end

% Make sure the waveform is a column vector
if N(2) > 1, waveform = transpose(waveform); end;


% kernel
kernel  = flipud(waveform);
kernel  = kernel/sum(abs(kernel));

% $$$ samples = double(samples);                                     % parse to double
% $$$ samples = double(samples - repmat(mean(samples),[size(samples,1) 1]); % remove DC from signal
% match filtering
%samples_mf = conv2(samples_mf, kernel, shape);
samples_mf = conv2(double(samples) - repmat(mean(double(samples)),[size(samples,1) 1]), kernel, shape);

% set second output
if nargout > 1
    if strcmp(shape,'full')
        cutoff = floor(length(waveform)/2);
    else
        cutoff = 0;
    end
end


