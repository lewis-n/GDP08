function [output, noise] = AWGNChannel(s, EbNo_dB, k)
%   Applies AWGN to signal according to EbNo parameter
%   Assumes 1 sample per symbol
%   s - input signal
%   EbNo - SNR per bit in decibels
%   k - bits per symbol

    EbNo = 10^(EbNo_dB/10); % Convert EbNo(dB) to linear EbNo
    Eb = (sum(abs(s).^2)/length(s))/k; % Calculate energy per bit
    sigma = sqrt((Eb/EbNo)/2); % Calculate No and normalise; convert to amplitude
    noise = sigma*(randn(1,length(s))+1i*randn(1,length(s))); % Calculate noise samples
    output = s + noise; % Apply noise to signal

end