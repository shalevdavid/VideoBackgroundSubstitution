% %%%%%     clean noise   %%%%%%

function im = clean_noise_hard(diff);

[L,num]=bwlabel(diff);
im=zeros(size(L));
for m=1:num
    Z=(L==m);
    mass=sum(Z(:));
    if mass > 800
        im=im+Z;
    end
end

im=1*(im>0);

