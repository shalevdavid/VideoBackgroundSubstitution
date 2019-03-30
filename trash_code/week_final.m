clc;
close all;
clear all;

%%  stage 1 - LOADING THE MOVIE  %%
tic

mov = aviread('samplemovies\capture2.avi');                                                        %%%%  loading a movie
[I_Background_global,map2] = imread('backgrounds\CIMG3567.jpg');                %%%% protected variable I_Background_global
I_Background_global = im2double(I_Background_global);

%%% if the camera has an Interlace problem we can use the following
mov = InterlaceMovie(mov);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sfi=1;                                                              % sfi= starting frame index
efi=size(mov,2);                                        % efi= ending frame index

nfi=15;                                                            % nfi = the number of frames required for initialization - stage 2
srf=nfi+1;                                                   % srf = starting running frame - stage 3
erf=63;                                                            % erf = ending running frame - stage 3
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

M = 4;

for i=srf:erf
    
    i
    I = frame2im(mov(i));
%     GRAY = im2double(rgb2gray(I));
    RED = im2double(I(:,:,1));
    GREEN = im2double(I(:,:,2));
    BLUE = im2double(I(:,:,3));
    
    [H,S,V] = rgb2hsv(I);
    
%     maskGRAY1 = medfilt2(abs(GRAY - SourceBackgroundGRAY)>5*maxnoiseGRAY,[5 5]);
%     maskRED1 = medfilt2(abs(RED - SourceBackgroundRED)> 0.07,[5 5]);
%     maskGREEN1 = medfilt2(abs(GREEN - SourceBackgroundGREEN)> 0.07,[5 5]);
%     maskBLUE1 = medfilt2(abs(BLUE - SourceBackgroundBLUE)> 0.07,[5 5]);
    maskH1 = medfilt2(abs(H - SourceBackgroundH)>maxnoiseH,[5 5]);
    maskS1 = medfilt2(abs(S - SourceBackgroundS)>maxnoiseS,[5 5]);
    
%     maskGRAY2 = CreateMask( GRAY , SourceBackgroundGRAY , maxnoiseGRAY , J , K , M );
    maskRED2 = CreateMask( RED , SourceBackgroundRED , maxnoiseRED , J , K , M );
    maskGREEN2 = CreateMask( GREEN , SourceBackgroundGREEN , maxnoiseGREEN , J , K , M );
    maskBLUE2 = CreateMask( BLUE , SourceBackgroundBLUE , maxnoiseBLUE , J , K , M );
    maskH2 = CreateMask( H , SourceBackgroundH , maxnoiseH , J , K , M );
    maskS2 = CreateMask( S , SourceBackgroundS , maxnoiseS , J , K , M );
    
    maskHS1 = clean_noise_param ( (maskH1+maskS1)>0 , 800);
    maskHS2 = clean_noise_param( (maskH2 + maskS2)>0 , 800);
    maskRGB = clean_noise_param( (maskRED2+maskGREEN2+maskBLUE2)>2 , 800);

    mask = (maskHS1+maskHS2+maskRGB)>0;
    
    mask = fill_shape4(mask);
    
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

M=8;        %%%  M is the block size in pixels
p=16;        %%%  p refers to the serch-block's size in the MotionVector algorithem.

Ibw1 = rgb2gray(frame2im(mov(stf-1)));

for i=stf:etf

    i                                                                                                                %% check
    [I2,Map] = frame2im(mov(i));
    Ibw2 = rgb2gray(I2);
    
     [r,c] = find(mask);
     SetOfPoints = [r,c];
 
     [SetOfNewPoints] = TraceObject(SetOfPoints, double(Ibw1), double(Ibw2), double(mask), M, p);

    mask_next_estimation = zeros(J,K);
    for j=1:size(SetOfNewPoints,1) 
        mask_next_estimation(SetOfNewPoints(j,1),SetOfNewPoints(j,2))=1;
    end;
    
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
    Ibw1=Ibw2;

end;

movie2avi(FINAL,'MoviesResults\Final_Idea_6.avi') ;

toc