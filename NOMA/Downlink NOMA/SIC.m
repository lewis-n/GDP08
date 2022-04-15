function x_decoded = SIC(y, a, p, mpskmod, mpskdemod)

    %  Successive Interference Cancellation function
    %
    %  Returns a matrix of decoded signals
    %
    %  y - Matrix of signals received at each user, cols are user signals
    %  a - Array of power allocation coefficients for each user
    %  p - Total transmission power
    %  mpskmod, mpskdemod - PSK modulation and demodulation objects
    %  Imperfect (optional) - Use imperfect SIC

    arguments
        y 
        a double {mustBeInRange(a, 0, 1), mustBeFloat}
        p double {mustBePositive}
        mpskmod
        mpskdemod
    end

    % Direct decoding of first signal
    x_decoded(:,1) = mpskdemod(y(:,1));
    
    % Perform SIC on remaining signals
    for i = 2:size(y,2)
        
        for j = 2:i
            x = mpskmod(mpskdemod(y(:,i)));
            y(:,i) = y(:,i) - (sqrt(a(j-1)*p))*x;
        end

        x_decoded(:,i) = mpskdemod(y(:,i));

    end
end

% 