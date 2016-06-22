function Distancias = distancia_euclidea (inputs, outputs, incognitas) 
    
    Clases = unique(outputs);
    [N, N_Class] = size(Clases);
    [N_Desc, N_Obj] = size(inputs);
    
    Means = [];
    for clase=1:N_Class
        aux = [];
        for desc=1:N_Desc
            aux = [ aux mean(inputs(desc, outputs==Clases(clase))) ];
        end
        Means = [ Means; aux ];
    end
    Means = Means';
%     Distancias = zeros(N_Obj,1);
    for i=1:N_Class
%         Distancias(i) = -(incognitas - inputs(:,i))' * (incognitas - inputs(:,i));
        Distancias{i} = expand(-(incognitas-inputs(:,i))' * (incognitas-inputs(:,i)));
    end
end