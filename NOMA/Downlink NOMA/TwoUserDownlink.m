clear
clc

p = 1;

% User distances from transmitter
d1 = 2;
d2 = 1;

% User power allocation coefficients
a1 = 0.75;
a2 = 0.25;

% Length of random binary data to be transmitted
N_data = 10^6;

% Generate random binary data for each user
x1 = randi([0 1], N_data, 1)';
x2 = randi([0 1], N_data, 1)';

% Perform baseband modulation of data
x1_mod = pskmod(x1, 2, pi);
x2_mod = pskmod(x2, 2, pi);

% Get fading and path loss conditions for each user
g1 = sqrt(1/2)*(randn(N_data, 1) + 1i*randn(N_data, 1))';
g2 = sqrt(1/2)*(randn(N_data, 1) + 1i*randn(N_data, 1))';

eta = 4; 
PL1 = sqrt(d1^eta);
PL2 = sqrt(d2^eta);

h1 = g1/PL1;
h2 = g2/PL2;

EbNo = 0:0.5:25;

BER_1 = [];
BER_2 = [];

for i = EbNo
    % Superposition Coding
    s = sqrt(p*a1)*x1_mod + sqrt(p*a2)*x2_mod;

    rng('default'); % Reset rng
    [~, n1] = AWGNChannel(s, i, 1);
    [~, n2] = AWGNChannel(s, i, 1);

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
end

semilogy(EbNo,BER_1);
hold on
semilogy(EbNo,BER_2);
title('Rayleigh Fading + AWGN');
ylabel('BER');
xlabel('EbNo (dB)');
legend('User 1', 'User 2');