function saida = comp(entrada,fat_comp,quant_bits,amp_corr_C,amp_corr_T)

            comp_range = 0:1/(2^quant_bits-1):1;
            saida = zeros(size(entrada,1),size(entrada,2));
            
            for i = 1:size(entrada,1)
                entrada(i,:) = entrada(i,:)/max(entrada(i,:));
                saida(i,:) = quantiz(entrada(i,:), comp_range);                                
                saida(i,:) = ((saida(i,:)-1)/(2^quant_bits-1)).^fat_comp; 
                for j = 1:size(saida,2)
                    if saida(i,j) < amp_corr_T(i)/(2^quant_bits-1)
                        saida(i,j) = 0;
                    elseif saida(i,j) > amp_corr_C(i)/(2^quant_bits-1)
                        saida(i,j) = amp_corr_C(i);
                    end                                   
                end               
            end           
end