classdef Cpaciente < handle 
    %% Classe para extracao das informacoes e dados de pacientes
    
    properties 
        arquivo_dat = './projetoic/dados_pacientes/p_cochlear_padrao' % Arquivo .dat com dados do paciente                       
        empresa = 'Cochlear' % Empresa que produz o dispositivo utilizado pelo paciente
        estrategia = 'ACE' % Estrategia de processamento do IC
        num_canais = 22 % Numero de canais do IC
        maxima = 8 % Selecao de n canais (maxima) por frame
        interphase_gap = 8e-6 % IPG - Intervalo entre as partes positiva e negativa do pulso
        largura_pulso1 = 25e-6 % Largura do pulso 1 (meia onda 1 sem contar o interphase gap)
        largura_pulso2 = 25e-6 % Largura do pulso 2 (meia onda 2 sem contar o interphase gap)
        fat_comp = 0.6 % Fator de compressao (expoente para a lei da potencia)
        LGF = 20 % Loudness Growth Function (Cochlear)
        T_SPL = 25 % NPS referente ao valor do limiar
        C_SPL = 65 % NPS referente ao valor do maximo conforto
        T_Level = 100*ones(22,1) % Limiar da amplitude de corrente por banda
        C_Level = 200*ones(22,1) % Maximo conforto para amplitude de corrente por banda
        inf_freq % Frequencias inferiores do banco de filtros
        sup_freq % Frequencias superiores do banco de filtros       
    end
    
    properties (Dependent)
        central_freq % Frequencias centrais do banco de filtros
        bandas_freq_entrada % Largura das bandas do banco de filtros
    end
    
    methods 
        function obj = Cpaciente(arquivo_dat)%,prop2,prop3)
            if nargin == 1
                
                obj.arquivo_dat = arquivo_dat;               
                %obj.empresa = dlmread(arquivo_dat,'\t',[3 2 3 2]);
                obj.num_canais = max(dlmread(arquivo_dat,'\t',[15 0 36 0]));
                obj.maxima = dlmread(arquivo_dat,'\t',[3 1 3 1]);
                obj.interphase_gap = mean(dlmread(arquivo_dat,'\t',[4 1 4 1]))*1e-6;
                obj.largura_pulso1 = mean(dlmread(arquivo_dat,'\t',[15 7 36 7]))*1e-6;
                obj.largura_pulso2 = mean(dlmread(arquivo_dat,'\t',[15 7 36 7]))*1e-6; 
                obj.T_SPL = dlmread(arquivo_dat,'\t',[8 1 8 1]);
                obj.C_SPL = dlmread(arquivo_dat,'\t',[9 1 9 1]);
                obj.T_Level = dlmread(arquivo_dat,'\t',[15 3 36 3]);
                obj.C_Level = dlmread(arquivo_dat,'\t',[15 4 36 4]);
                obj.inf_freq = dlmread(arquivo_dat,'\t',[15 9 36 9]);
                obj.sup_freq = dlmread(arquivo_dat,'\t',[15 10 36 10]);
                                
                a = dlmread(obj.arquivo_dat,'\t',[7 1 7 1]);           
                obj.LGF = a;              
                if a == 20
                    val = 0.24;
                elseif a == 30
                    val = 0.3;
                elseif a == 40
                    val = 0.51;
                elseif a == 50
                    val = 0.6;   
                else
                    error('Valor desconhecido do fator de compressao')
                end                   
                obj.fat_comp = val; 
                
            end
        
        end
%% GET     

          function val = get.bandas_freq_entrada(obj)
                val = obj.sup_freq - obj.inf_freq;
          end
        
          function val = get.central_freq(obj)
                val = (obj.sup_freq + obj.inf_freq)./2;
          end
                  
        
%% BLOCOS

        function media_paciente(obj,quantidade_media,excluir_media) % Calcula a media de um grupo de pacientes
            if strcmp(obj.empresa,'Cochlear')
            media_paciente_cochlear(quantidade_media,'./projetoic/dados_pacientes/p_cochlear_',excluir_media);
            else
                error('Dados de pacientes de outras empresas ainda nao foram adicionados')
            end
        end
    end       
end

