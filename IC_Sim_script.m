%% Simulacao do sinal no implante coclear
nome_in = {'seno_1k', 'seno_5k', 'chirp_125_125e2' , 'ruido_branco_16k', 'ch�o_16k'};    
fc = [0.24 0.63 1];
pc = [1:7 9];

for i = 1:length(nome_in)
    for j = 1:length(fc)
        for k = 1:length(pc)
            
%clear classes
%clear all
close all
%clc
addpath(genpath('./funcoes'))
addpath(genpath('./SRMRToolbox-master'))
addpath(genpath('./wideband'))
addpath(genpath('./sinais_entrada'))
addpath(genpath('./dados_pacientes'))
% fs = 16e3;
% resamp_audio('fiz.wav','./monossilabas/fiz_16k.wav',fs)

nome_in = {'seno_1k', 'seno_5k', 'chirp_125_125e2' , 'ruido_branco_16k', 'ch�o_16k'};    
fc = [0.24 0.63 1];
pc = [1:7 9];
        
            
%% Processador

sim = Cprocessador(char(strcat(nome_in(i),'.wav')), strcat('p_cochlear_',num2str(pc(k)),'.dat'));
sim.num_canais = 22;
sim.maxima = 8;
sim.taxa_est = 900;
sim.tipo_env = 'Hilbert';
% sim.largura_pulso1 = 25e-6;
% sim.largura_pulso2 = 35e-6;
% sim.interphase_gap = 8e-6;
sim.fat_comp = fc(j);

