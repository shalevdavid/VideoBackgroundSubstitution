%%%   returning the filled image in mask %%%

function  [mask] = fill_shape(im); 

[nx,ny]=size(im);
im_big = zeros(nx+20,ny+20);
im_big(11:nx+10,11:ny+10) = im;

solid_im = hard_solidify_image(im_big);

% [mask] = fill_edges2(solid_im);

mask = imfill(solid_im(11:nx+10,11:ny+10),'holes');