clc;
clear all;
close all;
%%%%%%%%%%%%%%%%   defining constants  %%%%%%%%%%%%%%%%%%%%
Numpixels =10000;                                    % Numpixels = the saf of the number of pixels
sfi=1;                                                        % sfi= starting frame index
efi=170;                                                       % efi= ending frame index
dfi=1;                                                            %dfi = difference frame index
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mov = aviread('Z:\Video1',sfi:efi);                         %%%%  loading a movie
%%%%%%%   The  algorithem of finding the first good frame     %%%%%%%
frame1 = mov(1);
frame2 = mov(1+dfi);
[I1,Map] = frame2im(frame1);
Ibw1= rgb2gray(I1);
[I2,Map] = frame2im(frame2);
Ibw2 = rgb2gray(I2);
diff = (im2double(Ibw2) - im2double(Ibw1));
h=imhist(diff(:),256);
plot(h)
imshow(diff,[])
plot(h)
h=imhist(diff(:),1256);
plot(h)
t=0:0.1:1
uint8(t)
MIN=min(diff(:));
MAX=max(diff(:));
diff=256.*(diff-MIN)./(MAX-MIN);
imshow(diff,[])
max(diff(:))
d=uint8(diff);
imshow(d,[])
h=imhist(d(:),1256);
plot(h)
h=imhist(d(:),256);
plot(h)
ind1=d<180;
ind2=d>140;
ind=(ind1-ind2)==0;
imshow(ind.*d,[]);
imshow(ind.*diff,[]);
imshow(ind,[]);
R=I1(:,:,1);
G=I1(:,:,2);
B=I1(:,:,3);
[H,S,V]=rgb2hsv(I1);
V2=0.33(R+G+B);
V2=0.33*(R+G+B);
imshow([V,V2],[]);
imshow([V2],[]);
V2=0.3*R+0.6*G+0.1*B;
imshow([V2],[]);
%-- 04/02/07 22:27 --%
close all
clear all;
cloze all;
close all;
clear all;
%-- 05/02/07 01:12 --%
%-- 05/02/07 13:08 --%
CLOse all;
close all;
%-- 05/02/07 16:58 --%
%-- 06/02/07 18:05 --%
imshow(mov(I1)
imshow(i1)
imshow(I1)
[H,S,V]=rgb2hsv(Ibw2);
imagsec(H)
imagesec(H)
imgsec(H)
imagesc(H)
imagesc(Ibw2)
imshow(Ibw2)
imshow(V)
frame1 = mov(1);
frame2 = mov(1+dfi);
[I1,Map] = frame2im(frame1);
Ibw1= rgb2gray(I1);
[I2,Map] = frame2im(frame2);
Ibw2 = rgb2gray(I2);
diff = (im2double(Ibw2) - im2double(Ibw1));
h=imhist(diff(:),256);
plot(h)
imshow(diff,[])
plot(h)
h=imhist(diff(:),1256);
plot(h)
t=0:0.1:1
uint8(t)
MIN=min(diff(:));
MAX=max(diff(:));
diff=256.*(diff-MIN)./(MAX-MIN);
imshow(diff,[])
max(diff(:))
d=uint8(diff);
imshow(d,[])
h=imhist(d(:),1256);
plot(h)
h=imhist(d(:),256);
plot(h)
ind1=d<180;
ind2=d>140;
ind=(ind1-ind2)==0;
imshow(ind.*d,[]);
imshow(ind.*diff,[]);
imshow(ind,[]);
R=I1(:,:,1);
G=I1(:,:,2);
B=I1(:,:,3);
%-- 12/03/07 16:41 --%
R=I1(:,:,1);
G=I1(:,:,2);
B=I1(:,:,3);
[H,S,V]=rgb2hsv(I1);
V2=0.33(R+G+B);
V2=0.33*(R+G+B);
imshow([V,V2],[]);
imshow([V2],[]);
V2=0.3*R+0.6*G+0.1*B;
imshow([V2],[]);
a=[ 0 0 0; 1 1 1]
a(:)
max(a(:))