tic
sim.cis_ace();
toc
%%
% figure(1)
% %plot(sim.vet_tempo,sim.Csinal_processador.comp(20,:)')
% xlim([0.3 0.4])
% ylim([130 200])
% %plot(sim.Csinal_processador.corr_onda.E22(:,2)')
% hold on
% xlabel('t(s)')
% ylabel('UC(1-255)')
% legend('1','0,6','0,2','Location','NorthWest')

%% Reconstru��o 

% data = Creconst(sim);
% data.nome_reconst = nome_in;
% % data.carrier = 'Harmonic Complex';
% % data.vocoder(1);
% % % data.lambda = lc(il);
% % sim.corr_esp = 'Exp';
% data.NF = 20;
% % data.dtn_A = 35e-3;
% % data.N_neurons = 50;
% % data.neural_vocoder(1);
% data.calcOndas();
% % figure(2)
% % plot(data.tempo,data.ondas(:,:))
% % xlabel('t(s)')
% % ylabel('corrente (A)')
% % xlim([0.498 0.5])
% % ylim([-sim.max_corr sim.max_corr])
% %hold on
%%
% figure(1)
% plot(sim.amp_corr_T,'-or')
% xlabel('canal')
% ylabel('UC (1-255)')
% %ylim([100 250])
% hold on
% plot(sim.amp_corr_C,'-or')
%legend('p1 (T-level)','p1 (C-level)','p3 (T-level)','p3 (C-level)','Location','NorthEast')

%% Reconstru��o Neural-vocoder

% close all
% figure(2)
% plot(sim.vet_tempo,sim.Csinal_processador.in)
% xlabel('Tempo(s)')
% ylabel('Amplitude')
% 
% [y,x] = find(sim.Spike_matrix);
% x = x/(2*data.freq2);
% figure(1)
% plot(x,y,'.k','MarkerSize',2)
% %xlim([0 0.251])
% ylim([0 max(y)])
% xlabel('Tempo(s)')
% ylabel('Neur�nio "n" (da base ao �pice)')
% set(gca,'Ydir','reverse')


% AP
% x_Ap = (1:size(data.Ap,2))*data.dtn_A/2;
% y_Ap = 1:size(data.Ap,1);
% figure(3);
% % subplot(2,1,1)
% surface(x_Ap,y_Ap,data.Ap,'EdgeColor','none')
% c=colorbar
% colormap(jet)
% ylim([1 22])
% %caxis([0 5])
% xlim([data.dtn_A max(x_Ap)])
% xlabel('Tempo(s)')
% ylabel('Popula��o no eletrodo "N" (da base ao �pice)')
% ylabel(c,'Taxa de disparos (spikes/s)')
% view(0, 270)
%set(gca,'Ydir','reverse')

%% Etapas dos sinais

% n = 1;
% 
% figure(1)
% subplot(4,1,1)
% plot(sim.vet_tempo,sim.Csinal_processador.filt(n,:))
% xlim([0 max(sim.vet_tempo)])
% subplot(4,1,2)
% plot(sim.vet_tempo,sim.Csinal_processador.env(n,:))
% xlim([0 max(sim.vet_tempo)])
% subplot(4,1,3)
% plot(sim.vet_tempo,sim.Csinal_processador.comp(n,:))
% xlim([0 max(sim.vet_tempo)])
% subplot(4,1,4)
% vn = strcat('E',num2str(n));
% tc = sim.Csinal_processador.corr_onda.(vn);
% plot(tc(:,1),tc(:,2))
% xlim([0 max(sim.vet_tempo)])
% 
% n = 8;
% 
% figure(2)
% subplot(4,1,1)
% plot(sim.vet_tempo,sim.Csinal_processador.filt(n,:))
% xlim([0 max(sim.vet_tempo)])
% subplot(4,1,2)
% plot(sim.vet_tempo,sim.Csinal_processador.env(n,:))
% xlim([0 max(sim.vet_tempo)])
% subplot(4,1,3)
% plot(sim.vet_tempo,sim.Csinal_processador.comp(n,:))
% xlim([0 max(sim.vet_tempo)])
% subplot(4,1,4)
% vn = strcat('E',num2str(n));
% tc = sim.Csinal_processador.corr_onda.(vn);
% plot(tc(:,1),tc(:,2))
% xlim([0 max(sim.vet_tempo)])
% 
% n = 16;
% 
% figure(3)
% subplot(4,1,1)
% plot(sim.vet_tempo,sim.Csinal_processador.filt(n,:))
% xlim([0 max(sim.vet_tempo)])
% subplot(4,1,2)
% plot(sim.vet_tempo,sim.Csinal_processador.env(n,:))
% xlim([0 max(sim.vet_tempo)])
% subplot(4,1,3)
% plot(sim.vet_tempo,sim.Csinal_processador.comp(n,:))
% xlim([0 max(sim.vet_tempo)])
% subplot(4,1,4)
% vn = strcat('E',num2str(n));
% tc = sim.Csinal_processador.corr_onda.(vn);
% plot(tc(:,1),tc(:,2))
% xlim([0 max(sim.vet_tempo)])
% 

%% Eletrodograma

canal_min = 1;
canal_max = sim.num_canais;
%figure
for n = 1:canal_max
h = subplot(canal_max-canal_min+1,1,n);
vn = strcat('E',num2str(n));
tc = sim.Csinal_processador.corr_onda.(vn);
stem(tc(:,1),tc(:,2),'k','Marker','none');
ylim([0 sim.max_corr])
%ylim([0 1.25*abs(max(tc(:,2)))])
%ylim([0 sim.max_corr_paciente(n)])
set(h,'XTick',[])
set(h,'YTick',[])
set(h,'FontSize',8)
ylabel(strcat('',num2str(n)))
if n == canal_max
    set(h,'XTick',0:0.05:max(sim.vet_tempo),'TickDir','out')
    xlim([0 max(sim.vet_tempo)])
    xlabel('t(s)')
end
suplabel('N�mero do eletrodo','y',[.125 .125 .8 .8]);
end
print(char(strcat('./resultados eletrodograma/EG_',nome_in(i),'_p',num2str(pc(k)),'_fc',num2str(j))),'-depsc')
print(char(strcat('./resultados eletrodograma/EG_',nome_in(i),'_p',num2str(pc(k)),'_fc',num2str(j))),'-dpng')
        end
    end
end

%% Espectrograma FFT

% [y, f, t, p] = spectrogram(sim.Csinal_processador.in,128,120,128,sim.freq_amost,'yaxis');
% figure(3);
% surf(t,f,10*log10(abs(p)),'EdgeColor','none');
% axis xy; 
% axis tight;
% %set(gca,'Yscale','log')
% % set(gca,'XTick',[])
% % set(gca,'YTick',[])
% ylim([2e1 8e3])
% colormap(jet);
% view(0,90);
% ylabel('Frequency (Hz) ');
% xlabel('Time ');

%% Espectrograma Wavelet
% 
% figure(5)
% level = 6;
% wpt = wpdec(sim.Csinal_processador.in,level,'sym8');
% [Spec,Time,Freq] = wpspectrum(wpt,sim.freq_amost);%,'plot');
% surf(Time,fliplr(Freq),10*log10(abs(Spec)),'EdgeColor','none');
% axis xy; 
% axis tight;
% %set(gca,'Yscale','log')
% % set(gca,'XTick',[])
% % set(gca,'YTick',[])
% % ylim([2e2 8e3])
% colormap(jet);
% view(0,90);


