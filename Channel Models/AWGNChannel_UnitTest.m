% This unit test verifies the functionality of the AWGNChannel function

x = linspace(0, 100, 2000);
y = complex(sin(x));
y_pwr = sum(abs(y).^2)/length(y);

awgnchan = comm.AWGNChannel('SignalPower', y_pwr);

% Test with EbNo = 10dB (awgnchannel object default)
rng('default'); % Reset rng
y_out_builtin = awgnchan(y);
rng('default'); % Reset rng
y_out_custom = AWGNChannel(y, 10, 1);

plot(x, real(y_out_builtin));
hold
plot(x, real(y_out_custom), 'Marker','diamond', 'LineStyle','none');
legend('built-in', 'custom')