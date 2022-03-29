clear; clc; addpath('../../Channel Models')

%  Downlink NOMA simulation
%
%  BER performance for users using imperfect SIC
%
%  Generated data, signals, and channel conditions are specfied as
%  matrices with dimensions N_users x N_data.


%  -------------- Parameters ---------------
p = 1; % Transmission power
d = [2, 1]; % User distances from transmitter
a = [0.75, 0.25]; % Power allocation coefficients for each user
N_data = 5*10^5; % Length of binary data transmitted to each user
M = 2; % Modulation Order
eta = 4; % Path loss coefficient
EbNo = 0:1:30; % EbNo Values
e = [0 0.05 0.1 0.2]; % Array of SIC residual powers (errors)

%  -------------- Simulation ---------------
assert(length(d) == length(a), 'Length of array ''d'' must equal length of array ''a''');
N_users = length(d);
k = log2(M); % Bits per symbol

% Generate random binary data for each user
x = randi([0 1], N_data, N_users)';

% Perform baseband modulation of data
x_mod = pskmod(x, 2, pi);

% Generate fading and path loss conditions for each user
PL = sqrt(d.^-eta)';
h = (PL.*(randn(N_data, N_users) + 1i*randn(N_data, N_users))')/sqrt(2);

% Superposition Coding
s = sum(sqrt(p*a').*x_mod);

BER_AWGN_RAY = zeros(length(e), length(EbNo));
rate = zeros(length(e), length(EbNo));

for i = 1:4
    for j = 1:length(EbNo)
        % AWGN Channel
        rng('default'); % Reset rng
        for l = 1:N_users
            n(l,:) = AWGNChannel(s, EbNo(j), k);
        end
        
        % Fading Channel
        y = h.*s + n;
    
        y = y./h; % Equalise
    
        decoded = SIC(y, a, p, e(i));
        [~, BER_AWGN_RAY(i,j)] = biterr(x(2,:), decoded(2,:));
        
        g2 = abs(h(2,:)).^2;
        rate(i,j) = mean(log2(1 + (g2.*p*a(2)) ./ (e(i)*g2*p*a(1) + abs(n(2,:)).^2) ));
    end
end

figure(1)
semilogy(EbNo, BER_AWGN_RAY(1,:), 'DisplayName', 'e = 0');
hold on
semilogy(EbNo, BER_AWGN_RAY(2,:), 'DisplayName', 'e = 0.05');
semilogy(EbNo, BER_AWGN_RAY(3,:), 'DisplayName', 'e = 0.1');
semilogy(EbNo, BER_AWGN_RAY(4,:), 'DisplayName', 'e = 0.3');

legend show
title('AWGN + Rayleigh Fading (User 2)');
grid on
ylabel('BER');
xlabel('EbNo (dB)');

figure(2)
plot(EbNo, rate(1,:), 'DisplayName', 'e = 0');
hold on
plot(EbNo, rate(2,:), 'DisplayName', 'e = 0.05');
plot(EbNo, rate(3,:), 'DisplayName', 'e = 0.1');
plot(EbNo, rate(4,:), 'DisplayName', 'e = 0.3');
title('AWGN + Rayleigh Fading (User 2)');
grid on
legend
xlabel('EbNo (dB)');
ylabel('Rate (bps/Hz)')