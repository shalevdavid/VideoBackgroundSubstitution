%%%   returning the filled image in mask %%%

function  [mask] = fill_shape(im); 

[nx,ny]=size(im);

for i =1:3
    im = 1*(im>0);
    im = fillcol(im,ny+1-i);
    im = fillcol(im,i);
    im = fillrow(im,nx+1-i);
    im = fillrow(im,i);
end

im_big = zeros(nx+20,ny+20);
im_big(11:nx+10,11:ny+10) = im;

solid_im = hard_solidify_image(im_big);

% [mask] = fill_edges2(solid_im);

mask = imfill(solid_im(11:nx+10,11:ny+10),'holes');