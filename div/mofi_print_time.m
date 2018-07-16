function time_out = mofi_print_time

%%
%  CFU_PRINT_TIME
%
% Prints the current date and time to the terminal
% Input:  None
% Output: YYYY-MM-DD HH:MM (SS)
%
% Version 1.0, 2011-12-14, MFR, Init version
% Version 1.1, 2011-12-15, MFR, Changed formating
% Version 1.2, 2011-12-15, MFR, Renamed from print_clock to print_time
%

t = clock;

time = sprintf('%04i-%02i-%02i_%02.0f:%02.0f:%02.0fs\n',t(1), t(2), t(3), t(4), t(5), t(6));
fprintf('Time: %s', time);

if nargout > 0
    time_out = time;
end
