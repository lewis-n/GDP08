clear all;
N = 10^6;
SNR_dB = 0:12;
in = randn(1,N)>0.5;
%modulation
for ii = 1:N
    if(mod(ii,2)==0)
       IN(ii/2) = (in(ii)*2-1)*j + (temp*2-1);
    else
        temp = in(ii);
    end
end

%different SNR
for ii = 1:length(SNR_dB)
  count = 1;
  s = (1/sqrt(2))*IN; % normalization of energy to 1
  n = 1/sqrt(2)*[randn(1,length(IN)) + j*randn(1,length(IN))]; % white guassian noise, 0dB variance
  OUT = s + 10^(-SNR_dB(ii)/20)*n; % additive white gaussian noise

 %demodulation
  for mm = 1:length(OUT)
     out(count) = real(OUT(mm))>0;
     out(count+1) = imag(OUT(mm))>0;
     count = count + 2;
  end
ERR(ii) = length(find(in - out)); % couting the number of errors
end

err = ERR/N;
QPSK_t = 0.5*(erfc(sqrt(0.5*(10.^(SNR_dB/10)))) - (1/4)*(erfc(sqrt(0.5*(10.^(SNR_dB/10))))).^2);

close all
figure
semilogy(SNR_dB,QPSK_t,'b.-');
hold on
semilogy(SNR_dB,err,'mx-');
grid on
legend('theory-QPSK', 'simulation-QPSK');
xlabel('Es/No, dB')
ylabel('Symbol Error Rate')
title('Symbol error probability curve for QPSK')
