function [im0,sigma1] = initialize(mov,efi,nfi);

for n=1:87
    n
    im{n}=rgb2gray(im2double(frame2im(mov(n))));
    %     figure; imshow(im{n},[]);
end
im0=zeros(size(im{1}));
for  n=1:15
    im0=(1/15)*im{n}+im0;
end
%calculating sigma
[x,y]=size(im);
sigma1=sum(sum((im{2}-im{1}).^2))/(2*x*y)


imshow(im0,[]);
for n=16:87
    diff{n-15}=abs(im{n}-im0);
%     figure; imshow(diff{n-15}>0.05,[]); title([num2str(n)]);   
end