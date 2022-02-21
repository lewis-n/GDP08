%% Configuration
BW = 10^6;                    % Bandwidth (Hz)
P_dBm = 0:1:40;               % Transmission power (dBm)
P = (10^-3)*10.^(P_dBm/10);   % Transmission power (linear)

%Fixed Power Allocation
% User 1 (weakest and farthest)
d1 = 1000;
a1 = 0.50;
% User 2
d2 = 500;
a2 = 0.25;
% User 3
d3 = 250;
a3 = 0.15;
% User 4 (strongest and nearest)
d4 = 200;
a4 = 0.10;

data_length = 10^6;

BER_1 = [];
BER_2 = [];
BER_3 = [];
BER_4 = [];

%% Create random binary data for each user
x1_data = randi([0 1], data_length, 1);
x2_data = randi([0 1], data_length, 1);
x3_data = randi([0 1], data_length, 1);
x4_data = randi([0 1], data_length, 1);

%% BPSK baseband modulation
x1 = pskmod(x1_data, 2, pi);
x2 = pskmod(x2_data, 2, pi);
x3 = pskmod(x3_data, 2, pi);
x4 = pskmod(x4_data, 2, pi);

%% Get channel gain and noise for each user
[h1, n1] = channel(BW, d1, length(x1));
[h2, n2] = channel(BW, d2, length(x2));
[h3, n3] = channel(BW, d3, length(x3));
[h4, n4] = channel(BW, d4, length(x4));

%% For transmission power p in array P
for p = P
    % Superposition Coding
    s = sqrt(p*a1)*x1 + sqrt(p*a2)*x2 + sqrt(p*a3)*x3 + sqrt(p*a4)*x4;

    % Received signals
    y1 = h1.*s + n1;
    y2 = h2.*s + n2;
    y3 = h3.*s + n3;
    y4 = h4.*s + n4;

    % Equalisation
    y_eq1 = y1./h1;
    y_eq2 = y2./h2;
    y_eq3 = y3./h3;
    y_eq4 = y4./h4;
    
    % Decode at U1 (direct, no SIC)
    x1_decoded = pskdemod(y_eq1, 2, pi);
    [~, BER_1(end+1)] = biterr(x1_data, x1_decoded);

    % Decode at U2 (U1 SIC)
    x1_2_demod = pskdemod(y_eq2, 2, pi);
    x1_2_remod = pskmod(x1_2_demod, 2, pi); % Demodulate to binary and remodulate
    y1_2 = y_eq2 - (sqrt(a1*p))*x1_2_remod; % Subtract decoded signal with assigned amplitude
    x2_decoded = pskdemod(y1_2, 2, pi);
    [~, BER_2(end+1)] = biterr(x2_data, x2_decoded);

    % Decode at U3 (U1 and U2 SIC)
    x1_3_demod = pskdemod(y_eq3, 2, pi);
    x1_3_remod = pskmod(x1_3_demod, 2, pi); % Demodulate to binary and remodulate
    y1_3 = y_eq3 - (sqrt(a1*p))*x1_3_remod; % Subtract decoded signal with assigned amplitude
    x2_3_demod = pskdemod(y1_3, 2, pi);
    x2_3_remod = pskmod(x2_3_demod, 2, pi);
    y3 = y1_3 -  (sqrt(a2*p))*x2_3_remod;
    x3_decoded = pskdemod(y3, 2, pi);
    [~, BER_3(end+1)] = biterr(x3_data, x3_decoded);

    % Decode at U4 (U1, U2 and U3 SIC)
    x1_4_demod = pskdemod(y_eq4, 2, pi);
    x1_4_remod = pskmod(x1_4_demod, 2, pi); % Demodulate to binary and remodulate
    y1_4 = y_eq4 - (sqrt(a1*p))*x1_4_remod; % Subtract decoded signal with assigned amplitude
    x2_4_demod = pskdemod(y1_4, 2, pi);
    x2_4_remod = pskmod(x2_4_demod, 2, pi);
    y4_2 = y1_4 - (sqrt(a2*p))*x2_4_remod;
    x4_demod = pskdemod(y4_2, 2, pi);
    x4_remod = pskmod(x4_demod, 2, pi);
    y4 = y4_2 - (sqrt(a3*p))*x4_remod;
    x4_decoded = pskdemod(y4, 2, pi);
    [~, BER_4(end+1)] = biterr(x4_data, x4_decoded);

end

%% Plot BER for each user against power (dBm)
semilogy(P_dBm, BER_1);
hold on
semilogy(P_dBm, BER_2);
hold on
semilogy(P_dBm, BER_3);
hold on
semilogy(P_dBm, BER_4);

plot_title = sprintf('BER vs Transmission Power \n AWGN + Rayleigh Fading + Log Distance Path Loss \n BW = %2.0e Hz',BW);
title(plot_title);
u1_legend = sprintf('User 1 (Weakest User, d = %dm, a = %.2f)', d1, a1);
u2_legend = sprintf('User 2 (d = %dm, a = %.2f)', d2, a2);
u3_legend = sprintf('User 3 (d = %dm, a = %.2f)', d3, a3);
u4_legend = sprintf('User 4 (Strongest User, d = %dm, a = %.2f)', d4, a4);
legend(u1_legend, u2_legend, u3_legend, u4_legend);
xlabel('Power (dBm)');
ylabel('BER')