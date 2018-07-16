function time_str = mofi_get_time

t = clock;
time_str = sprintf('%04i_%02i_%02i_%02.0f%02.0f_%02.0f',t(1), t(2), t(3), t(4), t(5), t(6));
