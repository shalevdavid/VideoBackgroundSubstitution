clc;
clear all;
close all;


%%  defining constants  %%


Numpixels =25000;                             % Numpixels = the saf of the number of pixels 
sfi=1;                                        % sfi= starting frame index
efi=67;                                       % efi= ending frame index
dfi=1;                                        % dfi = difference frame index
nfi=15;                                       % nfi = the number of frames required for initialization
srf=sfi;                                        % srf = starting running frame
erf=efi;                                      % erf = ending running frame
epsilon = 0.0001; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mov = aviread('samplemovies\capture2.avi',sfi:efi);                                     %%%%  loading a movie
[I_Background_global,map2] = imread('CIMG3564.jpg');                %%%% protected variable I_Background_global
I_Background_global = im2double(I_Background_global);


%%  Initialization  %%
tic

SourceBackgroundGRAY = 0;
SourceBackgroundRED = 0;
SourceBackgroundGREEN = 0;
SourceBackgroundBLUE = 0;

for i=1:nfi
    
    frame = mov(i);
    I = frame2im(frame);
    GRAY = im2double(rgb2gray(I));
    RED = im2double(I(:,:,1));
    GREEN = im2double(I(:,:,2));
    BLUE = im2double(I(:,:,3));
    SourceBackgroundGRAY = SourceBackgroundGRAY + GRAY; 
    SourceBackgroundRED = SourceBackgroundRED + RED;
    SourceBackgroundGREEN = SourceBackgroundGREEN + GREEN;
    SourceBackgroundBLUE = SourceBackgroundBLUE + BLUE;

end;

SourceBackgroundGRAY = SourceBackgroundGRAY/nfi;
SourceBackgroundRED = SourceBackgroundRED/nfi;
SourceBackgroundGREEN = SourceBackgroundGRAY/nfi;
SourceBackgroundBLUE = SourceBackgroundBLUE/nfi;

maxnoiseGRAY = 0;
maxnoiseRED = 0;
maxnoiseGREEN = 0;
maxnoiseBLUE = 0;

for i=1:nfi
    
    frame1 = mov(i);
    I = frame2im(frame1); 
    GRAY = im2double(rgb2gray(I));
    RED = im2double(I(:,:,1));
    GREEN = im2double(I(:,:,2));
    BLUE = im2double(I(:,:,3));
    maxnoiseGRAY = max(   maxnoiseGRAY  ,  abs(GRAY-SourceBackgroundGRAY)   );
    maxnoiseRED = max(   maxnoiseRED  ,  abs(RED-SourceBackgroundRED)   );
    maxnoiseGREEN = max(   maxnoiseGREEN  ,  abs(GREEN-SourceBackgroundGREEN)   );
    maxnoiseBLUE = max(   maxnoiseBLUE  ,  abs(BLUE-SourceBackgroundBLUE)   );
    
end;

AverageNoiseGRAY = mean(maxnoiseGRAY(:));
AverageNoiseRED = mean(maxnoiseRED(:));
AverageNoiseGREEN = mean(maxnoiseGREEN(:));
AverageNoiseBLUE = mean(maxnoiseBLUE(:));
maxnoiseGRAY = max(maxnoiseGRAY,AverageNoiseGRAY);
maxnoiseRED = max(maxnoiseRED,AverageNoiseRED);
maxnoiseGREEN = max(maxnoiseGREEN,AverageNoiseGREEN);
maxnoiseBLUE = max(maxnoiseBLUE,AverageNoiseBLUE);

toc
%%  RUNNING THE PROCESS ON THE REST OF THE MOVIE  %%
tic

[J,K] = size(SourceBackgroundGRAY);

for i=srf:erf
    
    i
    I = frame2im(mov(i));
    GRAY = im2double(rgb2gray(I));
    RED = im2double(I(:,:,1));
    GREEN = im2double(I(:,:,2));
    BLUE = im2double(I(:,:,3));
    
    %%% what shoudnt be done
    diffGRAY = abs(GRAY - SourceBackgroundGRAY);
    maskGRAYpixel = im2double(  diffGRAY>maxnoiseGRAY  );
    diffRED = abs(RED - SourceBackgroundRED);
    maskREDpixel = im2double(  diffRED>maxnoiseRED  );
    diffGREEN = abs(GREEN - SourceBackgroundGREEN);
    maskGREENpixel = im2double(  diffGREEN>maxnoiseGREEN  );
    diffBLUE = abs(BLUE - SourceBackgroundBLUE);
    maskBLUEpixel = im2double(  diffBLUE>maxnoiseBLUE  );
    %%% this 8 lines are no good
    
    
    M=6;
    [maskGRAY] = CreateMask( GRAY , SourceBackgroundGRAY , maxnoiseGRAY , J , K , M );
    [maskRED] = CreateMask( RED , SourceBackgroundRED , maxnoiseRED , J , K , M );
    [maskGREEN] = CreateMask( GREEN , SourceBackgroundGREEN , maxnoiseGREEN , J , K , M );
    [maskBLUE] = CreateMask( BLUE , SourceBackgroundBLUE , maxnoiseBLUE , J , K , M );

    mask = (maskGRAY+maskRED+maskGREEN+maskBLUE+maskGRAYpixel+maskREDpixel+maskGREENpixel+maskBLUEpixel)>0;
    mask = fill_shape4(mask);
    
    I_Background = I_Background_global;                 %%%  reading  background picture to I_Background - coloured
    dm = im2double(mask);                               %% mask is the Ibw2 filled - binary image
    inv = ones(size(dm,1),size(dm,2))-dm;               %%% inv1 is the inverse of dm1 - binary image
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

movie2avi(FINAL,'MoviesResults\FINAL15C.avi') ;

