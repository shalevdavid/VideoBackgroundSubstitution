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

alpha = 0.05;       % The Learning Parameter 
RunningBackgroundRED = SourceBackgroundRED;
RunningBackgroundGREEN = SourceBackgroundGREEN;
RunningBackgroundBLUE = SourceBackgroundBLUE;
RunningBackgroundS = SourceBackgroundS;

Ip = frame2im(mov(srf-1));
REDp = im2double(Ip(:,:,1));
GREENp = im2double(Ip(:,:,2));
BLUEp = im2double(Ip(:,:,3));
[Hp,Sp,Vp] = rgb2hsv(Ip);

I = frame2im(mov(srf));
RED = im2double(I(:,:,1));
GREEN = im2double(I(:,:,2));
BLUE = im2double(I(:,:,3));
[H,S,V] = rgb2hsv(I);

for i=srf:erf-1
    
    i    
    In = frame2im(mov(i+1));
    REDn = im2double(In(:,:,1));
    GREENn = im2double(In(:,:,2));
    BLUEn = im2double(In(:,:,3));
    [Hn,Sn,Vn] = rgb2hsv(In);
    
    RR = RED-RunningBackgroundRED;
    GG = GREEN-RunningBackgroundGREEN;
    BB = BLUE-RunningBackgroundBLUE;
    SS = S-RunningBackgroundS;

    diffRp = clean_noise_param( abs(RED-REDp)>0.06 , 10 );
    diffGp = clean_noise_param( abs(GREEN-GREENp)>0.06 , 10 );
    diffBp = clean_noise_param( abs(BLUE-BLUEp)>0.06 , 10 );
    diffSp = clean_noise_param( abs(S-Sp)>0.05 , 50 );
    
    diffRn = clean_noise_param( abs(REDn-RED)>0.06 , 10 );
    diffGn = clean_noise_param( abs(GREENn-GREEN)>0.06 , 10 );
    diffBn = clean_noise_param( abs(BLUEn-BLUE)>0.06 , 10 );
    diffSn = clean_noise_param( abs(Sn-S)>0.05 , 50 );
    
    diffcorr = (diffRn.*diffRp+diffGn.*diffGp+diffBn.*diffBp)>0;
    
    mask2 = clean_noise_param((abs(RR) +abs(GG) +abs(BB) +abs(SS))>0.4,100);
    mask_primary = fill_shape_param4( (medfilt2(mask2,[5 5]) + mask2 )>0 ,2,2,15);
    
    mask = mask_primary;
  
    REDp = RED;
    GREENp = GREEN;
    BLUEp = BLUE;
    Hp = H; 
    Sp = S;
    Vp = V;
    Ip = I;
    
%     I_Background = I_Background_global;                                  %%%  reading  background picture to I_Background - coloured
%     dm = im2double(mask);                                                %%% mask is the Ibw2 filled - binary image
%     inv = ones(size(dm,1),size(dm,2))-dm;                                %%% inv1 is the inverse of dm1 - binary image
%     inv = [ones(size(inv,1),(size(I_Background,2)-size(inv,2))),inv];    
%     inv = [ones((size(I_Background,1)-size(inv,1)),size(inv,2));inv];
%     for j=1:3
%         I(:,:,j) = double(I(:,:,j)).*dm;
%     end;
%     for j=1:3
%         I_Background(:,:,j) = double(I_Background(:,:,j)).*inv;
%     end;
%     for j=1:3
%         x(:,:,j) = [zeros(size(I(:,:,j),1),(size(I_Background,2)-size(I(:,:,j),2))),I(:,:,j)]; 
%         y(:,:,j) = [zeros((size(I_Background,1)-size(x(:,:,j),1)),size(x(:,:,j),2));x(:,:,j)];
%     end;
    FINAL(i-srf+1) = im2frame( im2double(Ip).*repmat(mask,[1 1 3]) + I_Background_global.*repmat(1-mask,[1 1 3]) );
    
    RED = REDn;
    GREEN = GREENn;
    BLUE = BLUEn;
    H = Hn; 
    S = Sn;
    V = Vn;
    I = In;
    
    RunningBackgroundRED = mask.*RunningBackgroundRED + (1-mask).*( alpha*RED + (1-alpha)*RunningBackgroundRED);
    RunningBackgroundGREEN = mask.*RunningBackgroundGREEN + (1-mask).*( alpha*GREEN + (1-alpha)*RunningBackgroundGREEN);
    RunningBackgroundBLUE = mask.*RunningBackgroundBLUE + (1-mask).*( alpha*BLUE + (1-alpha)*RunningBackgroundBLUE);
    RunningBackgroundS = mask.*RunningBackgroundS + (1-mask).*( alpha*S + (1-alpha)*RunningBackgroundS);
    
end;

movie2avi(FINAL,'MoviesResults\Final_19_3.avi','fps',movinfo.FramesPerSecond);

toc