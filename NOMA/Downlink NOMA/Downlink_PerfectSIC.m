clear; clc; addpath('../../Channel Models')

%  Downlink NOMA simulation
%
%  BER performance for each user using perfect SIC
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

BER_AWGN = zeros(N_users, length(EbNo));
BER_Fading = zeros(N_users, length(EbNo));

for i = 1:length(EbNo)
    % AWGN Channel
    rng('default'); % Reset rng
    for j = 1:N_users
        n(j,:) = AWGNChannel(s, EbNo(i), k);
    end

    y = s.*PL + n;
    decoded = SIC(y, a, p, 0);
    [~, BER_AWGN(:,i)] = biterr(x, decoded, 'row-wise');


    % AWGN + Fading Channel
    y = h.*s + n;
    y = y./h; % Equalise
    decoded = SIC(y, a, p, 0);
    [~, BER_Fading(:,i)] = biterr(x, decoded, 'row-wise');

end

tiledlayout(1, 2)
nexttile
for i = 1:N_users
    semilogy(EbNo, BER_AWGN(i,:), 'DisplayName', strcat('User', 32, num2str(i)));
    hold on
end
axis tight
legend show
title('BER (AWGN)')
grid on
ylabel('BER')
xlabel('EbNo (dB)')

nexttile
for i = 1:N_users
    semilogy(EbNo, BER_Fading(i,:), 'DisplayName', strcat('User', 32, num2str(i)));
    hold on
end
legend show
title('BER (AWGN + Rayleigh Fading)')
grid on
ylabel('BER')
xlabel('EbNo (dB)')

