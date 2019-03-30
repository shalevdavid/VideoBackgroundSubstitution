function [mask,num] = fill_edges2(im);

[Nx,Ny]=size(im);
%performing closing operation inorder to make sure the edges are continues
im=solidify_image(im);


%Deleting small or false edges (assuming main image consistes of large edges)
[L,num] = bwlabel(im==1,8);
im=zeros(size(L));
for m=1:num
    Z=(L==m);
    S=sum(Z(:));
    if (S < 20)
        L(find(L==m))=0;
    else
        ix=find(1*(sum(Z')>0)==1); iy=find(1*(sum(Z)>0)==1);
        px=ix(1)-1; py=iy(1)-1;
        stats =  regionprops(1*Z,'FilledImage');
        stats =  regionprops(1*stats.FilledImage,'FilledImage');
        [nx,ny]=size(stats.FilledImage);
        tx=1:nx; ty=1:ny;
        im(px+tx,py+ty)=im(px+tx,py+ty)+1*stats.FilledImage;
    end
end


mask=1*(im>0);