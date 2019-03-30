clc;
close all;
clear all;

%%  stage 1 - LOADING THE MOVIE  %%
tic

mov = aviread('samplemovies\Picture014shorter.avi');                                                        %%%%  loading a movie
[I_Background_global,map2] = imread('backgrounds\CIMG3567.jpg');                %%%% protected variable I_Background_global
I_Background_global = im2double(I_Background_global);

%%% if the camera has an Interlace problem we can use the following
% mov = InterlaceMovie(mov);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sfi=1;                                                              % sfi= starting frame index
efi=size(mov,2);                                        % efi= ending frame index

nfi=15;                                                            % nfi = the number of frames required for initialization - stage 2
srf=nfi+1;                                                   % srf = starting running frame - stage 3
erf=68;                                                            % erf = ending running frame - stage 3
stf=erf+1;                                                   % sti = starting tracking frame - stage 4 
etf=efi;                                                        % eti = ending tracking frame - stage 4

[J,K] = size(rgb2gray(frame2im(mov(1))));

toc
%%  stage 2 - INITIALIZATION OF THE CAMERA  %%
tic

% SourceBackgroundGRAY = 0;
SourceBackgroundRED = 0;
SourceBackgroundGREEN = 0;
SourceBackgroundBLUE = 0;
SourceBackgroundH = 0;
SourceBackgroundS = 0;

for i=1:nfi
    
    I = frame2im(mov(i));
%     GRAY = im2double(rgb2gray(I));
    RED = im2double(I(:,:,1));
    GREEN = im2double(I(:,:,2));
    BLUE = im2double(I(:,:,3));

    [H,S,V] = rgb2hsv(I);

%     SourceBackgroundGRAY = SourceBackgroundGRAY + GRAY;
    SourceBackgroundRED = SourceBackgroundRED + RED;
    SourceBackgroundGREEN = SourceBackgroundGREEN + GREEN;
    SourceBackgroundBLUE = SourceBackgroundBLUE + BLUE;
    SourceBackgroundH = SourceBackgroundH + H;
    SourceBackgroundS = SourceBackgroundS +S;
    
end;

% SourceBackgroundGRAY = SourceBackgroundGRAY/nfi;
SourceBackgroundRED = SourceBackgroundRED/nfi;
SourceBackgroundGREEN = SourceBackgroundGREEN/nfi;
SourceBackgroundBLUE = SourceBackgroundBLUE/nfi;
SourceBackgroundH = SourceBackgroundH/nfi;
SourceBackgroundS = SourceBackgroundS/nfi;

% at first we find the Source Background and now we use it to estimate the
% charactaristic maximal noise of the camera

% maxnoiseGRAY = 0;
maxnoiseRED = 0;
maxnoiseGREEN = 0;
maxnoiseBLUE = 0;
maxnoiseH = 0;
maxnoiseS = 0;

for i=1:nfi
    
    I = frame2im(mov(i)); 
%     GRAY = im2double(rgb2gray(I));
    RED = im2double(I(:,:,1));
    GREEN = im2double(I(:,:,2));
    BLUE = im2double(I(:,:,3));

    [H,S,V] = rgb2hsv(I);
%     maxnoiseGRAY = max(   maxnoiseGRAY  ,  abs(GRAY-SourceBackgroundGRAY)   );
    maxnoiseRED = max(   maxnoiseRED  ,  abs(RED-SourceBackgroundRED)   );
    maxnoiseGREEN = max(   maxnoiseGREEN  ,  abs(GREEN-SourceBackgroundGREEN)   );
    maxnoiseBLUE = max(   maxnoiseBLUE  ,  abs(BLUE-SourceBackgroundBLUE)   );
    maxnoiseH = max(   maxnoiseH  ,  abs(H-SourceBackgroundH)   );
    maxnoiseS = max(   maxnoiseS  ,  abs(S-SourceBackgroundS)   );
    
end;

% AverageNoiseGRAY = mean(maxnoiseGRAY(:));
AverageNoiseRED = mean(maxnoiseRED(:));
AverageNoiseGREEN = mean(maxnoiseGREEN(:));
AverageNoiseBLUE = mean(maxnoiseBLUE(:));
AverageNoiseH = mean(maxnoiseH(:));
AverageNoiseS = mean(maxnoiseS(:));

% maxnoiseGRAY = max(maxnoiseGRAY,AverageNoiseGRAY);
maxnoiseRED = max(maxnoiseRED,AverageNoiseRED);
maxnoiseGREEN = max(maxnoiseGREEN,AverageNoiseGREEN);
maxnoiseBLUE = max(maxnoiseBLUE,AverageNoiseBLUE);
maxnoiseH = max(maxnoiseH,AverageNoiseH);
maxnoiseS = max(maxnoiseS,AverageNoiseS);

