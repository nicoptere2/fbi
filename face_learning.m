function face_learning
%  Identifier les motifs globaux, G_Patterns, présents dans toutes les
%  images de tous les visages de la base de connaissance ainsi que les
%  occurrences de ces motifs dans chaque image de chaque visage de la base.
%  
%  Chaque image est découpée en N blocs 4x4. Chaque bloc est analysé en
%  fréquences via la DCT2 dont le coefficient DC est ignoré. Ensuite chaque
%  image est réprésentée par une matrice Nx15 qui sert à la fois à
%  identifier les motifs globaux et à construire l'histogramme de ces
%  motifs pour chaque image de chaque visage de la base de connaissance.
%
% Les paramètres dont les motifs globaux, utiles à l'identification d'une
% image inconnue sont enregistrés dans le fichier 'params.mat' ainsi que
% les histogrammes de chaque image de chaque visage de la base de
% connaissance.
%
% Le même traitement peut être fait avec les coefficients DC. Mais ils sont
% ignorés pour ce projet.

%% Réinitialiser l'espace de travail
clear
clc

%% Définir le répertoire de la base de connaisssance #
db_path = uigetdir();

%% Initialiser les paramètres globaux
BSZ = 4; %%taille des blocs
QP = 22; %%valeur de quantification
N_AC_PATTERNS = 35; %%Nombre de vecteurs DCT retenus pour l'ensemble de la bdr
NB_FACES = 5; %%le nombre d'individus
NB_IMAGES = 5; %%le nombre de profil par individu
DC_MEAN_ALL = 0; 

%% Extraire les N blocs DCT pour chaque image de chaque visage
AC_list = cell(NB_FACES,NB_IMAGES);% les matrices Nx15
dc_means = zeros(NB_FACES,NB_IMAGES);% les moyennes par image des DC
% des constantes
blocSz =  (1:BSZ) - 1;
BZ2 = floor(BSZ/2);
ACSZ = BSZ * BSZ - 1;
% pour chaque visage
for f = 1:NB_FACES
    face_path = sprintf('%s/s%d',db_path,f);
    
    % pour chaque image
    for fi = 1:NB_IMAGES
        fname = sprintf('%s/%d.png',face_path,fi);
        img = imread(fname);
        [h,w] = size(img);
        n_blocks = 0;
        
        for i= 1:2:(h-3)
            for j= 1:2:(w-3)
            n_blocks = n_blocks+1;
            b = im(i:(i+3),j:(j+3));
            bdct = dct2(b);
            
            AC_list{f,fi}{b} = dct2(2:16);
            dc(b) = dct2(1);
            end
        end
    dc_mean(f,fi) = mean(dc);
    end
end
DC_MEAN_ALL = mean2(dc_means);

%% Stockage des paramètres dans une structure
params = struct(...
    'BZS',BSZ,...
    'QP',QP,...
    'N_AC_PATTERNS',N_AC_PATTERNS,...
    'NB_FACES',NB_FACES,...
    'NB_IMAGES',NB_IMAGES,...
    'DC_MEAN_ALL',DC_MEAN_ALL,...
    'DIR',db_path);

%% enregistrement de la structure dans un fichier
save('params.mat','params');
disp('dct done');

%% Identification des motifs globaux, construction de leurs histogrammes
G_Patterns = [];
for f = 1:NB_FACES
    for fi = 1:NB_IMAGES
        % normalisation et quantification des AC
        h = size(AC_list(f,fi),1);
        ac = AC_list(f,fi);
        QAC = zeros(h, 15);
        for i = 1:h
                a = ac(i, :) * DC_MEAN_ALL;
                b = a / dc_means(f,fi) / QP;
                r = round(b);
                QAC(i, :) = r;
        end
        % identification des motifs et comptage de leurs occurrences.
				% QAC est la matrice des vecteurs AC quantifés
        for i = 1:size(QAC,1)
            
            if f==1 && fi==1
                G_Patterns(1,1:15) = QAC(1,1:15);
                G_Patterns(1,16) = 1;
            else
                [~,ind] = ismember(QAC(i,1:15),G_Patterns(:,1:15), 'rows');
                if ind > 0
                    G_Patterns(ind, 16) = G_Patters(ind, 16)+1;
                else
                    ind = size(G_Patterns, 1)+1;
                    G_Patterns(ind, 1:15) = QAC(i, 1:15);
                    G_Patterns(ind, 15+i) = 1;
                end
            end
        end
    end
end
% Conserver les N_AC_PATTERNS motifs les plus présents dans toutes les
% images de tous les visages de la base.
[~,Idx] = sort(G_Patterns(:,end),'descend');
G_Patterns = G_Patterns(Idx(1:N_AC_PATTERNS),1:(end-1));

% save G_Patterns
save('G_Patterns.mat','G_Patterns')
disp('G_Patterns done')

%% Construction des histogrammes de toutes les images de chaque visage
AC_Patterns_Histo = zeros(N_AC_PATTERNS,1);
AC_Patterns_Histo_List = cell(NB_FACES, NB_IMAGES);
for f = 1:NB_FACES
    for fi = 1:NB_IMAGES
        %%FAIRE FONCTION FIND PATTERN NICOLAS !
        AC_Patterns_Histo(i) = find_Pattern(G_Patterns(i, 1:15), AC_list(f,fi)(:, 1:15));
    end
    AC_Patterns_Histo_Listif(f,fi) = AC_Patterns_Histo;
    
end
save('Histogrammes.mat', 'AC_Patterns_Histo_List');
disp('AC_Patterns_Histo done');
