clear
clc
% User distances from transmitter
d1 = 2;
d2 = 1;

% User power allocation coefficients
a1 = 0.75;
a2 = 0.25;

% Noise power in 1Hz bandwidth (Watts)
N0 = 3.981E-21;

% Length of random binary data to be transmitted
N_data = 10^6;

% Generate random binary data for each user
x1 = randi([0 1], N_data, 1);
x2 = randi([0 1], N_data, 1);

% Perform baseband modulation of data
x1_mod = pskmod(x1, 2, pi);
x2_mod = pskmod(x2, 2, pi);

% Get noise samples for each user
n1 = sqrt(N0/2)*(randn(N_data, 1) + 1i*randn(N_data, 1));
n2 = sqrt(N0/2)*(randn(N_data, 1) + 1i*randn(N_data, 1));

% Get fading and path loss conditions for each user
g1 = sqrt(1/2)*(randn(N_data, 1) + 1i*randn(N_data, 1));
g2 = sqrt(1/2)*(randn(N_data, 1) + 1i*randn(N_data, 1));

eta = 4; 
PL1 = sqrt(d1^eta);
PL2 = sqrt(d2^eta);

h1 = g1/PL1;
h2 = g2/PL2;

SNR_dB = 0:1:70;
SNR_Lin = 10.^(SNR_dB/10);

BER_1 = [];
BER_2 = [];
u1_rate_avg = [];
u2_rate_avg = [];

u1_threshold = 1;
u2_threshold = 2;
u1_outage = [];
u2_outage = [];

for p = SNR_Lin*N0
    % Superposition Coding
    s = sqrt(p*a1)*x1_mod + sqrt(p*a2)*x2_mod;

    % Received signals
    y1 = h1.*s + n1;
    y2 = h2.*s + n2;

    % Equalisation
    y1 = y1./h1;
    y2 = y2./h2;
    
    % Decode x1 from y1 (direct detection)
    x1_decoded = pskdemod(y1, 2, pi);
    [~, BER_1(end+1)] = biterr(x1, x1_decoded);
    
    % Decode x1 from y2 (SIC)
    x1_2 = pskmod(pskdemod(y2, 2, pi), 2, pi); % Demodulate to binary and remodulate
    y2 = y2 - (sqrt(a1*p))*x1_2; % Subtract decoded signal with assigned amplitude
    x2_decoded = pskdemod(y2, 2, pi);
    [~, BER_2(end+1)] = biterr(x2, x2_decoded);
    
    u1_SNR = ( (abs(h1).^2)*p*a1)./((abs(h1).^2)*p*a2 + N0);
    u2_SNR = ( (abs(h2).^2)*p*a2)./(N0);
    
    u1_rate = log2(1 + u1_SNR);
    u2_rate = log2(1 + u2_SNR);
    u1_rate_avg(end+1) = mean(u1_rate);
    u2_rate_avg(end+1) = mean(u2_rate);

    u1_outage(end+1) = sum(u1_rate < u1_threshold)/N_data;
    u2_outage(end+1) = sum(u2_rate < u2_threshold)/N_data;

    EbN0_1 = SNR_Lin/u1_rate_avg(end);
    EbN0_2 = SNR_Lin/u2_rate_avg(end);
end

EbN0_1_dB = 10*log10(EbN0_1);
EbN0_2_dB = 10*log10(EbN0_2);

t1 = tiledlayout(3,1);
title(t1, 'AWGN + Rayleigh Fading (Log Distance Path Loss)');
nexttile(t1)
semilogy(EbN0_1_dB, BER_1);
hold on
semilogy(EbN0_2_dB, BER_2);
u1_legend = sprintf('User 1 (Weak User, d = %dm, a = %.2f)', d1, a1);
u2_legend = sprintf('User 2 (Strong User, d = %dm, a = %.2f)', d2, a2);
legend(u1_legend, u2_legend);
xlabel('Eb/No (dB)');
ylabel('BER');
plot_title = sprintf('BER vs Transmission Power');
title(plot_title);
xlim([0 30])

nexttile(t1)
plot(EbN0_1_dB, u1_rate_avg);
hold on
plot(EbN0_2_dB, u2_rate_avg);
xlabel('Eb/No (dB)');
ylabel('Rate (bps)');
legend(u1_legend, u2_legend);
title('User Rates');
xlim([0 30])

nexttile(t1)
semilogy(EbN0_1_dB, u1_outage);
hold on
semilogy(EbN0_2_dB, u2_outage);
xlabel('Eb/No (dB)');
ylabel('Outage Probability')
legend(u1_legend, u2_legend);
title('Outage Probability');
xlim([0 30])