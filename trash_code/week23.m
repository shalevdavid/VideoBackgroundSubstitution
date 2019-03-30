%%
close all; clc; clear all;
tic

movinfo = aviinfo('samplemovies\dmf070502-004.avi');
mov = aviread('samplemovies\dmf070502-004.avi');                                   %%%%  loading a movie
[I_Background_global,map2] = imread('backgrounds\messiGolaso.jpg');                %%%% protected variable I_Background_global
I_Background_global = im2double(I_Background_global);

%%% if the camera has an Interlace problem we can use the following
% mov = InterlaceMovie(mov);
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
SourceBackgroundH = 0;
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
    SourceBackgroundH = SourceBackgroundH + H;
    SourceBackgroundS = SourceBackgroundS +S;
    
%     energy_source = sum(GREEN(:).^2)
    
end;

% SourceBackgroundGRAY = SourceBackgroundGRAY/nfi;
SourceBackgroundRED = SourceBackgroundRED/nfi;
SourceBackgroundGREEN = SourceBackgroundGREEN/nfi;
SourceBackgroundBLUE = SourceBackgroundBLUE/nfi;
SourceBackgroundH = SourceBackgroundH/nfi;
SourceBackgroundS = SourceBackgroundS/nfi;

toc
%%
tic

alpha1 = 0.05;       % The Learning Parameter 
RunningBackgroundRED1 = SourceBackgroundRED;
RunningBackgroundGREEN1 = SourceBackgroundGREEN;
RunningBackgroundBLUE1 = SourceBackgroundBLUE;
RunningBackgroundS1 = SourceBackgroundS;

alpha2 = 0.125;       % The Learning Parameter 
RunningBackgroundRED2 = SourceBackgroundRED;
RunningBackgroundGREEN2 = SourceBackgroundGREEN;
RunningBackgroundBLUE2 = SourceBackgroundBLUE;
RunningBackgroundS2 = SourceBackgroundS;

alpha3 = 0.2;       % The Learning Parameter 
RunningBackgroundRED3 = SourceBackgroundRED;
RunningBackgroundGREEN3 = SourceBackgroundGREEN;
RunningBackgroundBLUE3 = SourceBackgroundBLUE;
RunningBackgroundS3 = SourceBackgroundS;

alpha4 = 0.3;       % The Learning Parameter 
RunningBackgroundRED4 = SourceBackgroundRED;
RunningBackgroundGREEN4 = SourceBackgroundGREEN;
RunningBackgroundBLUE4 = SourceBackgroundBLUE;
RunningBackgroundS4 = SourceBackgroundS;

alpha5 = 0.4;       % The Learning Parameter 
RunningBackgroundRED5 = SourceBackgroundRED;
RunningBackgroundGREEN5 = SourceBackgroundGREEN;
RunningBackgroundBLUE5 = SourceBackgroundBLUE;
RunningBackgroundS5 = SourceBackgroundS;

alpha6 = 0.5;       % The Learning Parameter 
RunningBackgroundRED6 = SourceBackgroundRED;
RunningBackgroundGREEN6 = SourceBackgroundGREEN;
RunningBackgroundBLUE6 = SourceBackgroundBLUE;
RunningBackgroundS6 = SourceBackgroundS;

