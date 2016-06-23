%% PARTE 1.1: Obtencion patrones
clear; clc; close all;
    addpath('D:\Documentos\Universidad\Percepcion\Parte 2\Practica5\MaterialFacilitado\Imagenes\fotos_entrenamiento')
    Ext = '.jpg';
    Objetos{1} = 'Circ_ent_';
    Objetos{2} = 'Cuad_ent_';
    Objetos{3} = 'Tria_ent_';
    Forma = [ '+r'; '.g'; '*b' ];
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
    Descriptors_data = [];
    Separabilidad = [];
    for i=1:N_Descriptores
        Descriptor_data(i,1) = mean(Input(i,:));
        Descriptor_data(i,2) = std(Input(i,:));
        Input_normalizado(i,:) = (Input(i,:)-Descriptor_data(i,1))./Descriptor_data(i,2); 
        Separabilidad = [ Separabilidad ; indiceJ(Input_normalizado(i, :), Output) ] ;
    end
%% PARTE 1.2: SELECCION DE CARACTERISTICA ADECUADA
    % VISUALIZACION
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

    % PRIMERA SELECCION 
    [Ordenado, ordenAntiguo] = sort(Separabilidad, 'descend');
    mejores = ordenAntiguo(1:N_1st_filter);    
    
    % SEGUNDA SELECCION
    Combinaciones = combnk(mejores, N_2nd_filter);
    [F C] = size(Combinaciones);
    SeparabilidadConj = zeros(F,1);
    for i=1:F
        SeparabilidadConj(i) = indiceJ(Input_normalizado(Combinaciones(i,:),:), Output);
    end
    [M Ind] = max(SeparabilidadConj);
    Descriptores_Selec = Combinaciones(Ind, :);
    mejores = Input_normalizado(Descriptores_Selec, :);
    
    % VISUALIZACION DE LOS ELEGIDOS
    for j=1:N_Objetos
        plot3(mejores(1, Output==j), mejores(2, Output==j), mejores(3, Output==j), Forma(j) )
        hold on
    end
    hold off
    
   %% PARTE 2: DISEÑO DEL CLASIFICADOR Y TESTEO
   
    X = sym('x', [1 N_2nd_filter], 'real')';
    de = distancia_mahanalois(mejores, Output, X);
    Combinaciones = combnk(1:N_Objetos, 2);
    [N R] = size(Combinaciones);
    for i=1:N
        ecuaciones{i} = de{Combinaciones(i,1)} - de{Combinaciones(i,2)};
    end
    X = [ -267.4014 -28.3151 10.2988 -287.8468; 
          -555.2040 -52.6702 17.9275 -627.3370;
         -287.8025 -24.3550 7.6287 -339.4901];
    % X = [ x1 x2 x3 cte ];
    % X = [ 12; 13; 23 ]
    
    addpath('D:\Documentos\Universidad\Percepcion\Parte 2\Practica5\MaterialFacilitado\Imagenes\fotos_fasetest');
    Ext = '.jpg';
    N_Img = 3;
   
    for i=1:N_Img
        vector = [];
        nombre = [ 'Test' num2str(i) Ext ];
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
        A = (A'-Descriptor_data(i,1))./Descriptor_data(i,2); 
        vector = [ vector A ];
        vector = vector(Descriptores_Selec,:);
        for j=1:N
            Color = rand(1,3)*255;
            visualiza(I, Ietiq==j, Color);
%             if (ecuacion(Input(:,j)', X(2,:)) > 0 && ecuacion(Input(:,j)', X(3,:)) > 0)
%                  title('Circulo')
%             elseif (ecuacion(Input(:,j)', X(1,:)) < 0 && ecuacion(Input(:,j)', X(3,:)) < 0 )
%                 title('Cuadrado')
%             elseif (ecuacion(Input(:,j)', X(1,:)) > 0 && ecuacion(Input(:,j)', X(3,:)) < 0 )
%                 title('Triangulo')
%             else
%                 title('Error')
%             end
            title(Objetos{knn_Mahan(mejores, Output, vector(:,j), 1)});
            k = waitforbuttonpress;
        end
    end
   
   display('Fin')
   
%% PARTE 3: FUNCIONAMIENTO
   
    X = [ -267.4014 -28.3151 10.2988 -287.8468; 
          -555.2040 -52.6702 17.9275 -627.3370;
         -287.8025 -24.3550 7.6287 -339.4901];
    % X = [ x1 x2 x3 cte ];
    % X = [ 12; 13; 23 ]
    
    addpath('D:\Documentos\Universidad\Percepcion\Parte 2\Practica5\MaterialFacilitado\Imagenes\fotos_fasefuncionamiento');
    Ext = '.jpg';
    N_Img = 2;
   
    for i=1:N_Img
        vector = [];
        nombre = [ 'Func' num2str(i) Ext ];
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
        A = (A'-Descriptor_data(i,1))./Descriptor_data(i,2); 
        vector = [ vector A ];
        vector = vector(Descriptores_Selec,:);
        for j=1:N
            Color = rand(1,3)*255;
            visualiza(I, Ietiq==j, Color);
%             if (ecuacion(Input(:,j)', X(2,:)) > 0 && ecuacion(Input(:,j)', X(3,:)) > 0)
%                  title('Circulo')
%             elseif (ecuacion(Input(:,j)', X(1,:)) < 0 && ecuacion(Input(:,j)', X(3,:)) < 0 )
%                 title('Cuadrado')
%             elseif (ecuacion(Input(:,j)', X(1,:)) > 0 && ecuacion(Input(:,j)', X(3,:)) < 0 )
%                 title('Triangulo')
%             else
%                 title('Error')
%             end
            title(Objetos{knn_Mahan(mejores, Output, vector(:,j), 5)});
            k = waitforbuttonpress;
        end
    end
   
   display('Fin')
   
   