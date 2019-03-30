

for n=1:efi
    %n
    im{n}=rgb2gray(im2double(frame2im(mov(n))));
    %     figure; imshow(im{n},[]);
end
im0=zeros(size(im{1}));
for  n=1:nfi
    im0=(1/15)*im{n}+im0;
end
%calculating sigma
[x,y]=size(im);
sigma1=sum(sum((im{2}-im{1}).^2))/(2*x*y)


%imshow(im0,[]);
for n=nfi+1:efi
    diff{n-nfi}=abs(im{n}-im0);
    figure; imshow(diff{n-nfi}>0.05,[]); title([num2str(n)]);   
end