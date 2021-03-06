%%
close all; clc; clear all;
tic

movinfo = aviinfo('samplemovies\dmf070704-001.avi');
mov = aviread('samplemovies\dmf070704-001.avi');                                   %%%%  loading a movie
[I_Background_global,map2] = imread('backgrounds\messiGolaso.jpg');                %%%% protected variable I_Background_global
I_Background_global = im2double(I_Background_global);

%%% if the camera has an Interlace problem we can use the following
mov = InterlaceMovie(mov);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sfi=1;                                                     % sfi= starting frame index
efi=size(mov,2);                                           % efi= ending frame index
nfi=40;                                                    % nfi = the number of frames required for initialization - stage 2
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

% SourceBackgroundGRAY = 0;
SourceBackgroundRED = 0;
SourceBackgroundGREEN = 0;
SourceBackgroundBLUE = 0;
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
    SourceBackgroundS = SourceBackgroundS +S;
    
%     energy_source = sum(GREEN(:).^2)
    
end;

% SourceBackgroundGRAY = SourceBackgroundGRAY/nfi;
SourceBackgroundRED = SourceBackgroundRED/nfi;
SourceBackgroundGREEN = SourceBackgroundGREEN/nfi;
SourceBackgroundBLUE = SourceBackgroundBLUE/nfi;
SourceBackgroundS = SourceBackgroundS/nfi;

toc
%%
tic

alpha = 0.125;       % The Learning Parameter 
RunningBackgroundRED = SourceBackgroundRED;
RunningBackgroundGREEN = SourceBackgroundGREEN;
RunningBackgroundBLUE = SourceBackgroundBLUE;
RunningBackgroundS = SourceBackgroundS;

% Ip = frame2im(mov(srf));
% REDp = im2double(Ip(:,:,1));
% GREENp = im2double(Ip(:,:,2));
% BLUEp = im2double(Ip(:,:,3));
% [Hp,Sp,Vp] = rgb2hsv(Ip);
% 
% RR = RED-RunningBackgroundRED;
% GG = GREEN-RunningBackgroundGREEN;
% BB = BLUE-RunningBackgroundBLUE;
% SS = S-RunningBackgroundS;
% 
% maskp = clean_noise_param((abs(RR) +abs(GG) +abs(BB) +abs(SS))>0.15 , 100);
% maskp = fill_shape_param4( (medfilt2(maskp,[5 5]) + maskp )>0 ,2,2,15);
% 
% RunningBackgroundRED = maskp.*RunningBackgroundRED + (1-maskp).*( alpha*RED + (1-alpha)*RunningBackgroundRED);
% RunningBackgroundGREEN = maskp.*RunningBackgroundGREEN + (1-maskp).*( alpha*GREEN + (1-alpha)*RunningBackgroundGREEN);
% RunningBackgroundBLUE = maskp.*RunningBackgroundBLUE + (1-maskp).*( alpha*BLUE + (1-alpha)*RunningBackgroundBLUE);
% RunningBackgroundS = maskp.*RunningBackgroundS + (1-maskp).*( alpha*S + (1-alpha)*RunningBackgroundS);

M=3;         %%%  2M+1 is the block size in pixels
p=16;        %%%  p refers to the serch-block's size in the MotionVector algorithem.

for i=srf:erf-1                         % if maskp is in use it should start from  srf-1
    
    i           
    I = frame2im(mov(i));
    RED = im2double(I(:,:,1));
    GREEN = im2double(I(:,:,2));
    BLUE = im2double(I(:,:,3));
    [H,S,V] = rgb2hsv(I);
    
    RR = RED-RunningBackgroundRED;
    GG = GREEN-RunningBackgroundGREEN;
    BB = BLUE-RunningBackgroundBLUE;
    SS = S-RunningBackgroundS;
    
    mask1 = clean_noise_param( (abs(RR) +abs(GG) +abs(BB) +abs(SS))>0.2 , 100);
    mask1= medfilt2( solidify_image_param( (medfilt2(mask1,[5 5]) + mask1 )>0 ,5,5,15) , [5 5] );
    mask12 = clean_noise_param( ( (abs(RR)>0.06)+ (abs(GG)>0.06) + (abs(BB)>0.06) )>0 , 800);
    mask12 = medfilt2( solidify_image_param( (medfilt2(mask12,[5 5]) + mask12 )>0 ,5,5,15) , [5 5] );
    
