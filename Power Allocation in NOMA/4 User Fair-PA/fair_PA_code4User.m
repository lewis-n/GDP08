clc;
clear variables;
close all;

U1_pow = 0.5; U2_pow = 0.25;
U3_pow = 0.125; U4_pow = 0.0625;   % ratio = 0.5
max_bpow = U1_pow + U2_pow + U3_pow + U4_pow;
N_data = 10^5;
Rf = 0.5:0.5:10;                  % 20 elements in Rf
N0 = 3.9811E-15;                  % noise power

U1 = 1000;  % farthest user
U2 = 500;
U3 = 250;
U4 = 125;

pow_1 = zeros(1,length(Rf));        
pow_2 = zeros(1,length(Rf));
pow_3 = zeros(1,length(Rf));
pow_4 = zeros(1,length(Rf));

eta = 4;

rayleigh_1 = sqrt(U1^-eta)*(randn(1,N_data) + 1i*randn(1,N_data))/sqrt(2);
rayleigh_2 = sqrt(U2^-eta)*(randn(1,N_data) + 1i*randn(1,N_data))/sqrt(2);
rayleigh_3 = sqrt(U3^-eta)*(randn(1,N_data) + 1i*randn(1,N_data))/sqrt(2);
rayleigh_4 = sqrt(U4^-eta)*(randn(1,N_data) + 1i*randn(1,N_data))/sqrt(2);
m_1 = (abs(rayleigh_1)).^2;
m_2 = (abs(rayleigh_2)).^2;
m_3 = (abs(rayleigh_3)).^2;
m_4 = (abs(rayleigh_4)).^2;

for x = 1:length(Rf)
    beta = (2^(Rf(x)))-1;         

    SNR_1 = max_bpow*U1_pow.*m_1./(max_bpow*m_1.*U4_pow + N0);
    SNR_2 = max_bpow*U2_pow.*m_2./(max_bpow*m_2.*U4_pow + N0);
    SNR_3 = max_bpow*U3_pow.*m_3./(max_bpow*m_3.*U4_pow + N0);
    SNR_4 = max_bpow*U4_pow.*m_4./(max_bpow*m_4.*U4_pow + N0);
    SNR_n = max_bpow*m_4.*U4_pow/N0;

    Cg_1 = log2(1 + SNR_1);         % channel capacity
    Cg_2 = log2(1 + SNR_2);
    Cg_3 = log2(1 + SNR_3);
    Cg_4 = log2(1 + SNR_4);
    Cg_n = log2(1 + SNR_n);

    for y = 1:N_data
        if Cg_1(y) < Rf(x)
            pow_1(x) = pow_1(x) + 1;
        else
            if Cg_2(y) < Rf(x)
            pow_2(x) = pow_2(x) + 1;
        else
            if Cg_3(y) < Rf(x)
            pow_3(x) = pow_3(x) + 1;
        else
            if Cg_4(y) < Rf(x)
            pow_4(x) = pow_4(x) + 1;
            end
            end
            end
        end
    end
end

outage_1 = pow_1/N_data;
outage_2 = pow_2/N_data;
outage_3 = pow_3/N_data;
outage_4 = pow_4/N_data;

figure;
plot(Rf,outage_1,'b','linewidth',2); 
hold on; 
grid on;
plot(Rf,outage_2,'g','linewidth',2);
hold on; 
grid on;
plot(Rf,outage_3,'r','linewidth',2);
hold on; 
grid on;
plot(Rf,outage_4,'c','linewidth',2);
xlabel('Far user Target Rate (R*) in bps/Hz');
ylabel('Outage Probability (OP)');
xlim([Rf(1) Rf(end)]);
legend('U1 (farthest)','U2','U3','U4 (nearest)');
