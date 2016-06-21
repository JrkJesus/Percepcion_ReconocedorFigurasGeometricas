%% PARTE 1.1: Obtencion patrones

    addpath('D:\Documentos\Universidad\Percepcion\Parte 2\Practica5\MaterialFacilitado\Imagenes\fotos_entrenamiento')
    Ext = '.jpg';
    Objetos{1} = 'Circ_ent_';
    Objetos{2} = 'Cuad_ent_';
    Objetos{3} = 'Tria_ent_';
    Forma = [ '+r'; '.g'; '.b' ];
%     Forma = cellstr(Forma);
    N_Objetos = 3; %3
    N_Repeticiones = 2;
    N_Descriptores = 12;
    N_1st_filter = 6;
    N_2nd_filter = 3;
    I = [];
    Input = [];
    Output = [];
    for i=1:N_Objetos % Numero de objetos distinos
        for j=1:N_Repeticiones % Numero de entrenamiento del obj
            nombre = [ Objetos{i} num2str(j) Ext ]; % num2str(i, '%02d')
            I = imread(nombre);
            Ibin = I < graythresh(I)*255;
            [ Ietiq N ] = bwlabel(Ibin);
            stats = regionprops(Ietiq, 'Area', 'Perimeter', 'MajorAxisLength', 'MinorAxisLength', 'Eccentricity', 'Solidity', 'Extent', 'EulerNumber');
            Compac = (cat(1,stats.Perimeter).^2)./cat(1,stats.Area);
            Excen = cat(1,stats.MinorAxisLength )./cat(1,stats.MajorAxisLength);
            A = [ Compac Excen cat(1,stats.Eccentricity) cat(1,stats.Solidity) cat(1,stats.Extent) ];
            Momentos = [];
            for k=1:N
                Momentos = [ Momentos Funcion_Calcula_Hu(Ibin(Ietiq==k)) ];
            end
            A = [ A Momentos' cat(1,stats.EulerNumber) ];
            Input = [ Input; A ];
            Output = [ Output; ones(N,1)*i ];
        end
    end
    Input = Input';
    Output = Output';
%     Input_normalizado = (Input-mean(Input))./std(Input); 
    Descriptors_mean = [];
    Separabilidad = [];
    for i=1:N_Descriptores
        Descriptor_data(i,1) = mean(Input(i,:));
        Descriptor_data(i,2) = std(Input(i,:));
        Input_normalizado(i,:) = (Input(i,:)-Descriptor_data(i,1))./Descriptor_data(i,2); 
        Separabilidad = [ Separabilidad ; indiceJ(Input_normalizado(i, :), Output) ] ;
    end
%% PARTE 1.2: SELECCION DE CARACTERISTICA ADECUADA

%     
%     for i=1:2:N_Descriptores
%         for j=1:N_Objetos
%             plot(Input_normalizado(i, Output==j), Input_normalizado(i+1,Output==j), Forma(j) )
%             hold on
%         end
%         hold off
%         k = waitforbuttonpress; % Esperamos a pulsar tecla o raton.
%         
%     end
    
    [Ordenado, ordenAntiguo] = sort(Separabilidad, 'descend');
    mejores = ordenAntiguo(1:N_1st_filter);    
    Combinaciones = combnk(mejores, N_2nd_filter);
    [F C] = size(Combinaciones);
    SeparabilidadConj = zeros(F,1);
    for i=1:F
        SeparabilidadConj(i) = indiceJ(Input_normalizado(Combinaciones(i,:),:), Output);
    end
    [M Ind] = max(SeparabilidadConj);
    Descriptores_Selec = Combinaciones(Ind, :);
    mejores = Input_normalizado(Descriptores_Selec, :);
    
    for j=1:N_Objetos
        plot3(mejores(1, Output==j), mejores(2, Output==j), mejores(3, Output==j), Forma(j) )
        hold on
    end
    hold off
    
   %% PARTE 2: 
   
   
   
   
   
   
   
   
   
   