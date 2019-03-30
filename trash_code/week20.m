%%
tic

movinfo = aviinfo('samplemovies\dmf070502-003.avi');
mov = aviread('samplemovies\dmf070502-003.avi');                                   %%%%  loading a movie
[I_Background_global,map2] = imread('backgrounds\messiGolaso.jpg');                %%%% protected variable I_Background_global
I_Background_global = im2double(I_Background_global);

%%% if the camera has an Interlace problem we can use the following
% mov = InterlaceMovie(mov);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sfi=1;                                                     % sfi= starting frame index
efi=size(mov,2);                                           % efi= ending frame index
nfi=90;                                                    % nfi = the number of frames required for initialization - stage 2
srf=nfi+1;                                                   % srf = starting running frame - stage 3
erf=efi;                                                   % erf = ending running frame - stage 3
stf=erf+1;                                                 % sti = starting tracking frame - stage 4 
etf=efi;                                                   % eti = ending tracking frame - stage 4

[J,K] = size(rgb2gray(frame2im(mov(1))));

[N,B,S] = size(I_Background_global);
I_Background_global = I_Background_global( N-J+1:N , B-K+1:B ,:);

toc
%%
tic

alpha = 0.2;       % The Learning Parameter 
RunningBackgroundRED = 0;
RunningBackgroundGREEN = 0;
RunningBackgroundBLUE = 0;
RunningBackgroundS = 0;

for i=1:nfi
    
    I = frame2im(mov(i));
%     GRAY = im2double(rgb2gray(I));
    RED = im2double(I(:,:,1));
    GREEN = im2double(I(:,:,2));
    BLUE = im2double(I(:,:,3));

    [H,S,V] = rgb2hsv(I);

%     SourceBackgroundGRAY = SourceBackgroundGRAY + GRAY;
   RunningBackgroundRED = (1-alpha)*RunningBackgroundRED + alpha+RED;
   RunningBackgroundGREEN = (1-alpha)*RunningBackgroundGREEN + alpha*GREEN;
    RunningBackgroundBLUE = (1-alpha)*RunningBackgroundBLUE + alpha*BLUE;
%     RunningBackgroundH = (1-alpha)*RunningBackgroundH + alpha*H;
   RunningBackgroundS = (1-alpha)*RunningBackgroundS +alpha*S;
    
end;


toc
%%
tic

alpha = 0.05;       % The Learning Parameter 
RunningBackgroundRED = SourceBackgroundRED;
RunningBackgroundGREEN = SourceBackgroundGREEN;
RunningBackgroundBLUE = SourceBackgroundBLUE;
RunningBackgroundS = SourceBackgroundS;

for i=srf:erf-1
    
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
    
    mask2 = clean_noise_param((abs(RR) +abs(GG) +abs(BB) +abs(SS))>0.35 , 100);
    mask_primary = fill_shape_param4( (medfilt2(mask2,[5 5]) + mask2 )>0 ,2,2,15);
    
    mask = mask_primary;
    
    FINAL(i-srf+1) = im2frame( im2double(I).*repmat(mask,[1 1 3]) + I_Background_global.*repmat(1-mask,[1 1 3]) );
    
    RunningBackgroundRED = mask.*RunningBackgroundRED + (1-mask).*( alpha*RED + (1-alpha)*RunningBackgroundRED);
    RunningBackgroundGREEN = mask.*RunningBackgroundGREEN + (1-mask).*( alpha*GREEN + (1-alpha)*RunningBackgroundGREEN);
    RunningBackgroundBLUE = mask.*RunningBackgroundBLUE + (1-mask).*( alpha*BLUE + (1-alpha)*RunningBackgroundBLUE);
    RunningBackgroundS = mask.*RunningBackgroundS + (1-mask).*( alpha*S + (1-alpha)*RunningBackgroundS);
    
end;

movie2avi(FINAL,'MoviesResults\Finon_19_4alpha=0.2.avi','fps',movinfo.FramesPerSecond);

toc