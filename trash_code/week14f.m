clc;
clear all;
close all;


%%  defining constants  %%


Numpixels =25000;                             % Numpixels = the saf of the number of pixels 
sfi=1;                                        % sfi= starting frame index
efi=67;                                       % efi= ending frame index
dfi=1;                                        % dfi = difference frame index
nfi=15;                                       % nfi = the number of frames required for initialization
srf=1;                                        % srf = starting running frame
erf=efi;                                      % erf = ending running frame
epsilon = 0.0001; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mov = aviread('samplemovies\capture2.avi',sfi:efi);                                     %%%%  loading a movie
[I_Background_global,map2] = imread('CIMG3564.jpg');                %%%% protected variable I_Background_global
I_Background_global = im2double(I_Background_global);


%%  Initialization  %%

SourceBackgroundGRAY = 0;

for i=1:nfi
    
    frame = mov(i);
    I = frame2im(frame);
    GRAY = im2double(rgb2gray(I));
    RED = im2double(I(:,:,1));
    GREEN = im2double(I(:,:,2));
    BLUE = im2double(I(:,:,3));
    SourceBackgroundGRAY = SourceBackgroundGRAY + GRAY; 
    SourceBackgroundBLUE = SourceBackgroundBLUE + B;

end;

SourceBackgroundGRAY = SourceBackgroundGRAY/nfi;
SourceBackgroundBLUE = SourceBackgroundBLUE/nfi;

maxnoiseGRAY = 0;

for i=1:nfi
    
    frame1 = mov(i);
    I = frame2im(frame1); 
    GRAY = im2double(rgb2gray(I));
    maxnoiseGRAY = max(   maxnoiseGRAY  ,  abs(GRAY-SourceBackgroundGRAY)   );
    
end;

AverageNoise = mean(maxnoiseGRAY(:));
maxnoiseGRAY = max(maxnoiseGRAY,AverageNoise);


%%  RUNNING THE PROCESS ON THE REST OF THE MOVIE  %%

[J,K] = size(SourceBackgroundGRAY);

for i=srf:erf
    
    i
    I = frame2im(mov(i));
    GRAY = im2double(rgb2gray(I));
%     diffGRAY = abs(GRAY - SourceBackgroundGRAY);
%     mask1 = im2double(  diffGRAY>maxnoiseGRAY  );
    
    M=6;
    for j=1:M:J-M+1
        for k=1:M:K-M+1
            
            tempdiff = GRAY(j:j+M-1,k:k+M-1) - SourceBackgroundGRAY(j:j+M-1,k:k+M-1);
            tempblocknoise = maxnoiseGRAY(j:j+M-1,k:k+M-1);
            MAD = sum( abs(tempdiff(:)) )/M^2;
            if (  MAD>sum(tempblocknoise(:))/M  )
                mask2(j:j+M-1,k:k+M-1) = 1;
            else
                mask2(j:j+M-1,k:k+M-1) = 0;
            end;
            
        end;
    end;
    mask2(   size(mask2,1)+1:J  ,  :   ) = mask2(  2*size(mask2,1)+1-J:size(mask2,1)  ,  :   );
    mask2(   :  ,  size(mask2,2)+1:K   ) = mask2(  :  ,  2*size(mask2,2)+1-K:size(mask2,2)   );
    
    mask = mask2;
    
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
 
movie2avi(FINAL,'MoviesResults\DSP_FINAL14c152.avi') ;

