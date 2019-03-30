function im=solidify_image(im);

SE = strel('rectangle',[10,10]);
im=imclose(im,SE);
jump=15;
for n=0:jump:180-jump
    SE = strel('line',10,n);
    im=imclose(im,SE);
end