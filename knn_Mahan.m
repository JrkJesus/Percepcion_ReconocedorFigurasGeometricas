function salida = knn_Mahan (inputs, outputs, vector, k) 

    clases = unique(outputs);
    [N N_Class] = size(clases);
    [N_Desc N_Obj] = size(inputs);
    
    MCovarianzas = zeros(N_Desc,N_Desc);
    for i=1:N_Class
        MCovarianzas = MCovarianzas + cov( (inputs(:,outputs==clases(i)))', 1)*sum(outputs==clases(i));
    end
    MCovarianzas = MCovarianzas / N_Obj;
    
    distancia_mahanalois = zeros(N_Obj,1);
    for i=1:N_Obj
        distancia_mahanalois(i) = -(vector - inputs(:,i))'* pinv(MCovarianzas) * (vector - inputs(:,i));
    end
    
    [ Dist_sort Indx_Nsort ] = sort(distancia_mahanalois, 'descend');
    
    
    salida = tabulate(outputs(Indx_Nsort(1:k)));
    salida = salida(end, 1);

end