function [h, n] = channel(BW, d, num_samples)
    %% Noise power for given bandwidth
    N0_dBm = -173.8 + 10*log10(BW);
    N0 = 10^(N0_dBm/10)/10^3;
    
    %% AWGN
    n = sqrt(N0/2)*(randn(num_samples, 1) + 1i*randn(num_samples, 1));
    
    %% Log distance path loss model
    % Approximate parameters for shadowed urban environment
    eta = 4; 
    sigma = 4;

    PL = sqrt(10^((10*eta*log10(d) + sigma*randn(1))/10)); % Path loss amplitude

    %% Rayleigh Fading
    R = sqrt(1/2)*(randn(num_samples, 1) + 1i*randn(num_samples, 1));
    
    %% Channel gain
    h = R/PL;
end
