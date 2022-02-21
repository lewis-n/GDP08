clear all;
N = 50000; % Length of random binary data
SNR = 0:1:12; % SNR range

iterations = 1:1; % Number of iterations to average BER over
BER_AWGN = zeros([length(SNR) 1]);
BER_AWGN_h = zeros([length(SNR) 1]);

k = 1; %length of data per coding
n = 3; %length of codeword

% Generate random binary data of length N
data = randi([0 1], 1, N);

%encode data
%encode each bits one by one and generate a new codeword called 'enc_data'
for mm = 1:length(data)
    enc_bits = encode(data(mm),n,k,'hamming/binary');
    for ii = 1:n
        enc_data((mm-1)*n+ii) = enc_bits(ii);
    end
end
        
% Convert binary to NRZ-L
% Bit 1 -> Symbol 1
% Bit 0 -> Symbol -1
tx = pskmod(enc_data, 2, pi);

for i = 1:length(SNR)
    for j = iterations
        [rx_AWGN, rx_AWGN_h, h] = Channel(tx, SNR(i));
        
        % Demodulate AWGN signal and decode data
        y = pskdemod(rx_AWGN, 2, pi);
      for mm = 1:length(data)
            for ii = 1:n
                dec_bits(ii) = y((mm-1)*n+ii);
            end
            dec_data(mm) = decode(dec_bits,n,k,'hamming/binary');
      end
        
        %calculate BER
        BER_AWGN(i) = BER_AWGN(i) + sum(dec_data ~= data)/N;

        % Equalise Rayleigh faded + AWGN signal
        rx_AWGN_h = rx_AWGN_h./h;
        % Demodulate Rayleigh faded + AWGN signal and calculate BER
        y = pskdemod(rx_AWGN_h, 2, pi);
        BER_AWGN_h(i) = BER_AWGN_h(i) + sum(dec_data ~= data)/N;
    end
end

% Divide sum of BERs by iterations to find average BERs
BER_AWGN = BER_AWGN./iterations(end);
BER_AWGN_h = BER_AWGN_h./iterations(end);

SNR_linear = 10.^(SNR/10);

AWGN_t = plot(SNR, 0.5*erfc(sqrt(SNR_linear)), 'color', 'blue');
hold on 
AWGN_h_t = plot(SNR, 0.5*(1 - sqrt(SNR_linear./(1+SNR_linear))), 'color','blue','LineStyle','-.');
AWGN_s = scatter(SNR, BER_AWGN, 50, 'red', 'filled');
AWGN_h_s = scatter(SNR, BER_AWGN_h, 50, 'black', 'Marker','d');
set(gca, 'yscale', 'log');
set(gcf, 'color', 'w');
xlabel('SNR (dB)');
ylabel('BER');
legend([AWGN_t AWGN_h_t AWGN_s(1) AWGN_h_s(1)], {'Theoretical BER (AWGN)', 'Theortical BER (AWGN + Rayleigh fading)', 'Simulated BER (AWGN)', 'Simulated BER (AWGN + Rayleigh Fading)'});
