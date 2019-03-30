clc;
clear all;
close all;

%%   defining constants  %%


Numpixels =25000;                                  % Numpixels = the saf of the number of pixels 
sfi=1;                                                           % sfi= starting frame index
efi=101;                                                         % efi= ending frame index
dfi=1;                                                            %dfi = difference frame index
nfi=15;                                                          %nfi = the number of frames required for initializatuin

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mov = aviread('Z:\Project\samplemovies\video4444.avi',sfi:efi);                                     %%%%  loading a movie
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
    
    maskR = im2bw(diffR,maxnoiseR/4);
    maskG = im2bw(diffG,maxnoiseG/4);
    maskB = im2bw(diffB,maxnoiseB/4);
    maskGRAY = im2bw(diffGRAY,maxnoiseGRAY/4);
    
    mask = (maskR+maskB+maskG+maskGRAY)>=1;
    
    mask = clean_noise(mask);
    
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
 
movie2avi(FINAL,'DSP_FINAL14.avi') ;

%% 
% %%   The  algorithem of finding the first good frame     %%
% 
% frame1 = mov(1);
% frame2 = mov(1+dfi);   
% [I1,Map] = frame2im(frame1);
% GRAY1= rgb2gray(I1);
% [I2,Map] = frame2im(frame2);
% GRAY2 = rgb2gray(I2);
% diff = abs(im2double(GRAY2) - im2double(GRAY1));
% diff = im2bw(diff,0.1);                                                      %%%%  now diff is binary
% summation = sum(diff(:));
% i=sfi;
% 
% 
%  while  ((summation < Numpixels) && ((i+2*dfi)<=efi))
%     i=i+dfi;
%     summation=0;
%     frame1=mov(i-sfi);
%     frame2=mov(i+dfi-sfi);
%     [I1,Map] = frame2im(frame1);
%    GRAY1= rgb2gray(I1);
%     [I2,Map] = frame2im(frame2);
%    GRAY2 = rgb2gray(I2);
%    diff = abs(im2double(GRAY2) - im2double(GRAY1));
%    diff = im2bw(diff,0.1);                                                    %%%%  now diff is binary
%    summation = sum(diff(:));
%    i                                                                                                    %% check
%    summation                                                                               %%  check
% end;
% 
% [H1,S1,V1]=rgb2hsv(I1);
% [H2,S2,V2]=rgb2hsv(I2);
% DS=im2bw(abs(S1-S2),0.3);
% DV=im2bw(abs(V1-V2),0.1);
% 
% R1=I1(:,:,1);
% R2=I2(:,:,1);
% G1=I1(:,:,2);
% G2=I2(:,:,2);
% B1=I1(:,:,3);
% B2=I2(:,:,3);
% DR=im2bw(abs(R1-R2),0.05);
% DG=im2bw(abs(G1-G2),0.05);
% DB=im2bw(abs(B1-B2),0.05);
% 
% % clean_DS=clean_noise(DS);
% % clean_DV=clean_noise(DV);
% % total_diff=(clean_DV+clean_DS)>=1;
% 
% total_diff=clean_noise(((DS+DV+DR+DG+DB)>=1));
% 
% % imshow(total_diff);
% diff=total_diff;
% clean_diff=diff;
% I_close = fill_shape(clean_diff);
% 
% %%  improving  I_close  to  be  more  accurate
% 
% frame1_a=mov(i+1-sfi); 
% frame2_a=mov(i+1+dfi-sfi);
% [I1_a,Map] = frame2im(frame1_a);
% Ibw1_a= rgb2gray(I1_a);
% [I2_a,Map] = frame2im(frame2_a);
% Ibw2_a = rgb2gray(I2_a);
% diff_a = abs(im2double(Ibw2_a) - im2double(Ibw1_a));
% diff_a = im2bw(diff_a,0.1);
% [H1_a,S1_a,V1_a]=rgb2hsv(I1_a);
% [H2_a,S2_a,V2_a]=rgb2hsv(I2_a);
% DS_a=im2bw(abs(S1_a-S2_a),0.3);
% DV_a=im2bw(abs(V1_a-V2_a),0.1);
% 
% R1_a=I1_a(:,:,1);
% R2_a=I2_a(:,:,1);
% G1_a=I1_a(:,:,2);
% G2_a=I2_a(:,:,2);
% B1_a=I1_a(:,:,3);
% B2_a=I2_a(:,:,3);
% DR_a=im2bw(abs(R1_a-R2_a),0.05);
% DG_a=im2bw(abs(G1_a-G2_a),0.05);
% DB_a=im2bw(abs(B1_a-B2_a),0.05);
% 
% % clean_DS_a=clean_noise(DS_a);
% % clean_DV_a=clean_noise(DV_a);
% % total_diff_a=(clean_DV_a+clean_DS_a)>=1;
% 
% total_diff_a=clean_noise(((DS_a+DV_a+DR_a+DG_a+DB_a)>=1));
% 
% % imshow(total_diff_a);
% diff_a=total_diff_a;
% clean_diff_a=diff_a;
% I_close_a = fill_shape(clean_diff_a);
% 
% 
% mask=I_close.*I_close_a;
% 
% 
% %%  Final Part of The Project %%
% 
% 
% I_Background = I_Background_global;                %%%  reading  background picture to I_Background - coloured
% 
% dm1 = im2double(mask);         %% mask is the Ibw2 filled - binary image
% 
% inv1 = ones(size(dm1,1),size(dm1,2))-dm1;   %%% inv1 is the inverse of dm1 - binary image
% 
% inv1 = [ones(size(inv1,1),(size(I_Background,2)-size(inv1,2))),inv1];    
% inv1 = [ones((size(I_Background,1)-size(inv1,1)),size(inv1,2));inv1];
% %%% now inv1 is expended
% 
% for j=1:3
%     I2(:,:,j) = double(I2(:,:,j)).*dm1;
% end;
% 
% for j=1:3
%     I_Background(:,:,j) = double(I_Background(:,:,j)).*inv1;
% end;
% 
% for j=1:3
%     x(:,:,j) = [zeros(size(I2(:,:,j),1),(size(I_Background,2)-size(I2(:,:,j),2))),I2(:,:,j)]; 
%     y(:,:,j) = [zeros((size(I_Background,1)-size(x(:,:,j),1)),size(x(:,:,j),2));x(:,:,j)];
% end;
% 
%     
% % figure, imshow(y);
% 
% FINAL(1) = im2frame(y+I_Background);
% 
% 
% %%%%%%%%%%% Running Proccess on the rest of the video %%%%%%%%%%%%%%
% 
% 
% M=8;        %%%  M is the block size in pixels
% p=16;        %%%  p refers to the serch-block's size in the MotionVector algorithem.
% 
% 
% [n_row,n_col]=size(Ibw1);
% 
% if ( mod(n_row,M)==0 )
%     last_row = n_row;
% else 
%     last_row = M * (floor(n_row/M)+1);
% end;
%     
% if ( mod(n_col,M)==0 )
%     last_col = n_col;
% else 
%     last_col = M * (floor(n_col/M)+1);
% end;
% 
% 
% [I2,Map] = frame2im(frame2);
% 
% Ibw2 = rgb2gray(I2);
% [H2,S2,V2]=rgb2hsv(I2);
% R2=I2(:,:,1);
% G2=I2(:,:,2);
% B2=I2(:,:,3);
% 
% for k=(i-sfi+2):efi
% 
%     k                                                                                                                     %% check
%     frame3=mov(k);
%     [I3,Map] = frame2im(frame3);
%     Ibw3 = rgb2gray(I3);
%     [H3,S3,V3]=rgb2hsv(I3);
%     R3=I3(:,:,1);
%     G3=I3(:,:,2);
%     B3=I3(:,:,3);
%     
%     [motionVect, ARPScomputations] = motionEstARPS(double(Ibw3), double(Ibw2),M,p );                   
%     [mask_next_estimation] = motionComp(double(mask), motionVect, M);    
%         
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     
%     I_Background = I_Background_global;                     %%%  reading  background picture to I_Background - colour
% 
%     dm1 = im2double(mask_next_estimation);                 %%% mask is the Ibw2 filled - binary image
%     
%     inv1 = ones(size(dm1,1),size(dm1,2))-dm1;                        %%% inv1 is the inverse of dm1 - binary image
%     inv1 = [ones(size(inv1,1),(size(I_Background,2)-size(inv1,2))),inv1];    
%     inv1 = [ones((size(I_Background,1)-size(inv1,1)),size(inv1,2));inv1];
%     
%     for j=1:3
%         I3(:,:,j) = double(I3(:,:,j)).*dm1;
%     end;
%   
%     for j=1:3
%         I_Background(:,:,j) = double(I_Background(:,:,j)).*inv1;
%     end;
%   
%     for j=1:3
%         x(:,:,j) = [zeros(size(I3(:,:,j),1),(size(I_Background,2)-size(I3(:,:,j),2))),I3(:,:,j)]; 
%         y(:,:,j) = [zeros((size(I_Background,1)-size(x(:,:,j),1)),size(x(:,:,j),2));x(:,:,j)];
%     end;
%  
%     FINAL(k-i+sfi) = im2frame(y+I_Background);
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     
%     mask = mask_next_estimation;
%     Ibw2=Ibw3;
%     H2=H3;
%     S2=S3;
%     V2=V3;
%     R2=R3;
%     G2=G3;
%     B2=B3;
% 
% end;
% 
% 
% movie2avi(FINAL,'DSP_FINAL14.avi') ;