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

Ip = frame2im(mov(srf));
REDp = im2double(Ip(:,:,1));
GREENp = im2double(Ip(:,:,2));
BLUEp = im2double(Ip(:,:,3));
[Hp,Sp,Vp] = rgb2hsv(Ip);

RR = RED-RunningBackgroundRED;
GG = GREEN-RunningBackgroundGREEN;
BB = BLUE-RunningBackgroundBLUE;
SS = S-RunningBackgroundS;

maskp = clean_noise_param((abs(RR) +abs(GG) +abs(BB) +abs(SS))>0.15 , 100);
maskp = fill_shape_param4( (medfilt2(maskp,[5 5]) + maskp )>0 ,2,2,15);

M=3;         %%%  2M+1 is the block size in pixels
p=16;        %%%  p refers to the serch-block's size in the MotionVector algorithem.

for i=srf+1:erf-1
    
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
    
    mask1 = clean_noise_param((abs(RR) +abs(GG) +abs(BB) +abs(SS))>0.15 , 100);
    mask1= medfilt2(fill_shape_param4( (medfilt2(mask1,[5 5]) + mask1 )>0 ,2,2,15),[5 5]);
    
    [x,y] = SketchPath(maskp);            % %  returns the points of the extended edge
    SetOfPoints = [x,y];                        % % SetOfPoints contains the edge points by order 
    
    [SetOfNewPointsS] = TraceObjectNTSS(SetOfPoints, double(Sp), double(S), double(maskp), M, p);
    [SetOfNewPointsREDcorr] = TraceObjectNTSScorr(SetOfPoints, double(REDp), double(RED), double(maskp), M, p);
    [SetOfNewPointsGREENcorr] = TraceObjectNTSScorr(SetOfPoints, double(GREENp), double(GREEN), double(maskp), M, p);
    [SetOfNewPointsBLUEcorr] = TraceObjectNTSScorr(SetOfPoints, double(BLUEp), double(BLUE), double(maskp), M, p);
    
    SetOfNewPointsAvg = round((SetOfNewPointsS+SetOfNewPointsREDcorr+SetOfNewPointsBLUEcorr+SetOfNewPointsGREENcorr)/4);
    mask2extended = zeros(J+2,K+2);
    for j=1:size(SetOfNewPointsAvg,1)
         b4 =  SetOfNewPointsAvg(j,1)-1:SetOfNewPointsAvg(j,1)+1;
         b5 = SetOfNewPointsAvg(j,2)-1:SetOfNewPointsAvg(j,2)+1;
        mask2extended(b4+1,b5+1)=1;
    end;
    mask2 = fill_shape_param4( mask2extended(2:J+1,2:K+1) , 5,5,15);
    
    mask = (mask1+mask2) >0;
    
    FINAL(i-srf) = im2frame( im2double(I).*repmat(mask,[1 1 3]) + I_Background_global.*repmat(1-mask,[1 1 3]) );
    
    RunningBackgroundRED = mask.*RunningBackgroundRED + (1-mask).*( alpha*RED + (1-alpha)*RunningBackgroundRED);
    RunningBackgroundGREEN = mask.*RunningBackgroundGREEN + (1-mask).*( alpha*GREEN + (1-alpha)*RunningBackgroundGREEN);
    RunningBackgroundBLUE = mask.*RunningBackgroundBLUE + (1-mask).*( alpha*BLUE + (1-alpha)*RunningBackgroundBLUE);
    RunningBackgroundS = mask.*RunningBackgroundS + (1-mask).*( alpha*S + (1-alpha)*RunningBackgroundS);
    
    maskp = mask;
    Ip = I;
    REDp = im2double(Ip(:,:,1));
    GREENp = im2double(Ip(:,:,2));
    BLUEp = im2double(Ip(:,:,3));
    [Hp,Sp,Vp] = rgb2hsv(Ip);
    
end;

movie2avi(FINAL,'MoviesResults\week23b2.avi','fps',movinfo.FramesPerSecond);

toc