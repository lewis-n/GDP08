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
    rng('default'); % Reset rng
    for j = 1:N_users
        n(:,j) = AWGNChannel(s, EbNo(i), k);
    end

    y = s.*PL + n;
    decoded = SIC(y, a, p, mpskmod, mpskdemod);
    BER_AWGN(i,:) = sum(x ~= decoded)./N_data;

    % Fading Channel
    y = h.*s + n;
    y = y./h; % Equalise
    decoded = SIC(y, a, p, mpskmod, mpskdemod);
    BER_Fading(i,:) = sum(x ~= decoded)./N_data;
end

all_marks = {'s', '^', 'd', 'x', 'o'};

figure(1)
for i = 1:N_users
    semilogy(EbNo, BER_AWGN(:,i), 'DisplayName', strcat('User', 32, num2str(i)), 'Marker', all_marks{mod(i,5)});
    hold on
end
axis tight
legend show
%title('BER (AWGN)')
grid on
ylabel('BER')
xlabel('EbNo (dB)')
ylim([4.2E-5 1])

figure(2)
for i = 1:N_users
    semilogy(EbNo, BER_Fading(:,i), 'DisplayName', strcat('User', 32, num2str(i)), 'Marker', all_marks{mod(i,5)});
    hold on
end
legend show
%title('BER (AWGN + Rayleigh Fading)')
grid on
xlim([0 25])
ylabel('BER')
xlabel('EbNo (dB)')