toc
%%  stage 3 - INITIAL RECOGNITION  %% 
tic

for i=srf:erf
    
    i
    I = frame2im(mov(i));
    RED = im2double(I(:,:,1));
    GREEN = im2double(I(:,:,2));
    BLUE = im2double(I(:,:,3));
    [H,S,V] = rgb2hsv(I);
    
    maskRED = medfilt2( CreateMaskCorr( RED , SourceBackgroundRED , 0.98 , J , K , 6 ) , [10 10] );
    maskGREEN = medfilt2( CreateMaskCorr( GREEN , SourceBackgroundGREEN , 0.98 , J , K , 6 ) , [10 10] );
    maskBLUE = medfilt2( CreateMaskCorr( BLUE , SourceBackgroundBLUE , 0.97 , J , K , 6 ) , [10 10] );   
    maskRED = clean_noise_param(maskRED,400);
    maskGREEN = clean_noise_param(maskGREEN,400);
    maskBLUE = clean_noise_param(maskBLUE,400);
    
    maskH1 = medfilt2(abs(H - SourceBackgroundH)>maxnoiseH,[5 5]);
    maskS1 = medfilt2(abs(S - SourceBackgroundS)>maxnoiseS,[5 5]);
    maskH2 = CreateMask( H , SourceBackgroundH , maxnoiseH , J , K , 4 );
    maskS2 = CreateMask( S , SourceBackgroundS , maxnoiseS , J , K , 4 );

    maskRGB = (maskRED+maskGREEN+maskBLUE)>1; 
    maskHS1 = clean_noise_param ( (maskH1+maskS1)>0 , 800);
    maskHS2 = clean_noise_param( (maskH2 + maskS2)>0 , 800);

    mask1 = medfilt2( (maskRGB+maskHS1+maskHS2)>0 , [15 15] );
    mask1 = fill_shape4(mask1);
    
    se = strel('rectangle',[2 2]);
    mask2 = imdilate(fill_shape4(mask1),se);    
    eg = edge(GREEN,'sobel');
    eb = edge(BLUE,'sobel');
    er = edge(RED,'sobel');
    ergb = (eb+eg+er)>0;
    es = edge(S,'sobel',0.05);
    e = (ergb+es)>0;
    
    mask = fill_shape4(mask2.*e);
    
    I_Background = I_Background_global;                     %%%  reading  background picture to I_Background - coloured
    dm = im2double(mask);                                                             %%% mask is the Ibw2 filled - binary image
    inv = ones(size(dm,1),size(dm,2))-dm;                                %%% inv1 is the inverse of dm1 - binary image
    inv = [ones(size(inv,1),(size(I_Background,2)-size(inv,2))),inv];    
    inv = [ones((size(I_Background,1)-size(inv,1)),size(inv,2));inv];
    for j=1:3
        I(:,:,j) = double(I(:,:,j)).*dm;
    end;
    for j=1:3
        I_Background(:,:,j) = double(I_Background(:,:,j)).*inv;
    end;
    for j=1:3
        x(:,:,j) = [zeros(size(I(:,:,j),1),(size(I_Background,2)-size(I(:,:,j),2))),I(:,:,j)]; 
        y(:,:,j) = [zeros((size(I_Background,1)-size(x(:,:,j),1)),size(x(:,:,j),2));x(:,:,j)];
    end;
    FINAL(i-srf+1) = im2frame(im2double(y)+I_Background);
     
end;

toc
%%  stage 4 - RUNNING THE PROCESS ON THE REST OF THE MOVIE  %%
tic

M=3;         %%%  2M+1 is the block size in pixels
p=16;        %%%  p refers to the serch-block's size in the MotionVector algorithem.

