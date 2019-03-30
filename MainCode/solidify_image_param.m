% % % This functions is supposed to recieve an incontinuous edge and reconstruct it
% % % im - a B/W image
% % % param_rec - The rectangle element by which the edge is closed
% % % param_line - The line element by which the edge is closed
% % % param_pha - The phase element by which the edge is closed

function im = solidify_image_param(im,param_rec,param_line,param_pha)

SE = strel('rectangle',[param_rec,param_rec]);
im=imclose(im,SE);
jump=param_pha;
for n=0:jump:180-jump
    SE = strel('line',param_line,n);
    im=imclose(im,SE);
end