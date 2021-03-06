classdef Cprocessador < Cpaciente & CsinalEntrada
    %% Classe responsavel pelo processamento do IC
    %   
    
    properties 
        Csinal_processador % Classe com sinais de cada bloco de processamento
        tipo_filtro = 0 % Tipo de filtro para o banco do IC: 0 - ERB / 1 - Nucleus
        tipo_env = 0 % Tipo de extracao da envoltoria: 0 - Hilbert / 1 - Retificacao
        fcorte_fpb = 400; % Frequencia de corte do FPB apos retificacao
        ordem_fpb = 4; % Ordem do FPB apos retificacao
        taxa_est = 1000 % Taxa de estimulacao do gerador de pulsos
        quant_bits = 8 % Numero de bits para divisao da faixa dinamica
        fase_pulso = 0 % Fase inicial do pulso (meia onda 1): 0 - Catodico(-) / 1 - Anodico 
        atraso = 0; % Atraso do envelope entre canais: 0 (sem atraso) ou 1 (com atraso)
        paciente = 'padrao' % Utilizacao das informacoes do 'paciente padrao' da clase
        baixa_freq = 150 % Frequencia central do primeiro filtro do banco de reconstituicao
        
        tipo_pulso = 0 % Formato de pulso eletrico: 0 - Bifasico
        max_corr = 1.75e-3 % Maxima corrente do gerador
        ERB_bandas % Largura das bandas filtro Gammatone ERB
        ERB_cf % Frequencias centrais filtro Gammatone ERB
    end
    
    properties (Dependent)
        dt % Intervalo de tempo entre pontos no arquivo de entrada
        T_total % Tempo total do arquivo de entrada      
        num_bits % Numero de bits do arquivo de entrada 
        vet_tempo % Vetor temporal do arquivo de entrada
        max_corr_paciente % Corrente maxima suportada pelo paciente
    end
    
    methods % Funcoes da Classe
        function obj = Cprocessador(arquivo_dat, varargin)
            % varargin = {arquivo .wav de audio alvo, arquivo .wav do ruido, SNRdB}            
            obj@Cpaciente(arquivo_dat);
            obj@CsinalEntrada(varargin{:});
        end 
        
%% GET (Definicao das variaveis dependentes)      
                
        function val = get.dt(obj)
                val = 1/obj.freq_amost;
        end
        
        function val = get.T_total(obj)
                var = audioinfo(obj.arqX);
                val = var.Duration;
        end
        
        function val = get.vet_tempo(obj)
                val = obj.dt:obj.dt:obj.T_total;
        end      
        
        function val = get.num_bits(obj)
                var = audioinfo(obj.arqX);
                val = var.BitsPerSample;
        end
        
        function val = get.max_corr_paciente(obj)
                val = obj.max_corr*(1e-2)*10.^(obj.C_Level/(2^obj.num_bits-1));
        end
        
%% OUTRAS FUNCOES

        function openwav(obj) % Importa o sinal de entrada da classe CsinalEntrada
            obj.Csinal_processador.in = obj.Smescla;
        end

%         function play(obj) % Reproducao do sinal de entrada
%             sound(obj.Csinal_processador.in,obj.freq_amost)          
%         end
%         FUNCAO SUBSTITUIDA PELA FUNCAO 'reproduz_audio' DA CLASSE CsinalEntrada
        
        
%% BLOCOS

        function filtros(obj) % Banco de filtros do IC
            switch(obj.tipo_filtro)
                
                case 0 % Equivalent Rectangular Bandwidth (ERB)
                [obj.Csinal_processador.filt, obj.ERB_bandas, obj.ERB_cf] = cochlearFilterBank(...
                    obj.freq_amost, obj.num_canais, obj.baixa_freq, obj.Csinal_processador.in);
                
                case 1 % Nucleus (Cochlear)
                    if obj.num_canais ~= 22
                        error('O banco de filtros do Nucleus Freedom funciona apenas para 22 canais!')
                    else
                    obj.Csinal_processador.filt = CIFilterBank(...
                        obj.freq_amost, obj.num_canais,obj.central_freq(1),...
                        obj.Csinal_processador.in);
                    end
                 otherwise
                    error('Somente as seguintes opcoes: 0 - ERB / 1 - Nucleus');
            end
        end 
    
        function ext_env(obj) % Extracao da envoltoria dos canais
            obj.Csinal_processador.env = ext_env(obj.Csinal_processador.filt,...
                obj.tipo_env,obj.fcorte_fpb,obj.freq_amost,obj.ordem_fpb);
        end
        
        function comp(obj) % Compressao das envoltorias de acordo com o mapeamento
            obj.Csinal_processador.comp = comp(obj.Csinal_processador.env,...
                obj.fat_comp,obj.C_Level,obj.T_Level);         
        end
       
        function ger_pulsos(obj) % Geracao dos pulsos para CIS ou ACE (amplitude e instante no tempo)       
            obj.Csinal_processador.amp_pulsos = ger_pulsos(obj.Csinal_processador.comp,obj.num_canais,...
                obj.maxima,obj.freq_amost,obj.T_total,obj.taxa_est,obj.tipo_pulso,obj.largura_pulso1,...
                obj.largura_pulso2,obj.interphase_gap,obj.fase_pulso,obj.atraso,obj.max_corr,...
                obj.quant_bits,obj.T_Level,obj.C_Level);                   
        end
                                                  
        function cis_ace(obj) % Processamento das estrategias CIS e ACE
            openwav(obj)
            filtros(obj)
            ext_env(obj)
            comp(obj)
            ger_pulsos(obj)
        end                     
        
    end
end
   
    
        

