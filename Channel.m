
function [out_AWGN, out_AWGN_h, h] = Channel(tx, SNR_dB)

    %% AWGN Channel %%
    SNR_linear = 10^(SNR_dB/10);

    Es = (1/length(tx))*sum(abs(tx).^2); % Average power of signal
    noise = sqrt(Es/(2*SNR_linear))*(randn(1, length(tx)) + 1i*randn(1, length(tx)));
 
    out_AWGN = tx + noise;

    %% Rayleigh Fading %%
    % Multiplication by 1/sqrt(2) to normalise h
    h = (1/sqrt(2))*(randn(1, length(tx)) + 1i*randn(1, length(tx)));
    out_AWGN_h = (h.*tx) + noise;

end