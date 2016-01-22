function best = face_recognition( img, KPP )
% identification dans la base de connaissance des plus proches images (KPP)
% de l'image à identifier (img)
% demande trois paramètres : image à identifier, nbre image de la bdc
% susceptible de correspondre
% si on veut ou non visualiser le résultat
if(nargin < 2)
    KPP = 3;
end
if(nargin < 3)
    visu = true;
end

%% lecture des paramètres globaux
load('params.mat'); % params est une structure (cf. face_learning)

 BZS = params.BSZ;
 QP = params.QP;
 N_AC_PATTERNS = params.N_AC_PATTERNS;
 NB_FACES = params.NB_FACES;
 NB_IMAGES = params.NB_IMAGES;
 DC_MEAN_ALL = params.DC_MEAN_ALL;
 DIR = params.db_path;
%% extraction des blocs DCT

        img = imread(img);
        [h,w] = size(img);
        n_blocks = 0;
        
        for i= 1:2:(h-3)
            for j= 1:2:(w-3)
            n_blocks = n_blocks+1;
            b = im(i:(i+3),j:(j+3));
            bdct = dct2(b);
            
            AC_list{b} = dct2(1:16);
            dc(b) = dct2(1);
            end
        end
    dc_mean(f,fi) = mean(dc);
 
%% Normalisation et quantification
h = size(AC_list,1);
        QAC = zeros(h, 15);
        for i = 1:h
                a = AC_list(i, :) * DC_MEAN_ALL;
                b = a / dc_means / QP;
                QAC(i, :) = round(b);
        end
        
%% Comptage des occurrences des motifs globaux
load('G_Patterns.mat');
AC_Signatures = zeros(N_AC_PATTERNS,1);
for idx = 1:N_AC_PATTERNS
    AC_Signatures(idx) = find_Pattern(G_Patterns(idx,:),QAC);
end

%% Sélection des KPP meilleures AC_Patterns_Histo par PVH
best = ones(KPP+1,3)*-1; % chaque ligne est <SAD,N°individu,N°profil>
%% CUT HERE ====================================================================

%% CUT HERE ====================================================================
best = best(1:(end-1),2:end);

%% visualisation des visages possiblement identifiés
if(visu)
    figure;
    subplot(1,KPP+1,1);
    imshow(img);
    for b = 1:KPP
        subplot(1,KPP+1,b+1);
        filename = sprintf('%s/s%d/%d.png',...
            params.DIR,best(b,1),best(b,2));
        imreco = imread(filename);
        imshow(imreco);
    end
end
end