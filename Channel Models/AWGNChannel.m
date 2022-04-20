function out = AWGNChannel(s, EbNo_dB, k)
    %   Returns AWGN noise samples corresponding to Eb/No
    %   Assumes 1 sample per symbol
    %   s - input signal (each column represents a channel)
    %   EbNo - SNR per bit in decibels
    %   k - bits per symbol

    EbNo = 10^(EbNo_dB/10); % Convert EbNo(dB) to linear EbNo
    Eb = (sum(abs(s).^2)/length(s))/k; % Calculate energy per bit
    sigma = sqrt((Eb/EbNo)/2); % Calculate No and normalise; convert to amplitude
    n = sigma.*(randn(length(s), width(s))+1i*randn(length(s), width(s))); % Calculate noise samples
    
    out = s + n;
end