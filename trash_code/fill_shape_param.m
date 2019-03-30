%%%   returning the filled image in mask %%%

function  [mask] = fill_shape_param(im,param_rec,param_line,param_pha); 

[nx,ny]=size(im);

for i =1:10
    im=1*(im>0);
    im=fillcol(im,ny+1-i);
    im=fillcol(im,i);
    im=fillrow(im,nx+1-i);
    im=fillrow(im,i);
end

im_big=zeros(nx+2*max(param_rec,param_line),ny+2*max(param_rec,param_line));
im_big(max(param_rec,param_line)+1:nx+max(param_rec,param_line) , max(param_rec,param_line)+1:ny+max(param_rec,param_line))=im;

solid_im=solidify_image_param(im_big,param_rec,param_line,param_pha);


[mask] = fill_edges2(solid_im);
mask=mask(max(param_rec,param_line)+1:nx+max(param_rec,param_line) , max(param_rec,param_line)+1:ny+max(param_rec,param_line));