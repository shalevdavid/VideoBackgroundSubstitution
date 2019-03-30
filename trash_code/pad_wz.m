function im2=pad_wz(im,n);
im=im2double(im);
[a,b,c]=size(im);

im2=zeros(a+2*n,b+2*n,c);
im2([n+1:a+n],[n+1:b+n],:)=im;