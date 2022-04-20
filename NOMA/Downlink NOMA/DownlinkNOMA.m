clear; clc; addpath('../../Channel Models')

%  Downlink NOMA simulation
%
%  BER performance for each user in downlink NOMA using SIC
%
%  Generated data, signals, and channel conditions are specfied as
%  matrices with dimensions N_data x N_users (columns represents channels).


%  -------------- Parameters ---------------
p = 1; % Transmission power
d = [1000, 500]; % Distance of each user from transmitter
a = [0.8, 0.2]; % Power allocation coefficients for each user
N_data = 10^6; % Length of data transmitted to each user
M = 2; % Modulation Order
k = log2(M); % Bits per symbol
eta = 4; % Path loss coefficient
EbNo = 0:2:30; % EbNo Values

mpskmod = comm.PSKModulator(M, pi);
mpskdemod = comm.PSKDemodulator(M, pi);

%  -------------- Simulation ---------------
assert(length(d) == length(a), 'Length of array ''d'' must equal length of array ''a''');
N_users = length(d);

% Generate random data for each user
x = randi([0 M-1], N_data, N_users);

% Perform baseband modulation of data
for i = 1:N_users
    x_mod(:,i) = mpskmod(x(:,i));
end

% Generate fading and path loss conditions for each user
PL = sqrt(d.^-eta);
h = (PL.*(randn(N_data, N_users) + 1i*randn(N_data, N_users)))/sqrt(2);

% Superposition Coding
s = sum(sqrt(p*a).*x_mod, 2);

BER_AWGN = zeros(length(EbNo), N_users);
BER_Fading = zeros(length(EbNo), N_users);

for i = 1:length(EbNo)
    % AWGN Channel
    % No path loss applied
    rng('default'); % Reset rng

    y = repmat(s, 1, N_users);
    y = AWGNChannel(y, EbNo(i), k); % Apply noise
    decoded = SIC(y, a, p, mpskmod, mpskdemod);
    [~, BER_AWGN(i,:)] = biterr(x, decoded, [], 'column-wise');

    % Fading Channel
    % Rayleigh fading + path loss
    y = h.*s;
    y = AWGNChannel(y, EbNo(i), k); % Apply noise
    y = y./h; % Equalise
    decoded = SIC(y, a, p, mpskmod, mpskdemod);
    [~, BER_Fading(i,:)] = biterr(x, decoded, [], 'column-wise');
end

all_marks = {'s', '^', 'd', 'x', 'o', '.', '*'};

figure(1)
for i = 1:N_users
    semilogy(EbNo, BER_AWGN(:,i), 'DisplayName', strcat('User', 32, num2str(i)), 'Marker', all_marks{mod(i,7)});
    hold on
end
axis tight
legend show
%title('BER (AWGN)')
grid on
ylabel('BER')
xlabel('EbNo (dB)')
ylim([1E-5 1])
xlim([0 16])

figure(2)
for i = 1:N_users
    semilogy(EbNo, BER_Fading(:,i), 'DisplayName', strcat('User', 32, num2str(i)), 'Marker', all_marks{mod(i,7)});
    hold on
end
legend show
%title('BER (AWGN + Rayleigh Fading)')
grid on
xlim([0 25])
ylabel('BER')
xlabel('EbNo (dB)')

