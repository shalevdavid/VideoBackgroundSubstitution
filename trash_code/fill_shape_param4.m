%%%   returning the filled image in mask %%%

function  [mask] = fill_shape_param4(im,param_rec,param_line,param_pha); 

[nx,ny]=size(im);
im_big=zeros(nx+2*max(param_rec,param_line),ny+2*max(param_rec,param_line));
im_big(max(param_rec,param_line)+1:nx+max(param_rec,param_line) , max(param_rec,param_line)+1:ny+max(param_rec,param_line))=im;

solid_im=solidify_image_param(im_big,param_rec,param_line,param_pha);
% [mask] = fill_edges2(solid_im);

mask = imfill(solid_im(max(param_rec,param_line)+1:nx+max(param_rec,param_line) , max(param_rec,param_line)+1:ny+max(param_rec,param_line)),'holes');