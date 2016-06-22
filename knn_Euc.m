function salida = knn_Euc (inputs, outputs, vector, k) 

    [N_Desc N_Obj] = size(inputs);
    
    distancia_euclidea = zeros(N_Obj,1);
    for i=1:N_Obj
        distancia_euclidea(i) = -(vector - inputs(:,i))' * (vector - inputs(:,i));
    end
    
    [ Dist_sort Indx_Nsort ] = sort(distancia_euclidea,'descend');
    
    
    salida = tabulate(outputs(Indx_Nsort(1:k)));
    salida = salida(end, 1);

end