%     [x,y] = SketchPath(maskp);            % %  returns the points of the extended edge
%     SetOfPoints = [x,y];                        % % SetOfPoints contains the edge points by order
%     
%     [SetOfNewPointsS] = TraceObjectNTSS(SetOfPoints, double(Sp), double(S), double(maskp), M, p);
%     [SetOfNewPointsREDcorr] = TraceObjectNTSScorr(SetOfPoints, double(REDp), double(RED), double(maskp), M, p);
%     [SetOfNewPointsGREENcorr] = TraceObjectNTSScorr(SetOfPoints, double(GREENp), double(GREEN), double(maskp), M, p);
%     [SetOfNewPointsBLUEcorr] = TraceObjectNTSScorr(SetOfPoints, double(BLUEp), double(BLUE), double(maskp), M, p);
%     
%     [ControledSetS] = ControledPoints(SetOfNewPointsS, 2 , 4);
%     [ControledSetREDcorr] = ControledPoints(SetOfNewPointsREDcorr, 2 , 4);
%     [ControledSetGREENcorr] = ControledPoints(SetOfNewPointsGREENcorr, 2 , 4);
%     [ControledSetBLUEcorr] = ControledPoints(SetOfNewPointsBLUEcorr, 2 , 4);
%     
%     maskControl = zeros(J,K);
%     for j = 1:size(ControledSetS,1)
%         maskControl( ControledSetS(j,1), ControledSetS(j,2) ) =1;
%     end;
%      for j = 1:size(ControledSetREDcorr,1)
%          maskControl( ControledSetREDcorr(j,1), ControledSetREDcorr(j,2) ) =1;
%      end;
%       for j = 1:size(ControledSetGREENcorr,1)
%         maskControl( ControledSetGREENcorr(j,1), ControledSetGREENcorr(j,2) )=1;
%      end;
%      for j = 1:size(ControledSetBLUEcorr,1)
%         maskControl( ControledSetBLUEcorr(j,1),ControledSetBLUEcorr(j,2) )=1;
%      end;
%    
%     mask2 = fill_shape_param4( maskControl ,5,5,15);

    [BlockmaskMADRED] = CreateMaskMAD( RED , SourceBackgroundRED , 0.7 , 3 );
    BlockmaskMADRED = clean_noise_param(BlockmaskMADRED,800);
    BlockmaskMADRED =  medfilt2( solidify_image_param( (medfilt2(BlockmaskMADRED,[5 5]) + BlockmaskMADRED )>0 ,5,5,15) , [5 5] );
    
    [BlockmaskMADGREEN] = CreateMaskMAD( GREEN , SourceBackgroundGREEN , 0.7 , 3 );
    BlockmaskMADGREEN = clean_noise_param(BlockmaskMADGREEN,800);
    BlockmaskMADGREEN =  medfilt2( solidify_image_param( (medfilt2(BlockmaskMADGREEN,[5 5]) + BlockmaskMADGREEN )>0 ,5,5,15) , [5 5] );
    
    [BlockmaskMADBLUE] = CreateMaskMAD( BLUE , SourceBackgroundBLUE , 0.7 , 3 );
    BlockmaskMADBLUE = clean_noise_param(BlockmaskMADBLUE,800);
    BlockmaskMADBLUE =  medfilt2( solidify_image_param( (medfilt2(BlockmaskMADBLUE,[5 5]) + BlockmaskMADBLUE )>0 ,5,5,15) , [5 5] );    
    
    [BlockmaskMADS] = CreateMaskMAD( S , SourceBackgroundS , 1 , 3 );
    BlockmaskMADS = clean_noise_param(BlockmaskMADS,800);
    BlockmaskMADS =  medfilt2( solidify_image_param( (medfilt2(BlockmaskMADS,[5 5]) + BlockmaskMADS )>0 ,5,5,15) , [5 5] );        
    
    [BlockmaskASDRED] = CreateMaskASD( RED , SourceBackgroundRED , 0.65 , 3 );       %ASD is more robust against noise
    BlockmaskASDRED = clean_noise_param(BlockmaskASDRED,800);
    BlockmaskASDRED =  medfilt2( solidify_image_param( (medfilt2(BlockmaskASDRED,[5 5]) + BlockmaskASDRED )>0 ,5,5,15) , [5 5] );
    
    [BlockmaskASDGREEN] = CreateMaskASD( GREEN , SourceBackgroundGREEN , 0.65 , 3 );       %ASD is more robust against noise
    BlockmaskASDGREEN = clean_noise_param(BlockmaskASDGREEN,800);
    BlockmaskASDGREEN =  medfilt2( solidify_image_param( (medfilt2(BlockmaskASDGREEN,[5 5]) + BlockmaskASDGREEN )>0 ,5,5,15) , [5 5] );

    [BlockmaskASDBLUE] = CreateMaskASD( BLUE , SourceBackgroundBLUE , 0.65 , 3 );       %ASD is more robust against noise
    BlockmaskASDBLUE = clean_noise_param(BlockmaskASDBLUE,800);
    BlockmaskASDBLUE =  medfilt2( solidify_image_param( (medfilt2(BlockmaskASDBLUE,[5 5]) + BlockmaskASDBLUE )>0 ,5,5,15) , [5 5] );    
    
    [BlockmaskASDS] = CreateMaskASD( S , SourceBackgroundS , 0.95 , 3 );       %ASD is more robust against noise
    BlockmaskASDS = clean_noise_param(BlockmaskASDS,800);
    BlockmaskASDS =  medfilt2( solidify_image_param( (medfilt2(BlockmaskASDS,[5 5]) + BlockmaskASDS )>0 ,5,5,15) , [5 5] );    

    BlockmaskMAD = (BlockmaskMADS+BlockmaskMADBLUE+BlockmaskMADGREEN+BlockmaskMADRED)>0;    
    BlockmaskASD = (BlockmaskASDS+BlockmaskASDBLUE+BlockmaskASDGREEN+BlockmaskASDRED)>0;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    mask = solidify_image_param(  (BlockmaskASD+BlockmaskMAD+mask1+mask12)>0 , 3,3,10);
    
