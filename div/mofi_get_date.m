function date = mofi_get_date
% YYYY-MM-DD
t = clock;
date = sprintf('%04i_%02i_%02i',t(1), t(2), t(3));
