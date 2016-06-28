classdef CsimIC < CmodeloNA
    %% CsimIC Classe para criacao do objeto de simulacao, reconstrucao do
    % sinal e avaliacao objetiva dos resultados
    
    properties
        nome_sinal_reconst % Nome do arquivo gerado para o sinal reconstruido
        audio_reconst % Sinal de audio reconstruido
        carrier = 'Senoidal'; % Carrier (sinal portador) do vocoder: 'Ruido', 'Senoidal' e 'HC'
        numhar_HC = 240; % Numero de harmonicos no complexo
        df_HC = 100; % Discretizacao do complexo harmonico
        F0_HC = 100; % Frequencia fundamental do complexo harmonico
        tipo_vocoder = 'Neural'; % 'Normal' ou 'Neural'
        tipo_espec = 'Wavelet'; % Tipo de espectograma: 'Wavelet', 'FFT'
        SRMR_NH % Valor da metrica SRMR-NH
        SRMR_IC % Valor da metrica SRMR-CI
        Intel_SRMR_NH % Previsao da inteligibilidade para a metrica SRMR-NH
        Intel_SRMR_IC % Previsao da inteligibilidade para a metrica SRMR-CI
    end

    
    methods
        function obj = CsimIC(arquivo_dat,varargin) % Funcao geral da Classe
            % varargin = {arquivo .wav de audio alvo, arquivo .wav do ruido, SNRdB}
            obj@CmodeloNA(arquivo_dat,varargin{:});
        end
       
        function vocoder(obj,flag) % Reconstrucao atraves do vocoder: 'Normal' ou 'Neural'
            if (max(obj.ERB_cf) + max(obj.ERB_bandas)/2)*2 > obj.freq_amost
                display('A condicao (max(obj.ERB_cf) + max(obj.ERB_bandas)/2)*2 <= obj.freq_amost deve ser seguida');
                error('Frequencia de amostragem baixa para os filtros de alta frequencia!!!');             
            else
                
            switch(obj.tipo_vocoder)
                
                case 'Normal'
                obj.audio_reconst = vocoder(obj.Csinal_processador.env,obj.freq_amost,...
                obj.carrier, obj.baixa_freq, obj.vet_tempo,...
                obj.F0_HC,obj.df_HC,obj.numhar_HC);
                    if flag == 1
                        obj.nome_sinal_reconst = obj.arqX;
                        nv = strcat('_Vocoder_',obj.carrier,'.wav');
                        audiowrite(char(strcat(obj.nome_sinal_reconst,nv)),obj.audio_reconst,obj.freq_amost)
                    end
                    
                case 'Neural'
                    obj.audio_reconst = neural_vocoder(obj.Ap,obj.freq_amost,obj.carrier,obj.dtn_A,obj.pos_eletrodo,...
                    obj.baixa_freq, obj.F0_HC, obj.df_HC, obj.numhar_HC);
                    if flag == 1
                        obj.nome_sinal_reconst = obj.arqX;
                        nv = strcat('_Neural_Vocoder_',obj.carrier,'.wav');
                        audiowrite(char(strcat(obj.nome_sinal_reconst,nv)),obj.audio_reconst,obj.freq_amost)
                    end
            end
            
            end
        end
        
        
        function plotSpikes(obj) % Plota a matriz de disparos obtida com o modelo do NA
            [y,x] = find(obj.spike_matrix);
            x = x/(2*obj.freq_amost_pulsos);
            figure()
            plot(x,y,'.k','MarkerSize',2)
            ylim([0 max(y)])
            xlabel('Tempo(s)')
            ylabel('Neur�nio "n" (da base (0) ao �pice (N))')
            set(gca,'Ydir','reverse')
        end
        
        function plotEletrodograma(obj) % Plota o eletrodograma com a serie de pulsos
            canal_min = 1;
            canal_max = obj.num_canais;
            figure()
            for n = 1:canal_max
                h = subplot(obj.num_canais-canal_min+1,1,n);
                vn = strcat('E',num2str(n));
                tc = obj.Csinal_processador.amp_pulsos.(vn);
                stem(tc(:,1),tc(:,2),'k','Marker','none');
                ylim([0 obj.max_corr])
                set(h,'XTick',[])
                set(h,'YTick',[])
                set(h,'FontSize',8)
                set(h,'yscale','log')
                ylabel(strcat('',num2str(n)))
                if n == canal_max
                    set(h,'XTick',0:0.1:max(obj.vet_tempo),'TickDir','out')
                    xlim([0 max(obj.vet_tempo)])
                    xlabel('t(s)')
                end
            suplabel('N�mero do eletrodo','y',[.125 .125 .8 .8]);
            end
            
        end
        
        function plotEspectrograma(obj) % Plota o espectrograma do sinal de entrada
            switch obj.tipo_espec               
                case 'Wavelet'
                    figure()
                    level = 6;
                    wpt = wpdec(obj.Csinal_processador.in,level,'sym8');
                    [Spec,Time,Freq] = wpspectrum(wpt,obj.freq_amost);
                    surf(Time,fliplr(Freq),10*log10(abs(Spec)),'EdgeColor','none');
                    set(gca,'yscale','log')
                    axis xy; 
                    axis tight;
                    colormap(jet);
                    view(0,90);
                    ylabel('f(Hz)');
                    xlabel('t(s)'); 
                    
                case 'FFT'                    
                    figure();        
                    [p,f,t] = spectrogram(obj.Csinal_processador.in,256,120,256,obj.freq_amost,'yaxis');
                    surf(t,f,10*log10(abs(p)),'EdgeColor','none');
                    axis xy; 
                    axis tight;
                    set(gca,'yscale','log');
                    xlim([0 0.1])
                    ylim([0 8e3])
                    colormap(jet);
                    view(0,90);
                    ylabel('f(Hz)');
                    xlabel('t(s)');                 
            end
        end
        
        function plotNeurograma(obj) % Plota o neurograma obtido com o modelo do NA
                x_Ap = (1:size(obj.Ap,2))*obj.dtn_A/2;
                y_Ap = 1:size(obj.Ap,1);
                figure()
                surface(x_Ap,y_Ap,obj.Ap,'EdgeColor','none')
                c = colorbar;
                colormap(jet)
                ylim([1 obj.num_canais])
                xlim([obj.dtn_A max(x_Ap)])
                xlabel('Tempo(s)')
                ylabel('Popula��o no eletrodo "N" (da base ao �pice)')
                ylabel(c,'Taxa de disparos (spikes/s)')
                view(0, 270)
        end
        
        function plotFiltros(obj) % Plota o banco de filtros utilizado
             switch obj.tipo_filtro
                 case 'Gammatone'
                    np = 2048;
                    y = cochlearFilterBank(obj.freq_amost, obj.num_canais,obj.central_freq(1), [1 zeros(1,(np-1))]);
                    resp = 20*log10(abs(fft(y')));
                    freqScale = (0:(np-1))/np*obj.freq_amost;
                    figure()
                    semilogx(freqScale(1:(np/2-1)),resp(1:(np/2-1),:),'LineWidth',1);
                    axis([1e2 0.8e4 -80 0])
                    xlabel('Frequ�ncia (Hz)','FontSize',10);
                    ylabel('Resposta (dB)','FontSize',10); 
                 
                 case 'Nucleus'
                    np = 2048;
                    y = CIFilterBank(obj.freq_amost, obj.num_canais,obj.central_freq(1), [1 zeros(1,(np-1))]);
                    resp = 20*log10(abs(fft(y')));
                    freqScale = (0:(np-1))/np*obj.freq_amost;
                    figure()
                    semilogx(freqScale(1:(np/2-1)),resp(1:(np/2-1),:),'LineWidth',1);
                    axis([1e2 0.8e4 -80 0])
                    xlabel('Frequ�ncia (Hz)','FontSize',10);
                    ylabel('Resposta (dB)','FontSize',10);
             end
                    
        end
        
        function calcSRMR(obj) % Calcula os valores de SRMR-NH e SRMR-CI
                obj.SRMR_NH = SRMR(obj.audio_reconst,obj.freq_amost);
                obj.SRMR_IC = SRMR_CI(obj.audio_reconst,obj.freq_amost);
        end
        
        
        
    end
    
end

