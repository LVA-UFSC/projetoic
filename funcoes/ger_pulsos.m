function saida = ger_pulsos(entrada,num_canais,maxima,freq_amost,T_total,taxa_est,tipo_pulso,largura_pulso,interphase_gap,fase_pulso,atraso,max_corr,quant_bits)

            if strcmp(fase_pulso,'Catodico') == 1 
                fase = 1;
            elseif strcmp(fase_pulso,'Anodico') == 1
                fase = -1;
            end
                                    
            t = 0;
            
%% Estrategia CIS            
            
      if num_canais == maxima          
            
            if num_canais*taxa_est < freq_amost            
                for i = 1:num_canais
                    resamp(i,:) = resample(entrada(i,:), num_canais*taxa_est,freq_amost);               
                end
            elseif num_canais*taxa_est > freq_amost
                error('Erro: frequencia de amostragem menor do que o produto do numero de canais pela taxa de estimulacao!')
                stop
            else
                resamp = entrada;
            end
            
            a = 1;        

                for j = 1:num_canais:T_total*taxa_est*num_canais - num_canais + 2                   
                    n = 0;                         
                    for i = num_canais:-1:1                        
                        if strcmp(tipo_pulso,'Bifasico') == 1                            
                                saida.(strcat('E',num2str(i)))(a,:) = [t , fase*(max_corr/(2^quant_bits-1))*resamp(i,j + n)]; 
                                t = t + largura_pulso + interphase_gap;
                                saida.(strcat('E',num2str(i)))(a + 1,:) = [t , -fase*(max_corr/(2^quant_bits-1))*resamp(i,j + n)];                                
                                t = t - (largura_pulso + interphase_gap) + 1/(num_canais*taxa_est);                       
                        end                       
                        if atraso == 0
                           n = n + 1;
                        end                        
                    end                    
                    a = a + 2;
                end              
      else          
%% Estrategia ACE              
      
          if maxima*taxa_est < freq_amost            
                for i = 1:num_canais
                    resamp(i,:) = resample(entrada(i,:), num_canais*taxa_est,freq_amost);               
                end
          elseif maxima*taxa_est > freq_amost
                error('Erro: frequencia de amostragem menor do que o produto do numero de maxima pela taxa de estimulacao!')
                stop
          else
                resamp = entrada;
          end
            
           for i = num_canais:-1:1 
               a(i) = 1;
           end                 
                for j = 1:maxima:T_total*taxa_est*num_canais - maxima + 2                                          
                    
                    maxima_vet = zeros(1,num_canais);
                    for i = num_canais:-1:1 
                       maxima_vet(i) = resamp(i,j);
                    end
                       [maxima1, maxima2] = sort(maxima_vet,'descend');
                       maxima_valor = maxima1(1:maxima);
                       maxima_canal = maxima2(1:maxima);
                       
                    for i = maxima:-1:1                        
                        if strcmp(tipo_pulso,'Bifasico') == 1                            
                                saida.(strcat('E',num2str(maxima_canal(i))))(a(maxima_canal(i)),:) = [t , fase*(max_corr/(2^quant_bits-1))*maxima_valor(i)]; 
                                t = t + largura_pulso + interphase_gap;
                                saida.(strcat('E',num2str(maxima_canal(i))))(a(maxima_canal(i)) + 1,:) = [t , -fase*(max_corr/(2^quant_bits-1))*maxima_valor(i)];                                
                                t = t - (largura_pulso + interphase_gap) + 1/(num_canais*taxa_est);                       
                                a(maxima_canal(i)) = a(maxima_canal(i)) + 2;
                        end                     
                    end
                    display('Numero de pulsos por canal ACE')
                    a
                end          
     end
end