%%
close all; clc; clear all;
tic

movinfo = aviinfo('Z:\Project\Project_Necessary_Files_Only\samplemovies\Video1111.avi');
mov = aviread('Z:\Project\Project_Necessary_Files_Only\samplemovies\Video1111.avi');                                   %%%%  loading a movie
% [I_Background_global,map2] = imread('backgrounds\wall_messi.jpg');                %%%% protected variable I_Background_global
% I_Background_global = im2double(I_Background_global);

%%% if the camera has an Interlace problem we can use the following
% mov = InterlaceMovie(mov);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sfi=1;                                                     % sfi= starting frame index
efi=size(mov,2);                                           % efi= ending frame index
nfi=15;                                                    % nfi = the number of frames required for initialization - stage 2
srf=nfi+1;                                                   % srf = starting running frame - stage 3
erf=140;                                                   % erf = ending running frame - stage 3
stf=erf+1;                                                 % sti = starting tracking frame - stage 4 
etf=efi;                                                   % eti = ending tracking frame - stage 4

[J,K] = size(rgb2gray(frame2im(mov(1))));

% [N,B,S] = size(I_Background_global);
% I_Background_global = I_Background_global( N-J+1:N , B-K+1:B ,:);

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

    mask1 = clean_noise_param( ( abs(RR) +abs(GG) +abs(BB) +abs(SS) )>0.3 , 2500);
    mask1= medfilt2( solidify_image_param( (medfilt2(mask1,[5 5]) + mask1 )>0 ,2,2,15) , [5 5] );
    mask12 = clean_noise_param( ( (abs(RR)>0.09)+ (abs(GG)>0.09) + (abs(BB)>0.09) )>0 , 2500);
    mask12 = medfilt2( solidify_image_param( (medfilt2(mask12,[5 5]) + mask12 )>0 ,2,2,15) , [5 5] );
    mask13 = clean_noise_param( abs(YY)>0.09 , 2500);
    mask13 = medfilt2( solidify_image_param( (medfilt2(mask13,[5 5]) + mask13 )>0 ,2,2,15) , [5 5] ); 
    
