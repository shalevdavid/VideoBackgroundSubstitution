function im=easy_solidify_image(im);

SE = strel('rectangle',[5,5]);
im=imclose(im,SE);

jump=15;
for n=0:jump:180-jump
    SE = strel('line',5,n);
    im=imclose(im,SE);
end