for i=stf:etf

    i                                                                                                                %% check
    [I2,Map] = frame2im(mov(i));
    RED2 = im2double(I2(:,:,1));
    GREEN2 = im2double(I2(:,:,2));
    BLUE2 = im2double(I2(:,:,3));
    [H2,S2,V2] = rgb2hsv(I2);
    
    [r,c] = find(edge(mask,'sobel'));
    SetOfPoints = [r,c];
 
    [SetOfNewPointsS] = TraceObjectNTSS(SetOfPoints, double(S), double(S2), double(mask), M, p);
    [SetOfNewPointsRED] = TraceObjectNTSS(SetOfPoints, double(RED), double(RED2), double(mask), M, p);
    [SetOfNewPointsGREEN] = TraceObjectNTSS(SetOfPoints, double(GREEN), double(GREEN2), double(mask), M, p);
    [SetOfNewPointsBLUE] = TraceObjectNTSS(SetOfPoints, double(BLUE), double(BLUE2), double(mask), M, p);
    [SetOfNewPointsScorr] = TraceObjectNTSS(SetOfPoints, double(S), double(S2), double(mask), M, p);
    [SetOfNewPointsREDcorr] = TraceObjectNTSScorr(SetOfPoints, double(RED), double(RED2), double(mask), M, p);
    [SetOfNewPointsGREENcorr] = TraceObjectNTSScorr(SetOfPoints, double(GREEN), double(GREEN2), double(mask), M, p);
    [SetOfNewPointsBLUEcorr] = TraceObjectNTSScorr(SetOfPoints, double(BLUE), double(BLUE2), double(mask), M, p);

    mask_next_estimationS = zeros(J,K);
    for j=1:size(SetOfNewPointsS,1) 
        mask_next_estimationS(SetOfNewPointsS(j,1),SetOfNewPointsS(j,2))=1;
    end;
    mask_next_estimationRED = zeros(J,K);
    for j=1:size(SetOfNewPointsRED,1) 
        mask_next_estimationRED(SetOfNewPointsRED(j,1),SetOfNewPointsRED(j,2))=1;
    end;
    mask_next_estimationGREEN = zeros(J,K);
    for j=1:size(SetOfNewPointsGREEN,1) 
        mask_next_estimationGREEN(SetOfNewPointsGREEN(j,1),SetOfNewPointsGREEN(j,2))=1;
    end;
    mask_next_estimationBLUE = zeros(J,K);
    for j=1:size(SetOfNewPointsBLUE,1) 
        mask_next_estimationBLUE(SetOfNewPointsBLUE(j,1),SetOfNewPointsBLUE(j,2))=1;
    end;
    mask_next_estimationScorr = zeros(J,K);
    for j=1:size(SetOfNewPointsScorr,1) 
        mask_next_estimationScorr(SetOfNewPointsScorr(j,1),SetOfNewPointsScorr(j,2))=1;
    end;
    mask_next_estimationREDcorr = zeros(J,K);
    for j=1:size(SetOfNewPointsScorr,1) 
        mask_next_estimationREDcorr(SetOfNewPointsREDcorr(j,1),SetOfNewPointsREDcorr(j,2))=1;
    end;
    mask_next_estimationGREENcorr = zeros(J,K);
    for j=1:size(SetOfNewPointsGREENcorr,1) 
        mask_next_estimationGREENcorr(SetOfNewPointsGREENcorr(j,1),SetOfNewPointsGREENcorr(j,2))=1;
    end;
    mask_next_estimationBLUEcorr = zeros(J,K);
    for j=1:size(SetOfNewPointsBLUEcorr,1) 
        mask_next_estimationBLUEcorr(SetOfNewPointsBLUEcorr(j,1),SetOfNewPointsBLUEcorr(j,2))=1;
    end;
    
    mask_next_estimation = (mask_next_estimationRED+mask_next_estimationS+mask_next_estimationGREEN+mask_next_estimationBLUE)>0;
    mask_next_estimation = fill_shape4(mask_next_estimation);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    I_Background = I_Background_global;                     %%%  reading  background picture to I_Background - colour

    dm1 = im2double(mask_next_estimation);                 %%% mask is the Ibw2 filled - binary image
    
    inv1 = ones(size(dm1,1),size(dm1,2))-dm1;                        %%% inv1 is the inverse of dm1 - binary image
    inv1 = [ones(size(inv1,1),(size(I_Background,2)-size(inv1,2))),inv1];    
    inv1 = [ones((size(I_Background,1)-size(inv1,1)),size(inv1,2));inv1];
    
    for j=1:3
        I2(:,:,j) =double(I2(:,:,j)).*dm1;
    end;
  
    for j=1:3
        I_Background(:,:,j) = double(I_Background(:,:,j)).*inv1;
    end;
  
    for j=1:3
        x(:,:,j) = [zeros(size(I2(:,:,j),1),(size(I_Background,2)-size(I2(:,:,j),2))),I2(:,:,j)]; 
        y(:,:,j) = [zeros((size(I_Background,1)-size(x(:,:,j),1)),size(x(:,:,j),2));x(:,:,j)];
    end;
 
    FINAL(erf-srf+2+i-stf) = im2frame(im2double(y)+I_Background);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    mask = mask_next_estimation;
    RED = RED2;
    GREEN = GREEN2;
    BLUE = BLUE2;
    H = H2;
    S = S2;

end;

movie2avi(FINAL,'MoviesResults\Final_Idea_Comb3.avi') ;

toc