% %   if there is noise (specially effective when pixels are independent and expectation(average) zero      
% 
%     [BlockmaskMADRED] = CreateMaskMAD( RED , SourceBackgroundRED , 0.7 , 3 );
%     BlockmaskMADRED = clean_noise_param(BlockmaskMADRED,800);
%     BlockmaskMADRED =  medfilt2( solidify_image_param( (medfilt2(BlockmaskMADRED,[5 5]) + BlockmaskMADRED )>0 ,5,5,15) , [5 5] );
%     
%     [BlockmaskMADGREEN] = CreateMaskMAD( GREEN , SourceBackgroundGREEN , 0.7 , 3 );
%     BlockmaskMADGREEN = clean_noise_param(BlockmaskMADGREEN,800);
%     BlockmaskMADGREEN =  medfilt2( solidify_image_param( (medfilt2(BlockmaskMADGREEN,[5 5]) + BlockmaskMADGREEN)>0 ,5,5,15) , [5 5] );
%     
%     [BlockmaskMADBLUE] = CreateMaskMAD( BLUE , SourceBackgroundBLUE , 0.7 , 3 );
%     BlockmaskMADBLUE = clean_noise_param(BlockmaskMADBLUE,800);
%     BlockmaskMADBLUE =  medfilt2( solidify_image_param( (medfilt2(BlockmaskMADBLUE,[5 5]) + BlockmaskMADBLUE )>0 ,5,5,15) , [5 5] );    
%     
%     [BlockmaskMADS] = CreateMaskMAD( S , SourceBackgroundS , 1 , 3 );
%     BlockmaskMADS = clean_noise_param(BlockmaskMADS,800);
%     BlockmaskMADS =  medfilt2( solidify_image_param( (medfilt2(BlockmaskMADS,[5 5]) + BlockmaskMADS )>0 ,5,5,15) , [5 5] );        
%     
%     [BlockmaskASDRED] = CreateMaskASD( RED , SourceBackgroundRED , 0.65 , 3 );       %ASD is more robust against noise
%     BlockmaskASDRED = clean_noise_param(BlockmaskASDRED,800);
%     BlockmaskASDRED =  medfilt2( solidify_image_param( (medfilt2(BlockmaskASDRED,[5 5]) + BlockmaskASDRED )>0 ,5,5,15) , [5 5] );
%     
%     [BlockmaskASDGREEN] = CreateMaskASD( GREEN , SourceBackgroundGREEN , 0.65 , 3 );       %ASD is more robust against noise
%     BlockmaskASDGREEN = clean_noise_param(BlockmaskASDGREEN,800);
%     BlockmaskASDGREEN =  medfilt2( solidify_image_param( (medfilt2(BlockmaskASDGREEN,[5 5]) + BlockmaskASDGREEN )>0 ,5,5,15) , [5 5] );
% 
%     [BlockmaskASDBLUE] = CreateMaskASD( BLUE , SourceBackgroundBLUE , 0.65 , 3 );       %ASD is more robust against noise
%     BlockmaskASDBLUE = clean_noise_param(BlockmaskASDBLUE,800);
%     BlockmaskASDBLUE =  medfilt2( solidify_image_param( (medfilt2(BlockmaskASDBLUE,[5 5]) + BlockmaskASDBLUE )>0 ,5,5,15) , [5 5] );    
%     
%     [BlockmaskASDS] = CreateMaskASD( S , SourceBackgroundS , 0.95 , 3 );       %ASD is more robust against noise
%     BlockmaskASDS = clean_noise_param(BlockmaskASDS,800);
%     BlockmaskASDS =  medfilt2( solidify_image_param( (medfilt2(BlockmaskASDS,[5 5]) + BlockmaskASDS )>0 ,5,5,15) , [5 5] );    
% 
%     BlockmaskMAD = (BlockmaskMADS+BlockmaskMADBLUE+BlockmaskMADGREEN+BlockmaskMADRED)>0;    
%     BlockmaskASD =
%     (BlockmaskASDS+BlockmaskASDBLUE+BlockmaskASDGREEN+BlockmaskASDRED)>0;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    se = strel('disk',10);       %%%will be defined later before the loop
    mask = solidify_image_param(  (mask1+mask12+mask13)>0 , 3 , 3 , 10) ;
    mask = imdilate(mask,se);
    mask = fill_holes_param(mask,2500);
    mask = imerode(mask,se); 
    
    %%%%%%       Only at this point we now have 3 different masks       %%%%%%

    %  The idea is to make a non-casual prediction to mask_p using mask_p_p and mask 
    % in order to fill false holes and classify them as foreground 
    
    if (iterations>=3)  
       
%         REDp = Ip(:,:,1);
%         [x,y] = find(mask_p==1);            % %  returns the points of the extended edge
%         SetOfPoints = [x,y];
%         [SetOfNewPointsREDcorr] = TraceObjectNTSScorr( SetOfPoints , REDp , RED, mask_p , 3 , 16);
%         traced_mask_REDcorr = zeros(J,K);
%         for j = 1:size(SetOfNewPointsREDcorr,1)
%             traced_mask_REDcorr( SetOfNewPointsREDcorr(j,1), SetOfNewPointsREDcorr(j,2) ) =1;
%         end;
%         traced_mask_REDcorr = ControlTracedMask( SetOfPoints , SetOfNewPointsREDcorr , mask_p , 5 , 2 );
        
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
            mask_p = imdilate(mask_p,se);
            mask_p = fill_holes_param(mask_p,2500);
            mask_p = imerode(mask_p,se);
        end;
%         TRACE(iterations-2) = im2frame(I.*repmat(traced_mask_REDcorr,[1 1 3]) + I_Background_global.*repmat(1-traced_mask_REDcorr,[1 1 3]) );        
%         FINAL(iterations-2) = im2frame(Ip.*repmat(mask_p,[1 1 3]) + I_Background_global.*repmat(1-mask_p,[1 1 3]) );
    
    end;
    
% % % % % %           Update iteration of the learning background algorithem          % % % % % %   

    RunningBackgroundRED = mask.*RunningBackgroundRED + (1-mask).*( alpha*RED + (1-alpha)*RunningBackgroundRED);
    RunningBackgroundGREEN = mask.*RunningBackgroundGREEN + (1-mask).*( alpha*GREEN + (1-alpha)*RunningBackgroundGREEN);
    RunningBackgroundBLUE = mask.*RunningBackgroundBLUE + (1-mask).*( alpha*BLUE + (1-alpha)*RunningBackgroundBLUE);
    RunningBackgroundS = mask.*RunningBackgroundS + (1-mask).*( alpha*S + (1-alpha)*RunningBackgroundS);
    RunningBackgroundY = mask.*RunningBackgroundY + (1-mask).*( alpha*Y + (1-alpha)*RunningBackgroundY);

    mask_p_p = mask_p;                  %%% at this point we no longer have 3 masks, but only 2
    mask_p = mask;                          
    Ip=I;                                           % because we need the previous frame to make the movie.

end;

% movie2avi(FINAL,'MoviesResults\week27_4.avi','fps',movinfo.FramesPerSecond);
% movie2avi(TRACE,'MoviesResults\week26b+controltrace.avi','fps',movinfo.Fr
% amesPerSecond);

toc%%%%%%%%%%%%%%%%%%%%%%%%