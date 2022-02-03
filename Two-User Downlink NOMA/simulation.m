%% Configuration
BW = 10^6; % Bandwidth (Hz)
P_dBm = 0:1:40;             % Transmission power (dBm)
P = (10^-3)*10.^(P_dBm/10);   % Transmission power (linear)

%Fixed Power Allocation
% Weak User
d1 = 1000;
a1 = 0.75;
% Strong User
d2 = 500;
a2 = 0.25;

data_length = 10^6;

BER_1 = [];
BER_2 = [];

%% Create random binary data for each user
x1_data = randi([0 1], data_length, 1);
x2_data = randi([0 1], data_length, 1);

%% BPSK baseband modulation
x1 = pskmod(x1_data, 2, pi);
x2 = pskmod(x2_data, 2, pi);

%% Get channel gain and noise for each user
[h1, n1] = channel(BW, d1, length(x1));
[h2, n2] = channel(BW, d2, length(x2));

%% For transmission power p in array P
for p = P
    % Superposition Coding
    s = sqrt(p*a1)*x1 + sqrt(p*a2)*x2;

    % Received signals
    y1 = h1.*s + n1;
    y2 = h2.*s + n2;

    % Equalisation
    y1 = y1./h1;
    y2 = y2./h2;
    
    % Decode x1 from y1 (direct detection)
    x1_decoded = pskdemod(y1, 2, pi);
    [~, BER_1(end+1)] = biterr(x1_data, x1_decoded);
    
    % Decode x1 from y2 (SIC)
    x1_2 = pskmod(pskdemod(y2, 2, pi), 2, pi); % Demodulate to binary and remodulate
    y2 = y2 - (sqrt(a1*p))*x1_2; % Subtract decoded signal with assigned amplitude
    x2_decoded = pskdemod(y2, 2, pi);
    [~, BER_2(end+1)] = biterr(x2_data, x2_decoded);

end

%% Plot BER for each user against power (dBm)
semilogy(P_dBm, BER_1);
hold on
semilogy(P_dBm, BER_2);

plot_title = sprintf('BER vs Transmission Power \n AWGN + Rayleigh Fading + Log Distance Path Loss \n BW = %2.0e Hz',BW);
title(plot_title);
u1_legend = sprintf('User 1 (Weak User, d = %dm, a = %.2f)', d1, a1);
u2_legend = sprintf('User 2 (Strong User, d = %dm, a = %.2f)', d2, a2);
legend(u1_legend, u2_legend);
xlabel('Power (dBm)');
ylabel('BER')
