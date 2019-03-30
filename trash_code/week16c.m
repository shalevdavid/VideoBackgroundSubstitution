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


%% Interlace problem Pre-Proccessing


for j=1:size(mov,2)
    frame_pic = frame2im(mov(j));
    for index = 1:2:size(frame_pic,1)
        TempInterlace((index+1)/2,:,:) = frame_pic(index,:,:);
    end;
    for index = 1:2:size(TempInterlace,2)
        FinalInterlace(:,(index+1)/2,:,j) = TempInterlace(:,index,:);
    end;
end;


%%  Initialization  %%
tic

% SourceBackgroundGRAY = 0;
SourceBackgroundRED = 0;
SourceBackgroundGREEN = 0;
SourceBackgroundBLUE = 0;

for i=1:nfi
    
    I = FinalInterlace(:,:,:,i);
%     GRAY = im2double(rgb2gray(I));
    RED = im2double(I(:,:,1));
    GREEN = im2double(I(:,:,2));
    BLUE = im2double(I(:,:,3));
%     SourceBackgroundGRAY = SourceBackgroundGRAY + GRAY; 
    SourceBackgroundRED = SourceBackgroundRED + RED;
    SourceBackgroundGREEN = SourceBackgroundGREEN + GREEN;
    SourceBackgroundBLUE = SourceBackgroundBLUE + BLUE;

end;

% SourceBackgroundGRAY = SourceBackgroundGRAY/nfi;
SourceBackgroundRED = SourceBackgroundRED/nfi;
SourceBackgroundGREEN = SourceBackgroundGREEN/nfi;
SourceBackgroundBLUE = SourceBackgroundBLUE/nfi;

% maxnoiseGRAY = 0;
maxnoiseRED = 0;
maxnoiseGREEN = 0;
maxnoiseBLUE = 0;

for i=1:nfi
    
    I = FinalInterlace(:,:,:,i); 
%     GRAY = im2double(rgb2gray(I));
    RED = im2double(I(:,:,1));
    GREEN = im2double(I(:,:,2));
    BLUE = im2double(I(:,:,3));
%     maxnoiseGRAY = max(   maxnoiseGRAY  ,  abs(GRAY-SourceBackgroundGRAY)   );
    maxnoiseRED = max(   maxnoiseRED  ,  abs(RED-SourceBackgroundRED)   );
    maxnoiseGREEN = max(   maxnoiseGREEN  ,  abs(GREEN-SourceBackgroundGREEN)   );
    maxnoiseBLUE = max(   maxnoiseBLUE  ,  abs(BLUE-SourceBackgroundBLUE)   );
    
end;

% AverageNoiseGRAY = mean(maxnoiseGRAY(:));
AverageNoiseRED = mean(maxnoiseRED(:));
AverageNoiseGREEN = mean(maxnoiseGREEN(:));
AverageNoiseBLUE = mean(maxnoiseBLUE(:));
% maxnoiseGRAY = max(maxnoiseGRAY,AverageNoiseGRAY);
maxnoiseRED = max(maxnoiseRED,AverageNoiseRED);
maxnoiseGREEN = max(maxnoiseGREEN,AverageNoiseGREEN);
maxnoiseBLUE = max(maxnoiseBLUE,AverageNoiseBLUE);

toc
%%  RUNNING THE PROCESS ON THE REST OF THE MOVIE  %%
tic

M=6;
[J,K] = size(SourceBackgroundGREEN);

for i=srf:erf
    
    i
    I = FinalInterlace(:,:,:,i);
%     GRAY = im2double(rgb2gray(I));
    RED = im2double(I(:,:,1));
    GREEN = im2double(I(:,:,2));
    BLUE = im2double(I(:,:,3));
    
%     maskGRAY1 = medfilt2(abs(GRAY - SourceBackgroundGRAY)>5*maxnoiseGRAY,[5 5]);
    maskRED1 = medfilt2(abs(RED - SourceBackgroundRED)>5*maxnoiseRED,[5 5]);
    maskGREEN1 = medfilt2(abs(GREEN - SourceBackgroundGREEN)>5*maxnoiseGREEN,[5 5]);
    maskBLUE1 = medfilt2(abs(BLUE - SourceBackgroundBLUE)>5*maxnoiseBLUE,[5 5]);
    
%     maskGRAY2 = CreateMask( GRAY , SourceBackgroundGRAY , maxnoiseGRAY , J , K , M );
    maskRED2 = CreateMask( RED , SourceBackgroundRED , maxnoiseRED , J , K , M );
    maskGREEN2 = CreateMask( GREEN , SourceBackgroundGREEN , maxnoiseGREEN , J , K , M );
    maskBLUE2 = CreateMask( BLUE , SourceBackgroundBLUE , maxnoiseBLUE , J , K , M );

    mask = (maskRED1+maskGREEN1+maskBLUE1+maskRED2+maskGREEN2+maskBLUE2)>0;
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

movie2avi(FINAL,'MoviesResults\InterlaceM=6+NOgrayc.avi') ;

