clc;
clear all;
close all;

%%   defining constants  %%


Numpixels =25000;                                  % Numpixels = the saf of the number of pixels 
sfi=1;                                                           % sfi= starting frame index
efi=67;                                                         % efi= ending frame index
dfi=1;                                                            %dfi = difference frame index
nfi=15;                                                          %nfi = the number of frames required for initializatuin

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mov = aviread('samplemovies\capture2.avi',sfi:efi);                                     %%%%  loading a movie
[I_Background_global,map2]=imread('CIMG3564.jpg');                %%%% protected variable I_Background_global
I_Background_global=im2double(I_Background_global);


%%  Initialization %%


sum_source_background = 0;
sigmaGRAY = 0;

i=1;
SumSquareError = 0;

while  (i<nfi)
    
    frame1 = mov(i);
    frame2 = mov(i+1);
    I1 = frame2im(frame1);
    I2 = frame2im(frame2); 
    
    GRAY1 = im2double(rgb2gray(I1));
    GRAY2 = im2double(rgb2gray(I2));
    
    SumSquareError = SumSquareError + (GRAY1-GRAY2).^2;
    
    sum_source_background = sum_source_background + im2double(I1);
    i=i+1;
end;

sigma = (0.5*SumSquareError/(nfi-1)).^0.5;
SAF = 3*im2double(sigma);

SourceBackground = (sum_source_background+im2double(I2))/nfi;      %%% nice trick
SourceBackgroundGRAY = im2double(rgb2gray(SourceBackground));


%%  RUNNING THE PROCESS ON THE REST OF THE MOVIE

[J,K] = size(SourceBackgroundGRAY);
i=i+1;

while (i<=efi)
    
    i
    I = frame2im(mov(i));
    GRAY = im2double(rgb2gray(I));

    diffGRAY = abs(GRAY - SourceBackgroundGRAY);
    
    maskGRAY = im2double(diffGRAY>max(SAF(:)));
    
%     M=3;
%     for j=1:M:J-M+1
%         for k=1:M:K-M+1
%             
%             tempdiff = GRAY(j:j+M-1,k:k+M-1)  - SourceBackgroundGRAY(j:j+M-1,k:k+M-1);
%             MAD = sum(abs(tempdiff(:)) )/M^2;
%             if (  MAD>=(maxnoiseGRAY/M)  )
%                 mask2(j:j+M-1,k:k+M-1) = 1;
%             else
%                 mask2(j:j+M-1,k:k+M-1) = 0;
%             end;
%             
%         end;
%     end;
%     
%     mask2(   size(mask2,1)+1:J  ,  :   ) = mask2(  2*size(mask2,1)+1-J:size(mask2,1)  ,  :   );
%     mask2(   :  ,  size(mask2,2)+1:K   ) = mask2(  :  ,  2*size(mask2,2)+1-K:size(mask2,2)   );
    
    mask = maskGRAY;
    
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


