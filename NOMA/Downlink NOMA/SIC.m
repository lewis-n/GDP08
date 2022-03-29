function x_decoded = SIC(y, a, p, e)
 
    % Direct decoding of first signal
    x_decoded(1,:) = pskdemod(y(1,:), 2, pi);
    
    % Perform SIC on remaining signals
    for i = 2:size(y, 1)
        
        for j = 2:i
            x = pskmod(pskdemod(y(i,:), 2, pi), 2, pi);
            y(i,:) = y(i,:) - (1-sqrt(e))*(sqrt(a(j-1)*p))*x;
        end

        x_decoded(i,:) = pskdemod(y(i,:), 2, pi);

    end
end