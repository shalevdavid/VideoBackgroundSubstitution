%%
close all; clc; clear all;
tic

movinfo = aviinfo('V:\22a.avi');
mov = aviread('V:\22a.avi',1:150);                                   %%%%  loading a movie
[I_Background_global,map2] = imread('backgrounds\wall_messi.jpg');                %%%% protected variable I_Background_global
I_Background_global = im2double(I_Background_global);

%%% if the camera has an Interlace problem we can use the following
% mov = InterlaceMovie(mov);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sfi=1;                                                     % sfi= starting frame index
efi=size(mov,2);                                           % efi= ending frame index
nfi=1;                                                    % nfi = the number of frames required for initialization - stage 2
srf=nfi+1;                                                   % srf = starting running frame - stage 3
erf=150;                                                   % erf = ending running frame - stage 3
stf=erf+1;                                                 % sti = starting tracking frame - stage 4 
etf=efi;                                                   % eti = ending tracking frame - stage 4

[J,K] = size(rgb2gray(frame2im(mov(1))));

[N,B,S] = size(I_Background_global);
I_Background_global = I_Background_global( N-J+1:N , B-K+1:B ,:);

toc
%%
tic

SourceBackgroundRED = 0;
SourceBackgroundGREEN = 0;
SourceBackgroundBLUE = 0;
SourceBackgroundS = 0;
SourceBackgroundY = 0;

for i=1:nfi
    
    I = im2double(frame2im(mov(i)));
    RED = I(:,:,1);
    GREEN = I(:,:,2);
    BLUE = I(:,:,3);
    [H,S,V] = rgb2hsv(I);
    YCBCR = rgb2ycbcr(I);
    Y = YCBCR(:,:,1);

    SourceBackgroundRED = SourceBackgroundRED + RED;
    SourceBackgroundGREEN = SourceBackgroundGREEN + GREEN;
    SourceBackgroundBLUE = SourceBackgroundBLUE + BLUE;
    SourceBackgroundS = SourceBackgroundS + S;
    SourceBackgroundY = SourceBackgroundY + Y;
    
end;

SourceBackgroundRED = SourceBackgroundRED/nfi;
SourceBackgroundGREEN = SourceBackgroundGREEN/nfi;
SourceBackgroundBLUE = SourceBackgroundBLUE/nfi;
SourceBackgroundS = SourceBackgroundS/nfi;
SourceBackgroundY = SourceBackgroundY/nfi;

toc
%%
tic

alpha = 0.125;       % The Learning Parameter 
RunningBackgroundRED = SourceBackgroundRED;
RunningBackgroundGREEN = SourceBackgroundGREEN;
RunningBackgroundBLUE = SourceBackgroundBLUE;
RunningBackgroundS = SourceBackgroundS;
RunningBackgroundY = SourceBackgroundY;

mask_p = [];
mask_p_p = [];
iterations = 0;

