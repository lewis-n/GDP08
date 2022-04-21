clear all;
N = 10^6; %number of signal bits
SNR_dB = 0:18; %different signal noise ratio
in = randn(1,N)>0.5; %input signal
bits = 4; %bits per symbol
%modulation
%group the input in 4 bits
for ii = 1:4:N
    %A is MSB %D is LSB
    A = in(ii);
    B = in(ii+1);
    C = in(ii+2);
    D = in(ii+3);
    %karnaugh map is used to create formula according to constellation diagram
    %Boolean expression of C in 2(C)-1 is A|B, A, and B'A, same for C D
    IN((ii+3)/4) = ((A|B)*2-1)*j +(A*2-1)*j +((~B*A)*2-1)*j +((C|D)*2-1) + (C*2-1) + ((~D*C)*2-1);
end

%different SNR
for ii = 1:length(SNR_dB)
  count = 1;
  s = (1/sqrt(10))*IN; % normalization of energy to 1
  n = 1/sqrt(2)*[randn(1,length(IN)) + j*randn(1,length(IN))]; % white guassian noise, 0dB variance
  OUT = s + 10^(-SNR_dB(ii)/20)*n; % AWGN
  %OUT = IN*(1/sqrt(10));
%demodulation
  for mm = 1:length(OUT)
     %hard decision demodulation
     out(count) = imag(OUT(mm))>0;
     out(count+1) = abs(imag(OUT(mm)))<(2/sqrt(10));
     out(count+2) = real(OUT(mm))>0;
     out(count+3) = abs(real(OUT(mm)))<(2/sqrt(10));
     count = count + 4;
  end
  
ERR(ii) = length(find(in - out)); % couting the number of errors
end

err = ERR/N; %error rate

%theoratical 
QAM16_t = 3/2*erfc(sqrt(0.1*(10.^(SNR_dB/10))))/bits;

%plot graph
close all
figure
semilogy(SNR_dB,QAM16_t,'b.-');
hold on
semilogy(SNR_dB,err,'mx-');
grid on
legend('theory-16QAM', 'simulation-16QAM');
xlabel('Es/No, dB')
ylabel('Symbol Error Rate')
title('16QAM simulation')
