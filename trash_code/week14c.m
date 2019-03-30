clc;
clear all;
close all;

%%   defining constants  %%


Numpixels =25000;                                  % Numpixels = the saf of the number of pixels 
sfi=1;                                                           % sfi= starting frame index
efi=87;                                                         % efi= ending frame index
dfi=1;                                                            %dfi = difference frame index
nfi=15;                                                          %nfi = the number of frames required for initializatuin

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mov = aviread('Z:\Project\samplemovies\video5555.avi',sfi:efi);                                     %%%%  loading a movie
[I_Background_global,map2]=imread('CIMG3564.jpg');                %%%% protected variable I_Background_global
I_Background_global=im2double(I_Background_global);


%%  Initialization %%


sum_source_background = 0;
maxnoiseGRAY = 0;
maxnoiseR = 0;
maxnoiseG = 0;
maxnoiseB = 0;
% maxnoiseH = 0;
% maxnoiseS = 0;

i=1;

while  (i<nfi)
    
    frame1 = mov(i);
    frame2 = mov(i+1);
    I1 = frame2im(frame1);
    I2 = frame2im(frame2); 
    
    GRAY1 = im2double(rgb2gray(I1));
    GRAY2 = im2double(rgb2gray(I2));
    R1 =im2double(I1(:,:,1));
    R2 =im2double(I2(:,:,1));
    G1 =im2double(I1(:,:,2));
    G2 =im2double(I2(:,:,2));
    B1 =im2double(I1(:,:,3));
    B2 =im2double(I2(:,:,3));
%     [H1,S1,V1]=rgb2hsv(I1);
%     [H2,S2,V2]=rgb2hsv(I2);
    
    noiseGRAY = abs(GRAY1 -GRAY2);
    maxnoiseGRAY = max(   maxnoiseGRAY  ,   max(   noiseGRAY(:))   );    
    noiseR = abs(R1- R2);
    maxnoiseR = max(   maxnoiseR  ,   max(   noiseR(:))   );
    noiseG = abs(G1-G2);
    maxnoiseG = max(   maxnoiseG  ,   max(   noiseG(:))   );    
    noiseB = abs(B1-B2);
    maxnoiseB = max(   maxnoiseB  ,   max(   noiseB(:))   );
%     noiseH = abs(im2double(H1)-im2double(H2));
%     maxnoiseH = max(   maxnoiseH  ,   max(   noiseH(:))   );
%     noiseS = abs(im2double(S1)-im2double(S2));
%     maxnoiseS = max(   maxnoiseS  ,   max(   noiseS(:))   );
    
    sum_source_background = sum_source_background + im2double(I1);
    i=i+1;
end;

SourceBackground = (sum_source_background+im2double(I2))/nfi;      %%% nice trick
SourceBackgroundR = SourceBackground(:,:,1);
SourceBackgroundG = SourceBackground(:,:,2);
SourceBackgroundB = SourceBackground(:,:,3);
SourceBackgroundGRAY = rgb2gray(SourceBackground);


%%  RUNNING THE PROCESS ON THE REST OF THE MOVIE

[J,K] = size(GRAY1);
i=i+1;

while (i<=efi)
    
    i
    I = frame2im(mov(i));
    GRAY = im2double(rgb2gray(I));
    R = im2double(I(:,:,1));
    G = im2double(I(:,:,2));
    B = im2double(I(:,:,3));
    
    diffR = abs(R - SourceBackgroundR);
    diffG = abs(G - SourceBackgroundG);
    diffB = abs(B - SourceBackgroundB);
    diffGRAY =  abs(GRAY - SourceBackgroundGRAY);
    
    maskR = im2bw(diffR,maxnoiseR);
    maskG = im2bw(diffG,maxnoiseG);
    maskB = im2bw(diffB,maxnoiseB);
    maskGRAY = im2bw(diffGRAY,maxnoiseGRAY);
    
    mask1 = (maskR+maskB+maskG+maskGRAY)>=1;
    
    M=3;
    for j=1:M:J-M+1
        for k=1:M:K-M+1
            
            tempdiff = GRAY(j:j+M-1,k:k+M-1)  - SourceBackgroundGRAY(j:j+M-1,k:k+M-1);
            MAD = sum(abs(tempdiff(:)) )/M^2;
            if (  MAD>=(2*maxnoiseGRAY/M)  )
                mask2(j:j+M-1,k:k+M-1) = 1;
            else
                mask2(j:j+M-1,k:k+M-1) = 0;
            end;
            
        end;
    end;
    
    mask2(   size(mask2,1)+1:J  ,  :   ) = mask2(  2*size(mask2,1)+1-J:size(mask2,1)  ,  :   );
    mask2(   :  ,  size(mask2,2)+1:K   ) = mask2(  :  ,  2*size(mask2,2)+1-K:size(mask2,2)   );
    
    mask = mask2;
    
    I_Background = I_Background_global;                %%%  reading  background picture to I_Background - coloured
    dm = im2double(mask);                                                      %% mask is the Ibw2 filled - binary image
    inv = ones(size(dm,1),size(dm,2))-dm;                        %%% inv1 is the inverse of dm1 - binary image
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
    FINAL(i-nfi) = im2frame(im2double(y)+I_Background);
    
    i=i+1;
     
end;
 
movie2avi(FINAL,'MoviesResults\DSP_FINAL14c152.avi') ;