for i=srf:erf-1                         % if maskp is in use it should start from  srf-1
    
    i           
    iterations = iterations+1;
    I = im2double(frame2im(mov(i)));
    RED = I(:,:,1);
    GREEN = I(:,:,2);
    BLUE = I(:,:,3);
    [H,S,V] = rgb2hsv(I);
    YCBCR = rgb2ycbcr(I);
    Y = YCBCR(:,:,1);
    
    runningBackground(:,:,1)= RunningBackgroundRED;
    runningBackground(:,:,2)= RunningBackgroundGREEN;
    runningBackground(:,:,3)= RunningBackgroundBLUE;
    
    RR = RED-RunningBackgroundRED;
    GG = GREEN-RunningBackgroundGREEN;
    BB = BLUE-RunningBackgroundBLUE;
    YY = Y - RunningBackgroundY;
    SS = S-RunningBackgroundS;

    mask1 = clean_noise_param( ( abs(RR) +abs(GG) +abs(BB) +abs(SS) )>0.3 , 1600);
    mask1= medfilt2( solidify_image_param( (medfilt2(mask1,[5 5]) + mask1 )>0 ,5,5,15) , [5 5] );
    mask12 = clean_noise_param( ( (abs(RR)>0.085)+ (abs(GG)>0.085) + (abs(BB)>0.085) )>0 , 1600);
    mask12 = medfilt2( solidify_image_param( (medfilt2(mask12,[5 5]) + mask12 )>0 ,5,5,15) , [5 5] );
    mask13 = clean_noise_param( abs(YY)>0.07 , 1600);
    mask13 = medfilt2( solidify_image_param( (medfilt2(mask13,[5 5]) + mask13 )>0 ,5,5,15) , [5 5] ); 
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    mask = solidify_image_param(  (mask1+mask12+mask13)>0 , 3,3,10);
    
    %%%%%%       Only at this point we now have 3 different masks       %%%%%%
    
    RunningBackgroundRED = mask.*RunningBackgroundRED + (1-mask).*( alpha*RED + (1-alpha)*RunningBackgroundRED);
    RunningBackgroundGREEN = mask.*RunningBackgroundGREEN + (1-mask).*( alpha*GREEN + (1-alpha)*RunningBackgroundGREEN);
    RunningBackgroundBLUE = mask.*RunningBackgroundBLUE + (1-mask).*( alpha*BLUE + (1-alpha)*RunningBackgroundBLUE);
    RunningBackgroundS = mask.*RunningBackgroundS + (1-mask).*( alpha*S + (1-alpha)*RunningBackgroundS);
     RunningBackgroundY = mask.*RunningBackgroundY + (1-mask).*( alpha*Y + (1-alpha)*RunningBackgroundY);

    %  The idea is to make a non-casual prediction to mask_p using mask_p_p and mask 
    % in order to fill false holes and classify them as foreground 
    
    if (iterations>=3)  
       
        REDp = Ip(:,:,1);
        [x,y] = find(mask_p==1);            % %  returns the points of the extended edge
        SetOfPoints = [x,y];
        [SetOfNewPointsREDcorr] = TraceObjectNTSScorr( SetOfPoints , REDp , RED, mask_p , 3 , 16);
        traced_mask_REDcorr = zeros(J,K);
        for j = 1:size(ControledSetREDcorr,1)
            traced_mask_REDcorr( ControledSetREDcorr(j,1), ControledSetREDcorr(j,2) ) =1;
        end;
        traced_mask_REDcorr = ControledSetREDcorr = ControlTracedMask( SetOfPoints , SetOfNewPointsREDcorr , traced_mask_REDcorr , 5 , 2 );
        
        if (  sum(abs(mask(:)))>0  && sum(abs(mask_p(:)))>0  &&  sum(abs(mask_p_p(:)))>0  )
            mask_p_prediction = zeros(J,K);
            STATS_mask = regionprops(double(mask),'centroid');
            center_mask = STATS_mask.Centroid;
            STATS_mask_p = regionprops(double(mask_p),'centroid');
            center_mask_p = STATS_mask_p.Centroid;
            STATS_mask_p_p = regionprops(double(mask_p_p),'centroid');
            center_mask_p_p = STATS_mask_p_p.Centroid;
            movement_vector = round( center_mask_p - center_mask_p_p ); 
            mask_p_p_centered = MaskCenterization(mask_p_p,movement_vector);
            movement_vector = round( center_mask_p - center_mask ); 
            mask_centered = MaskCenterization(mask,movement_vector);
            mask_p = (mask_p + mask_p_p.*mask + mask_p_p_centered.*mask_centered)>0;
        end;
        TRACE(iterations-2) = im2frame(I.*repmat(traced_mask_REDcorr,[1 1 3]) + I_Background_global.*repmat(1-traced_mask_REDcorr,[1 1 3]) );        
        FINAL(iterations-2) = im2frame(Ip.*repmat(mask_p,[1 1 3]) + I_Background_global.*repmat(1-mask_p,[1 1 3]) );
    
    end;

    mask_p_p = mask_p;                  %%% at this point we no longer have 3 masks, but only 2
    mask_p = mask;                          
    Ip=I;                                           % because we need the previous frame to make the movie.

end;

movie2avi(FINAL,'MoviesResults\week26b+control.avi','fps',movinfo.FramesPerSecond);
movie2avi(TRACE,'MoviesResults\week26b+controltrace.avi','fps',movinfo.FramesPerSecond);

toc