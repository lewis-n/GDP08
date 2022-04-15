h1 = 1; % 0dB
h2 = 10; % 20dB

R1_NOMA = [];
R2_NOMA = [];
R1_MAX_OMA = [];
R2_MAX_OMA = [];

for a1 = 0:0.0001:1
    a2 = 1 - a1;
    W = a1;
    R1_NOMA(end+1) = log2(  1 + (a1*(h1^2))/(a2*(h1^2) + 1)  );
    R2_NOMA(end+1) = log2(  1 + (a2*(h2^2))/(1)  );
    
    % Bandwidth proportional to power allocated
    R1_MAX_OMA(end+1) = (W)*log2( 1 + (a1*(h1^2))/W );
    R2_MAX_OMA(end+1) = (1-W)*log2( 1 + (a2*(h2^2))/(1-W) );
end

a1 = 0:0.0001:1;
p1 = 1;
p2 = find(a1 == 0.5);
p3 = find(a1 == 0.9);
p4 = find(a1 == 1);

plot(R2_NOMA, R1_NOMA);
hold
plot(R2_MAX_OMA, R1_MAX_OMA, "Color", 'red', 'LineStyle','--');
xlabel('Rate of user 2 (bps/Hz)');
ylabel('Rate of user 1 (bps/Hz)');
plot([R2_NOMA(p1) R2_NOMA(p2) R2_NOMA(p3) R2_NOMA(p4)], [R1_NOMA(p1) R1_NOMA(p2) R1_NOMA(p3) R1_NOMA(p4)], 'k.', 'MarkerSize',15)
legend('NOMA', 'OMA');
labelpoints([R2_NOMA(p1) R2_NOMA(p2) R2_NOMA(p3) R2_NOMA(p4)], [R1_NOMA(p1) R1_NOMA(p2) R1_NOMA(p3) R1_NOMA(p4)], {'α_1 = 0', 'α_1 = 0.5', 'α_1 = 0.9', 'α_1 = 1'}, 'NE', 0.2, 1, 'interpreter', 'latex');
grid on