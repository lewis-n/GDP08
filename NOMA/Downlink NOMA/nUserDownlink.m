clear
clc
p = 1;
addpath('../../Channel Models')
% Number of users
N_Users = 3;

% User distances from transmitter
d = [1, 0.4, 0.14];

% User power allocation coefficients
a = [0.6, 0.25, 0.15];

% Length of random binary data to be transmitted
N_data = 5*10^5;

% Modulation Order
M = 2;
k = log2(M);

% Generate random binary data for each user
x = randi([0 1], N_data, N_Users)';

% Perform baseband modulation of data
x_mod = pskmod(x, 2, pi);

% Get fading and path loss conditions for each user
eta = 4;
PL = sqrt(d.^-eta)';
h = (PL.*(randn(N_data, N_Users) + 1i*randn(N_data, N_Users))')/sqrt(2);

EbNo = 0:1:30;

BER_AWGN_RAY = [];

for i = 1:length(EbNo)
    % Superposition Coding
    s = sum(sqrt(p*a').*x_mod);
    
    % AWGN Channel
    rng('default'); % Reset rng
    for j = 1:N_Users
        n(j,:) = AWGNChannel(s, EbNo(i), k);
    end
    
    % Fading Channel
    y = h.*s + n;

    y = y./h; % Equalise

    decoded = SIC(y, a, p);
    [~, BER_AWGN_RAY(:,i)] = biterr(x, decoded, 'row-wise');

end

figure(2)

for i = 1:N_Users
    semilogy(EbNo, BER_AWGN_RAY(i,:), 'DisplayName', strcat('User', 32, num2str(i)));
    hold on
end
legend show
title(sprintf('BER (AWGN + Rayleigh Fading), eta = %d', eta))
grid on
ylabel('BER');
xlabel('EbNo (dB)');