%     mask = solidify_image_param(  (mask1+mask12)>0 , 3,3,10);
    
    FINAL(i-srf+1) = im2frame( im2double(I).*repmat(mask,[1 1 3]) + I_Background_global.*repmat(1-mask,[1 1 3]) );
    
    RunningBackgroundRED = mask.*RunningBackgroundRED + (1-mask).*( alpha*RED + (1-alpha)*RunningBackgroundRED);
    RunningBackgroundGREEN = mask.*RunningBackgroundGREEN + (1-mask).*( alpha*GREEN + (1-alpha)*RunningBackgroundGREEN);
    RunningBackgroundBLUE = mask.*RunningBackgroundBLUE + (1-mask).*( alpha*BLUE + (1-alpha)*RunningBackgroundBLUE);
    RunningBackgroundS = mask.*RunningBackgroundS + (1-mask).*( alpha*S + (1-alpha)*RunningBackgroundS);  
    
%     maskp = mask;
%     Ip = I;
%     REDp = im2double(Ip(:,:,1));
%     GREENp = im2double(Ip(:,:,2));
%     BLUEp = im2double(Ip(:,:,3));
%     [Hp,Sp,Vp] = rgb2hsv(Ip);
    
end;

movie2avi(FINAL,'MoviesResults\week25b3.avi','fps',movinfo.FramesPerSecond);

toc