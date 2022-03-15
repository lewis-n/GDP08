clc;
clear variables;
close all;

max_bpow = 1;
N_data = 10^5;
Rf = 0.5:0.5:10;                  % 20 elements in Rf
N0 = 3.9811E-15;                  % noise power

far_dist = 1000; 
near_dist = 500;

pow_1 = zeros(1,length(Rf));        
pow_2 = zeros(1,length(Rf));

eta = 4;

rayleigh_f = sqrt(far_dist^-eta)*(randn(1,N_data) + 1i*randn(1,N_data))/sqrt(2);
rayleigh_n = sqrt(near_dist^-eta)*(randn(1,N_data) + 1i*randn(1,N_data))/sqrt(2);
m_f = (abs(rayleigh_f)).^2;
m_n = (abs(rayleigh_n)).^2;

for x = 1:length(Rf)
    beta = (2^(Rf(x)))-1;         

    alpha_f = beta*(N0 + max_bpow*m_f)./(max_bpow*m_f*(1+beta));
    alpha_f(alpha_f>1) = 0;
    alpha_n = 1 - alpha_f;

    SNR_f = max_bpow*alpha_f.*m_f./(max_bpow*m_f.*alpha_n + N0);
    SNR_mid = max_bpow*alpha_f.*m_n./(max_bpow*m_n.*alpha_n + N0);
    SNR_n = max_bpow*m_n.*alpha_n/N0;

    Cg_f = log2(1 + SNR_f);         % channel capacity
    Cg_mid = log2(1 + SNR_mid);
    Cg_n = log2(1 + SNR_n);

    for y = 1:N_data
        if Cg_f(y) < Rf(x)
            pow_1(x) = pow_1(x) + 1;
        end
        if alpha_f(y) ~= 0
            if (Cg_n(y) < Rf(x)) || (Cg_mid(y) < Rf(x))
                pow_2(x) = pow_2(x) + 1;
            end
        else
            if Cg_n(y) < Rf(x)
                 pow_2(x) = pow_2(x) + 1;
            end
        end
    end
end

outage_1 = pow_1/N_data;
outage_2 = pow_2/N_data;

figure;
plot(Rf,outage_1,'b','linewidth',2); 
hold on; 
grid on;
plot(Rf,outage_2,'g','linewidth',2);
xlabel('Far user Target Rate (R*) in bps/Hz');
ylabel('Outage Probability (OP)');
xlim([Rf(1) Rf(end)]);
legend('Far user (fair PA)','Near user (fair PA)');
