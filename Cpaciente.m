classdef Cpaciente < handle 
    % Classe para extra��o das informa��es e dados de pacientes
    
    properties
        arquivo_dat = './dados_pacientes/p_cochlear_padrao' % Arquivo .dat com dados do paciente
        quantidade_media = 10 % quantidade_media de pacientes a ser considerada
        excluir_media = [7 8] % Exclusao de alguns pacientes
        modelo_arquivo_cochlear = './dados_pacientes/p_cochlear_' % Modelo do arquivo de dados para pacientes da cochlear       
        paciente_cochlear_media_matriz
        paciente_cochlear_media_vetor         
    end
    
    properties (Dependent)            
        empresa
        estrategia
        num_canais % Numero de canais do IC
        maxima % Selecao de n (maxima) canais por frame
        interphase_gap % Intervalo entre as partes positiva e negativa do pulso
        largura_pulso1 % Largura do pulso 1 (meia onda 1 sem contar o interphase gap)
        largura_pulso2 % Largura do pulso 2 (meia onda 2 sem contar o interphase gap)
        fat_comp = 0.6 % fator de compressao (expoente para a lei da potencia)
        T_SPL
        C_SPL
        amp_corr_T  % Limiar da amplitude de corrente por banda
        amp_corr_C % Maximo conforto para amplitude de corrente por banda
        inf_freq
        sup_freq
        central_freq
        bandas_freq_entrada
    end
    
    methods 
        function objeto = Cpaciente(prop1)%,prop2,prop3)
            if nargin == 1
                objeto.arquivo_dat = prop1;               
            end
%             if nargin == 3
%                 objeto.arquivo_dat = prop1; 
%                 objeto.quantidade_media = prop2;               
%                 objeto.excluir_media = prop3;
%             end            
        end
%% GET       
        function val = get.paciente_cochlear_media_matriz(objeto)    
            [val, ~] = media_paciente_cochlear(objeto.quantidade_media,objeto.modelo_arquivo_cochlear,objeto.excluir_media);
        end     

        function val = get.paciente_cochlear_media_vetor (objeto)    
            [~, val] = media_paciente_cochlear(objeto.quantidade_media,objeto.modelo_arquivo_cochlear,objeto.excluir_media);
        end 
        
        function val = get.empresa(objeto)
            if strcmp(objeto.arquivo_dat,'media') == 1
            val = 'Cochlear'; 
            else
            val = dlmread(objeto.arquivo_dat,'\t',[3 2 3 2]); 
            end
        end
        
        function val = get.num_canais(objeto)
            if strcmp(objeto.arquivo_dat,'media') == 1
            val = objeto.paciente_cochlear_media_vetor(1);
            else
            val = max(dlmread(objeto.arquivo_dat,'\t',[15 0 36 0]));
            end
        end
        
        function val = get.amp_corr_T(objeto)
            if strcmp(objeto.arquivo_dat,'media') == 1
            val = objeto.paciente_cochlear_media_matriz(:,3);
            else
            val = dlmread(objeto.arquivo_dat,'\t',[15 3 36 3]);
            end
        end
        
        function val = get.amp_corr_C(objeto)
            if strcmp(objeto.arquivo_dat,'media') == 1
            val = objeto.paciente_cochlear_media_matriz(:,4);
            else
            val = dlmread(objeto.arquivo_dat,'\t',[15 4 36 4]);
            end
        end
        
        function val = get.inf_freq(objeto)
            if strcmp(objeto.arquivo_dat,'media') == 1
            val = objeto.paciente_cochlear_media_matriz(:,9);
            else
            val = dlmread(objeto.arquivo_dat,'\t',[15 9 36 9]);
            end
        end
        
        function val = get.sup_freq(objeto)
            if strcmp(objeto.arquivo_dat,'media') == 1
            val = objeto.paciente_cochlear_media_matriz(:,10);
            else
            val = dlmread(objeto.arquivo_dat,'\t',[15 10 36 10]);
            end
        end
        
        function val = get.bandas_freq_entrada(objeto)
            val = objeto.sup_freq - objeto.inf_freq;
        end
        
        function val = get.central_freq(objeto)
            val = (objeto.sup_freq + objeto.inf_freq)./2;
        end
        
        function val = get.largura_pulso1(objeto)
            if strcmp(objeto.arquivo_dat,'media') == 1
            val = mean(objeto.paciente_cochlear_media_matriz(:,7));
            else
            val = mean(dlmread(objeto.arquivo_dat,'\t',[15 7 36 7]))*1e-6;
            end
        end
        
        function val = get.largura_pulso2(objeto)
            if strcmp(objeto.arquivo_dat,'media') == 1
            val = mean(objeto.paciente_cochlear_media_matriz(:,7));
            else
            val = mean(dlmread(objeto.arquivo_dat,'\t',[15 7 36 7]))*1e-6;
            end
        end
        
        function val = get.maxima(objeto)
            if strcmp(objeto.arquivo_dat,'media') == 1
            val = ceil(objeto.paciente_cochlear_media_vetor(2));
            else
            val = dlmread(objeto.arquivo_dat,'\t',[3 1 3 1]);
            end
        end
        
        function val = get.interphase_gap(objeto)
            if strcmp(objeto.arquivo_dat,'media') == 1
            val = objeto.paciente_cochlear_media_vetor(3);
            else
            val = mean(dlmread(objeto.arquivo_dat,'\t',[4 1 4 1]))*1e-6;
            end
        end
        
        function val = get.fat_comp(objeto)            
            if strcmp(objeto.arquivo_dat,'media') == 1
            a = objeto.paciente_cochlear_media_vetor(6);
            else
            a = dlmread(objeto.arquivo_dat,'\t',[7 1 7 1]);           
            end

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
        end
        
        function val = get.T_SPL(objeto)
            if strcmp(objeto.arquivo_dat,'media') == 1
            val = objeto.paciente_cochlear_media_vetor(7);
            else
            val = dlmread(objeto.arquivo_dat,'\t',[8 1 8 1]);
            end
        end
        
        function val = get.C_SPL(objeto)
            if strcmp(objeto.arquivo_dat,'media') == 1
            val = objeto.paciente_cochlear_media_vetor(8);
            else
            val = dlmread(objeto.arquivo_dat,'\t',[9 1 9 1]);
            end
        end
        
%% BLOCOS

        function media_paciente(objeto)
            if strcmp(objeto.empresa,'Cochlear')
            [objeto.paciente_cochlear_media_matriz, ~] = media_paciente_cochlear(objeto.quantidade_media,objeto.modelo_arquivo_cochlear,objeto.excluir_media);
            else
                error('Dados de pacientes de outras empresas ainda n�o foram adicionados')
            end
        end
    end       
end