for i=srf:erf-1
    
    i           
    I = frame2im(mov(i));
    RED = im2double(I(:,:,1));
    GREEN = im2double(I(:,:,2));
    BLUE = im2double(I(:,:,3));
    [H,S,V] = rgb2hsv(I);
    
    RR1 = RED-RunningBackgroundRED1;
    GG1 = GREEN-RunningBackgroundGREEN1;
    BB1 = BLUE-RunningBackgroundBLUE1;
    SS1 = S-RunningBackgroundS1;
    
    mask1 = clean_noise_param((abs(RR1) +abs(GG1) +abs(BB1) +abs(SS1))>0.35 , 100);
    mask_primary1 = fill_shape_param4( (medfilt2(mask1,[5 5]) + mask1 )>0 ,2,2,15);
    
    RR2 = RED-RunningBackgroundRED2;
    GG2 = GREEN-RunningBackgroundGREEN2;
    BB2 = BLUE-RunningBackgroundBLUE2;
    SS2 = S-RunningBackgroundS2;
    
    mask2 = clean_noise_param((abs(RR2) +abs(GG2) +abs(BB2) +abs(SS2))>0.35 , 100);
    mask_primary2 = fill_shape_param4( (medfilt2(mask2,[5 5]) + mask2 )>0 ,2,2,15);
    
    RR3 = RED-RunningBackgroundRED3;
    GG3 = GREEN-RunningBackgroundGREEN3;
    BB3 = BLUE-RunningBackgroundBLUE3;
    SS3 = S-RunningBackgroundS3;
    
    mask3 = clean_noise_param((abs(RR3) +abs(GG3) +abs(BB3) +abs(SS3))>0.35 , 100);
    mask_primary3 = fill_shape_param4( (medfilt2(mask3,[5 5]) + mask3 )>0 ,2,2,15);
    
    RR4 = RED-RunningBackgroundRED4;
    GG4 = GREEN-RunningBackgroundGREEN4;
    BB4 = BLUE-RunningBackgroundBLUE4;
    SS4 = S-RunningBackgroundS4;
    
    mask4 = clean_noise_param((abs(RR4) +abs(GG4) +abs(BB4) +abs(SS4))>0.35 , 100);
    mask_primary4 = fill_shape_param4( (medfilt2(mask4,[5 5]) + mask4 )>0 ,2,2,15);
    
    RR5 = RED-RunningBackgroundRED5;
    GG5 = GREEN-RunningBackgroundGREEN5;
    BB5 = BLUE-RunningBackgroundBLUE5;
    SS5 = S-RunningBackgroundS5;
    
    mask5 = clean_noise_param((abs(RR5) +abs(GG5) +abs(BB5) +abs(SS5))>0.35 , 100);
    mask_primary5 = fill_shape_param4( (medfilt2(mask5,[5 5]) + mask5 )>0 ,2,2,15);
    
    RR6 = RED-RunningBackgroundRED6;
    GG6 = GREEN-RunningBackgroundGREEN6;
    BB6 = BLUE-RunningBackgroundBLUE6;
    SS6 = S-RunningBackgroundS6;
    
    mask6 = clean_noise_param((abs(RR6) +abs(GG6) +abs(BB6) +abs(SS6))>0.35 , 100);
    mask_primary6 = fill_shape_param4( (medfilt2(mask6,[5 5]) + mask6 )>0 ,2,2,15);
    
    min_diff = min(  min( min( (abs(RR1) +abs(GG1) +abs(BB1) +abs(SS1)) , (abs(RR2) +abs(GG2) +abs(BB2) +abs(SS2)) ) ,...
                                        min((abs(RR3) +abs(GG3) +abs(BB3) +abs(SS3)), (abs(RR4) +abs(GG4) +abs(BB4) +abs(SS4))) ) ,...
                                        min((abs(RR5) +abs(GG5) +abs(BB5) +abs(SS5)), (abs(RR6) +abs(GG6) +abs(BB6) +abs(SS6))) );
    
    mask = clean_noise_param(min_diff>0.2 , 500);
    mask = fill_shape_param4(mask,5,5,15);
    
    FINAL(i-srf+1) = im2frame( im2double(I).*repmat(mask,[1 1 3]) + I_Background_global.*repmat(1-mask,[1 1 3]) );
    
    RunningBackgroundRED1 = mask.*RunningBackgroundRED1 + (1-mask).*( alpha1*RED + (1-alpha1)*RunningBackgroundRED1);
    RunningBackgroundGREEN1 = mask.*RunningBackgroundGREEN1 + (1-mask).*( alpha1*GREEN + (1-alpha1)*RunningBackgroundGREEN1);
    RunningBackgroundBLUE1 = mask.*RunningBackgroundBLUE1 + (1-mask).*( alpha1*BLUE + (1-alpha1)*RunningBackgroundBLUE1);
    RunningBackgroundS1 = mask.*RunningBackgroundS1 + (1-mask).*( alpha1*S + (1-alpha1)*RunningBackgroundS1);
    
    RunningBackgroundRED2 = mask.*RunningBackgroundRED2 + (1-mask).*( alpha2*RED + (1-alpha2)*RunningBackgroundRED2);
    RunningBackgroundGREEN2 = mask.*RunningBackgroundGREEN2 + (1-mask).*( alpha2*GREEN + (1-alpha2)*RunningBackgroundGREEN2);
    RunningBackgroundBLUE2 = mask.*RunningBackgroundBLUE2 + (1-mask).*( alpha2*BLUE + (1-alpha2)*RunningBackgroundBLUE2);
    RunningBackgroundS2 = mask.*RunningBackgroundS2 + (1-mask).*( alpha2*S + (1-alpha2)*RunningBackgroundS2);
    
    RunningBackgroundRED3 = mask.*RunningBackgroundRED3 + (1-mask).*( alpha3*RED + (1-alpha3)*RunningBackgroundRED3);
    RunningBackgroundGREEN3 = mask.*RunningBackgroundGREEN3 + (1-mask).*( alpha3*GREEN + (1-alpha3)*RunningBackgroundGREEN3);
    RunningBackgroundBLUE3 = mask.*RunningBackgroundBLUE3 + (1-mask).*( alpha3*BLUE + (1-alpha3)*RunningBackgroundBLUE3);
    RunningBackgroundS3 = mask.*RunningBackgroundS3 + (1-mask).*( alpha3*S + (1-alpha3)*RunningBackgroundS3);
    
    RunningBackgroundRED4 = mask.*RunningBackgroundRED4 + (1-mask).*( alpha4*RED + (1-alpha4)*RunningBackgroundRED4);
    RunningBackgroundGREEN4 = mask.*RunningBackgroundGREEN4 + (1-mask).*( alpha4*GREEN + (1-alpha4)*RunningBackgroundGREEN4);
    RunningBackgroundBLUE4 = mask.*RunningBackgroundBLUE4 + (1-mask).*( alpha4*BLUE + (1-alpha4)*RunningBackgroundBLUE4);
    RunningBackgroundS4 = mask.*RunningBackgroundS4 + (1-mask).*( alpha4*S + (1-alpha4)*RunningBackgroundS4);
    
    RunningBackgroundRED5 = mask.*RunningBackgroundRED5 + (1-mask).*( alpha5*RED + (1-alpha5)*RunningBackgroundRED5);
    RunningBackgroundGREEN5 = mask.*RunningBackgroundGREEN5 + (1-mask).*( alpha5*GREEN + (1-alpha5)*RunningBackgroundGREEN5);
    RunningBackgroundBLUE5 = mask.*RunningBackgroundBLUE5 + (1-mask).*( alpha5*BLUE + (1-alpha5)*RunningBackgroundBLUE5);
    RunningBackgroundS5 = mask.*RunningBackgroundS5 + (1-mask).*( alpha5*S + (1-alpha5)*RunningBackgroundS5);
    
    RunningBackgroundRED6 = mask.*RunningBackgroundRED6 + (1-mask).*( alpha6*RED + (1-alpha6)*RunningBackgroundRED6);
    RunningBackgroundGREEN6 = mask.*RunningBackgroundGREEN6 + (1-mask).*( alpha6*GREEN + (1-alpha6)*RunningBackgroundGREEN6);
    RunningBackgroundBLUE6 = mask.*RunningBackgroundBLUE6 + (1-mask).*( alpha6*BLUE + (1-alpha6)*RunningBackgroundBLUE6);
    RunningBackgroundS6 = mask.*RunningBackgroundS6 + (1-mask).*( alpha6*S + (1-alpha6)*RunningBackgroundS6);
    
end;

movie2avi(FINAL,'MoviesResults\week23fill.avi','fps',movinfo.FramesPerSecond);

toc